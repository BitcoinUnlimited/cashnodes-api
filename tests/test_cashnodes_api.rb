require_relative '../cashnodes_api'
require 'minitest/autorun'
require 'json'
require 'rack/test'

class CahsnodesAPITest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_snapshots_is_ok
    Dir.mktmpdir  do |dir|
      20.times do |i|
        open("#{dir}/#{i.to_s.rjust(2, "0")}.json", 'w') {|f| f.puts('hello')}
      end

      get '/snapshots'
      assert_equal(200, last_response.status)
    end
  end

  def test_snapshots
    Dir.mktmpdir  do |dir|
      20.times do |i|
        open("#{dir}/#{i}.json", 'w') {|f| f.puts('hello')}
      end

      SnapshotsList.stub(:base_dir, dir) do
        get '/snapshots'
        assert_equal(200, last_response.status)
        body = JSON.parse(last_response.body)
        assert_equal(10, body['snapshots'].size)
        assert_equal(1, body['meta']['page'])
        assert_equal(2, body['meta']['next'])
        assert_nil(body['meta']['prev'])
      end
    end
  end

  def test_snapshots_with_page
    Dir.mktmpdir  do |dir|
      20.times do |i|
        open("#{dir}/#{i}.json", 'w') {|f| f.puts('hello')}
      end

      SnapshotsList.stub(:base_dir, dir) do
        get '/snapshots', page: 2
        assert_equal(200, last_response.status)
        body = JSON.parse(last_response.body)
        assert_equal(10, body['snapshots'].size)
        assert_equal(2, body['meta']['page'])
        assert_nil(body['meta']['next'])
        assert_equal(1, body['meta']['prev'])
      end
    end
  end

  def test_get_snapshot_ok
    Tempfile.open('foo') do |file|
      GetSnapshot.stub(:call, file.path) do
        get '/snapshots/1'
        assert_equal(200, last_response.status)
      end
    end
  end

  def test_get_snapshot_not_found
    GetSnapshot.stub(:call, nil) do
      get '/snapshots/2'
      assert_equal(404, last_response.status)
    end
  end
end
