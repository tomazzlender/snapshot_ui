# frozen_string_literal: true

require_relative "snapshot/context"
require_relative "snapshot/storage"
require "json"

module SnapshotUI
  class Snapshot
    # The kind of thing a snapshot holds. "response" is the default and the only
    # type the core gem knows how to capture; other types (e.g. "mail", added by
    # snapshot_ui-rails) store their own data under +type_data+ and are rendered
    # by a registered renderer (see SnapshotUI::Web).
    DEFAULT_TYPE = "response"

    attr_reader :slug, :context, :type, :type_data

    class NotFound < StandardError; end

    def self.persist(snapshotee:, context:, type: DEFAULT_TYPE, type_data: nil)
      new.extract(snapshotee: snapshotee, context: context, type: type, type_data: type_data).persist
    end

    def self.find(slug)
      json = JSON.parse(Storage.read(slug), symbolize_names: true)
      new.from_json(json)
    rescue Errno::ENOENT, Errno::EISDIR, Storage::InvalidKey
      raise NotFound.new("Snapshot with a slug `#{slug}` can't be found.")
    rescue JSON::ParserError => error
      raise NotFound.new("Snapshot with a slug `#{slug}` can't be read: #{error.message}")
    end

    def self.grouped_by_test_case
      all.group_by do |snapshot|
        snapshot.context.test_group
      end
    end

    def self.publish_snapshots_in_progress
      return unless SnapshotUI::Snapshot::Storage.in_progress_directory.exist?
      SnapshotUI::Snapshot::Storage.publish_snapshots_in_progress
    end

    def self.clear_snapshots_in_progress
      Storage.clear(:in_progress)
    end

    def self.clear_snapshots
      Storage.clear
    end

    # A token that changes whenever the published snapshots change. The web UI
    # polls it to know when to refresh.
    def self.version
      Storage.version
    end

    private_class_method def self.all
      snapshots = Storage.list.map { |slug| find(slug) }

      order_by_line_number(snapshots)
    end

    private_class_method def self.order_by_line_number(snapshots)
      snapshots.sort_by do |snapshot|
        snapshot.context.order_index
      end
    end

    # +type_data+ lets a caller supply the stored payload directly (used by
    # snapshot_ui-rails for mail). When omitted, the response body is extracted
    # from the snapshotee.
    def extract(snapshotee:, context:, type: DEFAULT_TYPE, type_data: nil)
      @type = type
      @type_data = type_data || extract_response_type_data(snapshotee)
      @context = Context.new(context)
      self
    end

    def persist
      Storage.write(context.to_slug, JSON.pretty_generate(as_json))
    end

    # The response body, for the default "response" type.
    def body
      type_data[:body]
    end

    def response?
      type == DEFAULT_TYPE
    end

    def as_json
      {
        type: type,
        type_data: type_data,
        context: {
          test_framework: context.test_framework,
          test_case_name: context.test_case_name,
          method_name: context.method_name,
          source_location: context.source_location,
          take_snapshot_index: context.take_snapshot_index,
          metadata: context.metadata
        },
        slug: context.to_slug
      }
    end

    def from_json(json)
      # Snapshots written before types existed have no :type and their body sits
      # directly under :type_data — treat them as responses.
      @type = json[:type] || DEFAULT_TYPE
      @type_data = json[:type_data] || {}
      @context = Context.new(json[:context])
      @slug = json[:slug]
      self
    end

    private

    def extract_response_type_data(snapshotee)
      body =
        if snapshotee.respond_to?(:body)
          snapshotee.body
        elsif snapshotee.is_a?(String)
          snapshotee
        end

      {body: body}
    end
  end
end
