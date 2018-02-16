# cashnodes HTTP API

HTTP APIs to serve data about Bitcoin Cash nodes.

## Available APIs

### Snpashots list

    GET /snapshots

Returns a list of available snapshots. This API is paginated and you can specify
the page to be returned via the `page` parameter.


### Snapshot data

    GET /snapshot/:timestamp

Return data for nodes in the given snapshot.


## Setup development environment

Install ruby 2.5.0 and bundler

    bin/setup

### Running local server

    ruby cashnodes_api.rb
