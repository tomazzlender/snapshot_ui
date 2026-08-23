# frozen_string_literal: true

require "mail"

module SnapshotUI
  module Rails
    # Reads a stored "mail" snapshot back into a usable form: the reconstructed
    # Mail::Message plus the parts and metadata the mail view needs.
    class Mail
      HTML = "text/html"
      TEXT = "text/plain"

      def initialize(snapshot)
        @type_data = snapshot.type_data
      end

      def message
        @message ||= begin
          message = ::Mail::Message.new(@type_data[:message].to_s)
          message.bcc = @type_data[:bcc] if @type_data[:bcc]
          message
        end
      end

      def mailer
        @type_data[:mailer]
      end

      def action
        @type_data[:action]
      end

      def html?
        !part_for(HTML).nil?
      end

      def text?
        !part_for(TEXT).nil?
      end

      # Both alternatives were captured — offer a switcher.
      def multipart_alternatives?
        html? && text?
      end

      def default_mime_type
        if html?
          HTML
        else
          (text? ? TEXT : message.mime_type)
        end
      end

      # The decoded body for a MIME type, falling back to the message body for a
      # single-part email whose type matches.
      def part_body(mime_type)
        if (part = part_for(mime_type))
          part.respond_to?(:decoded) ? part.decoded : part.to_s
        end
      end

      def attachments
        message.attachments || []
      end

      def eml
        message.to_s
      end

      private

      def part_for(mime_type)
        message.find_first_mime_type(mime_type) || ((message.mime_type == mime_type) ? message : nil)
      end
    end
  end
end
