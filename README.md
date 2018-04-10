# cashnodes HTTP API

HTTP APIs to serve data about Bitcoin Cash nodes.

[![Build Status](https://travis-ci.org/BitcoinUnlimited/cashnodes-api.svg?branch=master)](https://travis-ci.org/BitcoinUnlimited/cashnodes-api)

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


### Running tests

    rake test

## Environment variables

- SNAPSHOTS_BASE_DIR: the base dir where snapshots will be found

- Redis configuration: use either one of the two possible env vars

  + REDIS_URL 

  + REDIS_SOCKET and REDIS_PASSWORD
