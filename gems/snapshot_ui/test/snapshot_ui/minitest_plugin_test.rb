# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../helpers/fixture_helper"
require "open3"
require "rbconfig"

# Runs the dummy application's tests in a separate process, the way a test suite
# using Snapshot UI would run, to check the minitest plugin end to end.
class SnapshotUI::MinitestPluginTest < Minitest::Spec
  include FixtureHelper

  let(:storage) { SnapshotUI::Snapshot::Storage }

  def run_dummy_tests(*arguments, env: {})
    command = [RbConfig.ruby, "-I", "lib", "-e", 'require "minitest/autorun"; require "./test/dummy/test/dummy_test"', "--", *arguments]

    Open3.capture2e({"TAKE_SNAPSHOTS" => nil}.merge(env), *command, chdir: File.expand_path("../..", __dir__))
  end

  it "publishes the snapshots taken during a run with --take-snapshots, exactly once" do
    copy_snapshot_fixture

    output, status = run_dummy_tests("--take-snapshots")

    assert status.success?, output
    _(output).must_match(/4 runs, \d+ assertions, 0 failures, 0 errors/)
    _(output.scan("UI snapshots are ready for review at http://localhost:3001/ui/snapshots").size).must_equal 1, output
    _(storage.list.size).must_equal 4
    _(storage.list.all? { |slug| slug.start_with?("test/dummy_test_") }).must_equal true
    _(storage.in_progress_directory.exist?).must_equal false
  end

  it "takes snapshots when TAKE_SNAPSHOTS=1 is set instead" do
    copy_snapshot_fixture

    output, status = run_dummy_tests(env: {"TAKE_SNAPSHOTS" => "1"})

    assert status.success?, output
    _(output).must_match "UI snapshots are ready for review"
    _(storage.list.size).must_equal 4
  end

  it "leaves the published snapshots alone when snapshots are not being taken" do
    copy_snapshot_fixture

    output, status = run_dummy_tests

    assert status.success?, output
    _(output).must_match(/4 runs, \d+ assertions, 0 failures, 0 errors/)
    _(output).wont_match "UI snapshots"
    _(storage.list.sort).must_equal ["dummy-app", "test/dummy_test_19_0"]
  end
end
