require 'bundler/setup'
require 'yajl'
require 'rack/cors'
require 'sinatra'

require_relative 'lib/snapshots_list'
require_relative 'lib/get_snapshot'

use Rack::Cors do
  allow do
    origins '*'
    resource '*', :headers => :any, :methods => [:get, :options]
  end
end

disable :session
disable :strict_paths

get '/snapshots' do
  page = (params[:page] || 1).to_i
  snapshots = SnapshotsList.call(page)
  meta = snapshots[:meta]
  if meta[:next]
    meta[:next_url] = url("/snapshots?page=#{meta[:next]}")
  end
  if meta[:prev]
    meta[:prev_url] = url("/snapshots?page=#{meta[:prev]}")
  end
  content_type :json
  logger.debug("returning data for page=#{page}: #{snapshots.size} snapshots")
  [200, Yajl::Encoder.encode(snapshots)]
end

get '/latest' do
  snapshot = SnapshotsList.latest_snapshot()
  content_type :json
  send_file(snapshot)
end

get '/snapshots/:timestamp' do
  snapshot_path = GetSnapshot.call(params[:timestamp], logger)
  if snapshot_path.nil?
    logger.info("snapshot #{params[:timestamp]} not found")
    return [404, Yajl::Encoder.encode({error: 'snapshot not found'})]
  end

  content_type:json
  logger.debug("returning data for snapshot #{params[:timestamp]}: #{snapshot_path}")
  send_file(snapshot_path)
end
