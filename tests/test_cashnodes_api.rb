require_relative '../cashnodes_api'
require 'minitest/autorun'
require 'json'
require 'rack/test'
require 'redis'

class CahsnodesAPITest < Minitest::Test
  include Rack::Test::Methods

  def setup
    @redis_conn = Redis.new
    150.times do |i|
      @redis_conn.lpush('dumped_snapshots', i)
    end
  end

  def teardown
    @redis_conn.flushdb
  end

  def app
    Sinatra::Application
  end

  def test_snapshots_is_ok
    get '/snapshots'
    assert_equal(200, last_response.status)
  end

  def test_snapshots
    get '/snapshots'
    assert_equal(200, last_response.status)
    body = JSON.parse(last_response.body)
    assert_equal(100, body['snapshots'].size)
    assert_equal(1, body['meta']['page'])
    assert_equal(2, body['meta']['next'])
    assert_nil(body['meta']['prev'])
  end

  def test_snapshots_with_page
    get '/snapshots', page: 2
    assert_equal(200, last_response.status)
    body = JSON.parse(last_response.body)
    assert_equal(50, body['snapshots'].size)
    assert_equal(2, body['meta']['page'])
    assert_nil(body['meta']['next'])
    assert_equal(1, body['meta']['prev'])
  end

  def test_get_snapshot_ok
    get '/snapshots/1'
    assert_equal(200, last_response.status)
  end

  def test_get_snapshot_not_found
    get '/snapshots/2'
    assert_equal(404, last_response.status)
  end
end
