# frozen_string_literal: true

require_relative "snapshot/context"
require_relative "snapshot/storage"
require "json"

module SnapshotUI
  class Snapshot
    attr_reader :slug, :context, :body

    class NotFound < StandardError; end

    def self.persist(snapshotee:, context:)
      new.extract(snapshotee: snapshotee, context: context).persist
    end

    def self.find(slug)
      json = JSON.parse(Storage.read(slug), symbolize_names: true)
      new.from_json(json)
    rescue Errno::ENOENT
      raise NotFound.new("Snapshot with a slug `#{slug}` can't be found.")
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

    private_class_method def self.all
      snapshots = Storage.list.map { |slug| find(slug) }

      order_by_line_number(snapshots)
    end

    private_class_method def self.order_by_line_number(snapshots)
      snapshots.sort_by do |snapshot|
        snapshot.context.order_index
      end
    end

    def extract(snapshotee:, context:)
      @body = snapshotee.body
      @snapshotee_class = snapshotee.class.to_s
      @context = Context.new(context)
      self
    end

    def persist
      Storage.write(context.to_slug, JSON.pretty_generate(as_json))
    end

    def as_json
      {
        type_data: {
          snapshotee_class: @snapshotee_class,
          body: body
        },
        context: {
          test_framework: context.test_framework,
          test_case_name: context.test_case_name,
          method_name: context.method_name,
          source_location: context.source_location,
          take_snapshot_index: context.take_snapshot_index
        },
        slug: context.to_slug
      }
    end

    def from_json(json)
      @body = json[:type_data][:body]
      @context = Context.new(json[:context])
      @slug = json[:slug]
      self
    end
  end
end
