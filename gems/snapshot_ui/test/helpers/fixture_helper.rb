# frozen_string_literal: true

module FixtureHelper
  def copy_snapshot_fixture
    fixture_path = Pathname.new(__FILE__).dirname.join("../fixtures/snapshot_ui")
    tmp_path = Pathname.new(__FILE__).dirname.join("../dummy/tmp")
    snapshots_directory = tmp_path.join("snapshot_ui")

    tmp_path.rmtree
    tmp_path.mkdir
    FileUtils.cp_r(fixture_path, snapshots_directory)
  end

  def clean_snapshots
    Pathname.new(__FILE__).dirname.join("../dummy/tmp").rmtree
  end
end
