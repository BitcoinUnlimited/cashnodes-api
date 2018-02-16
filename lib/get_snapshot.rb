class GetSnapshot
  def self.call(timestamp)
    path = snapshot_path(timestamp)
    File.file?(path) ? path : nil
  end

  private

  def self.base_dir
    ENV['SNAPSHOTS_BASE_DIR']
  end

  def self.snapshot_path(timestamp)
    File.join(base_dir, "#{timestamp}.json")
  end
end
