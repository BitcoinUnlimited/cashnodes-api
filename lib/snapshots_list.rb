class SnapshotsList
  def self.call(redis_conn, page=1)
    redis_conn.lrange(
      SNAPSHOTS_KEY,
      (page - 1) * PER_PAGE,
      page * PER_PAGE - 1)
  end

  private

  SNAPSHOTS_KEY = 'dumped_snapshots'
  PER_PAGE = 100
end
