# frozen_string_literal: true

module SnapshotUI
  class Web
    def call(_env)
      [200, {"content-type" => "text/html"}, ["A list of snapshots"]]
    end
  end
end
