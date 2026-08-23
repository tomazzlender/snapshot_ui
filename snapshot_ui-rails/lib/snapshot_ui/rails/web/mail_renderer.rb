# frozen_string_literal: true

require "base64"
require "rack/utils"
require_relative "../mail"

module SnapshotUI
  module Rails
    module Web
      # Renders "mail" snapshots for SnapshotUI::Web. Registered by the railtie.
      #
      # #show renders the email chrome (headers, an HTML/plain-text switcher when
      # both parts exist, attachments, an .eml download) with the chosen part
      # shown in an iframe. #raw serves a single part with its content type, or
      # the .eml file.
      module MailRenderer
        VIEW = "snapshots/mail/show"

        module_function

        def show(snapshot, view)
          mail = SnapshotUI::Rails::Mail.new(snapshot)
          part = requested_part(view) || mail.default_mime_type

          presenter = Presenter.new(snapshot: snapshot, mail: mail, part: part, view: view)
          view.render_body_in_layout(presenter.render_body, status: 200)
        end

        def raw(snapshot, view)
          mail = SnapshotUI::Rails::Mail.new(snapshot)

          if view.request.params["eml"]
            filename = [mail.mailer, mail.action].compact.join("#")
            filename = "email" if filename.empty?
            return [200,
              {"content-type" => "message/rfc822",
               "content-disposition" => %(attachment; filename="#{filename}.eml")},
              [mail.eml]]
          end

          mime_type = view.request.params["part"] || mail.default_mime_type
          body = mail.part_body(mime_type)

          if body
            [200, {"content-type" => "#{mime_type}; charset=utf-8"}, [body]]
          else
            [404, {"content-type" => "text/plain; charset=utf-8"},
              ["Email part `#{mime_type}` not found in this snapshot."]]
          end
        end

        def requested_part(view)
          mime = view.request.params["part"]
          mime if [SnapshotUI::Rails::Mail::HTML, SnapshotUI::Rails::Mail::TEXT].include?(mime)
        end

        # Passed as the render context so the template can call these helpers and
        # still reach the core view's URL/asset helpers via method_missing.
        class Presenter
          H = Rack::Utils

          def initialize(snapshot:, mail:, part:, view:)
            @snapshot = snapshot
            @mail = mail
            @part = part
            @view = view
          end

          attr_reader :snapshot, :mail, :part, :view

          # Renders this gem's mail template to a <body> string. The template
          # lives under this file's directory (web/views/...).
          def render_body
            template = File.expand_path("views/#{MailRenderer::VIEW}.html.erb", __dir__)
            ERB.new(File.read(template), trim_mode: "-").result(binding)
          end

          def h(text)
            H.escape_html(text.to_s)
          end

          def raw_part_url(mime_type)
            base = view.raw_snapshot_path(snapshot.slug)
            "#{base}?#{H.build_query("part" => mime_type)}"
          end

          def eml_url
            "#{view.raw_snapshot_path(snapshot.slug)}?#{H.build_query("eml" => "1")}"
          end

          def show_url(mime_type)
            "#{view.snapshot_path(snapshot.slug)}?#{H.build_query("part" => mime_type)}"
          end

          def attachment_data_uri(attachment)
            "data:application/octet-stream;base64,#{Base64.strict_encode64(attachment.decoded)}"
          end

          def attachment_filename(attachment)
            attachment.respond_to?(:original_filename) ? attachment.original_filename : attachment.filename
          end

          # Let the template reach the core Application helpers (root_path, etc.).
          def method_missing(name, *args, &block)
            view.respond_to?(name, true) ? view.send(name, *args, &block) : super
          end

          def respond_to_missing?(name, include_private = false)
            view.respond_to?(name, include_private) || super
          end
        end
      end
    end
  end
end
