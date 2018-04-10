class SnapshotsList
  def self.call(page=1)
    tot_snapshots = snapshots_count
    {
      snapshots: snapshots(page),
      meta: pagination_meta(page, tot_snapshots)
    }
  end

  private

  PER_PAGE = 10

  def self.base_dir
    ENV['SNAPSHOTS_BASE_DIR']
  end

  def self.snapshot_paths
    "#{base_dir}/*.json"
  end

  def self.snapshots_count
    Dir[snapshot_paths].size
  end

  def self.snapshots(page=1)
    all_snapshots = Dir[snapshot_paths].sort_by{ |f| File.mtime(f) }.reverse
    all_snapshots[((page - 1) * PER_PAGE)..(page * PER_PAGE  - 1)].collect do |f|
      File.basename(f).split('.')[0]
    end
  end

  def self.pagination_meta(page, count=nil)
    len = count || snapshots_count
    pages = (len / PER_PAGE.to_f).ceil
    meta = {page: page, total_pages: pages, total: len}

    if page < pages
      meta[:next] = page + 1
    end

    if page > 1
      meta[:prev] = page - 1
    end
    meta
  end
end
