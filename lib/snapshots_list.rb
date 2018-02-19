class SnapshotsList
  def self.call(redis_conn, page=1)
    {
      snapshots: redis_conn.lrange(
        SNAPSHOTS_KEY,
        (page - 1) * PER_PAGE,
        page * PER_PAGE - 1),
      meta: pagination_meta(redis_conn, page)
    }
  end

  private

  SNAPSHOTS_KEY = 'dumped_snapshots'
  PER_PAGE = 100

  def self.pagination_meta(redis_conn, page)
    len = redis_conn.llen(SNAPSHOTS_KEY)
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
