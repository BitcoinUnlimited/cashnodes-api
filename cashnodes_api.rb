require 'bundler/setup'
require 'yajl'
require 'redis'
require 'hiredis'
require 'sinatra'

redis_conn = Redis.new(url: ENV['REDIS_URL'], driver: :hiredis)

get '/snapshots' do
  page = params[:page] || 1
  snapshots = SnapshotsList.call(redis_conn, page)
  content_type :json
  logger.debug("returning data for page=#{page}: #{snapshots.size} snapshots")
  [200, Yajl::Encoder.encode(snapshots)]
end

get '/snapshots/:timestamp' do
  snapshot_path = GetSnapshot.call(params[:timestamp])
  if snapshot_path.nil?
    logger.info("snapshot #{timestamp} not found")
    return [404, Yajl::Encoder.encode({error: 'snapshot not found'})]
  end

  content_type:json
  logger.debug("returning data for snapshot #{params[:timestamp]}: #{snapshot_path}")
  send_file(snapshot_path)
end
