require 'bundler/setup'
require 'yajl'
require 'redis'
require 'hiredis'
require 'sinatra'

require_relative 'lib/snapshots_list'
require_relative 'lib/get_snapshot'

redis_conn_params = {driver: :hiredis}
if ENV['REDIS_SOCKET']
  if !File.socket?(ENV['REDIS_SOCKET'])
    raise StandardError('Mis-configured REDIS_SOCKET env var')
  end
  redis_conn_params[:password] = ENV['REDIS_PASSWORD'] if ENV['REDIS_PASSWORD']
  redis_conn_params[:path] = ENV['REDIS_URL']
elsif ENV['REDIS_URL']
  redis_conn_params[:url] = ENV['REDIS_URL']
end
redis_conn = Redis.new(redis_conn_params)

get '/snapshots' do
  page = (params[:page] || 1).to_i
  snapshots = SnapshotsList.call(redis_conn, page)
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

get '/snapshots/:timestamp' do
  snapshot_path = GetSnapshot.call(params[:timestamp])
  if snapshot_path.nil?
    logger.info("snapshot #{params[:timestamp]} not found")
    return [404, Yajl::Encoder.encode({error: 'snapshot not found'})]
  end

  content_type:json
  logger.debug("returning data for snapshot #{params[:timestamp]}: #{snapshot_path}")
  send_file(snapshot_path)
end
