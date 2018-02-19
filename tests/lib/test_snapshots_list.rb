require 'minitest/autorun'
require_relative '../../lib/snapshots_list'
require 'redis'

describe SnapshotsList do
  before do
    @redis_conn = Redis.new
    150.times do |i|
      @redis_conn.lpush('dumped_snapshots', i)
    end
  end

  after do
    @redis_conn.flushdb
  end

  describe 'without a page' do
    it 'returns the first page' do
      snapshots = SnapshotsList.call(@redis_conn)[:snapshots]
      snapshots.size.must_equal 100
      100.times do |i|
        snapshots.include?("#{150 - i - 1}").must_equal true
      end
    end
  end

  describe 'with a specific page' do
    it 'returns the requested page' do
      snapshots = SnapshotsList.call(@redis_conn, 1)[:snapshots]
      snapshots.size.must_equal 100
      snapshots = SnapshotsList.call(@redis_conn, 2)[:snapshots]
      snapshots.size.must_equal 50
    end
  end
end
