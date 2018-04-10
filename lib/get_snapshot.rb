class GetSnapshot
  def self.call(timestamp, logger=nil)
    path = snapshot_path(timestamp, logger)
    if !path
      return nil
    end

    File.file?(path) ? path : nil
  end

  private

  def self.base_dir
    ENV['SNAPSHOTS_BASE_DIR']
  end

  def self.snapshot_path(timestamp, logger=nil)
    bdir = base_dir
    if !bdir
      return nil
    end
    full_path = File.expand_path(File.join(bdir, "#{timestamp}.json"))
    if File.dirname(full_path) != bdir
      if logger
        logger.warn("bad path: #{full_path}")
      end
      return nil
    end

    full_path
  end
end
