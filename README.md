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

WARNING: tests will connect to configure redis and flush its content.

    SNAPSHOTS_BASE_DIR=./tests/fixtures rake test

## Environment variables

- SNAPSHOTS_BASE_DIR: the base dir where snapshots will be found

- REDIS_URL: specify the Redis connection settings
