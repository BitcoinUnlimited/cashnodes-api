# Cash Nodes API instance deployment

This doc will describe the step to setup and deploy an instance of cashnodes sinatra API application.
In this doc we are assuming that ruby and all the needed deps needed to run the sinatra in dev mode are already installed (see README.md for more info)
The deployment will use `unicorn` to actually run the `sinatra` app and `nginx` as a front-end to proxy the incoming requests.

## Unicorn

### Install

Install the unicorn gem

    gem install unicorn


### Configure

Set up aux directory need to store log and pid files. From the root path of your installation execute:

    mkdir -p tmp/sockets tmp/pids log

Create unicorn configuration file `unicorn.rb`:

    # set path to app that will be used to configure unicorn,
    # note the trailing slash in this example
    @dir = "/path/to/cashnodes-api/"

    worker_processes 2
    working_directory @dir

    timeout 30

    # Specify path to socket unicorn listens to,
    # we will use this in our nginx.conf later
    listen "#{@dir}tmp/sockets/unicorn.sock", :backlog => 64

    # Set process id path
    pid "#{@dir}tmp/pids/unicorn.pid"

    # Set log file paths
    stderr_path "#{@dir}log/unicorn.stderr.log"
    stdout_path "#{@dir}log/unicorn.stdout.log"

    # env variable
    ENV['REDIS_PASSWORD']='thisismysecretpwd'
    ENV['REDIS_SOCKET']='/path/to/redis/socket.sock'
    ENV['SNAPSHOTS_BASE_DIR']='/path/where/nodes/snapshots/are/stored/'

## Start service at boot time

Instructions in this paragraph are tailored for a machine running a recent version of Ubuntu Linux (>= 16.04)

### Systemd start up script

Create a systemd service file with this path `/lib/systemd/system/cashnodes-api.service` with this content

    [Unit]
    Description=CashNodes API unicorn server
    
    [Service]
    Type=simple
    SyslogIdentifier=unicorn
    User=cashnodes
    PIDFile=/path/where/unicorn/store/its/pid
    WorkingDirectory=/path/to/cashnodes-api
    
    ExecStart=/path/to/unicorn -c /path/to/unicorn.rb -E  production -D
    ExecReload=/bin/kill -s USR2 $MAINPID
    ExecStop=/bin/kill -s QUIT $MAINPID
    
    [Install]
    WantedBy=multi-user.target

Enable the new service file and start the unicorn

    sudo systemctl daemon-reload
    sudo systemctl enable cashnodes-api
    sudo systemctl cashnodes-api start

## Nginx

### Installing

    sudpo apt install nginx

### Configuring

Create a configuration file in `/etc/nginx/sites-available/cashnodes-api` containing:

    # use the socket we configured in our unicorn.rb
    upstream unicorn_server {
      server unix:/path/to/unicorn.sock
          fail_timeout=0;
    }
    
    # configure the virtual host
    server {
      # replace with your domain name
      server_name your_domain.tld;
      # replace this with your static Sinatra app files, root + public
      root /path/to/cashnodes-api/public;
      listen 80;
      client_max_body_size 1M;
      keepalive_timeout 5;
    
      location / {
        try_files $uri @app;
      }
    
      location @app {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        # pass to the upstream unicorn server mentioned above
        proxy_pass http://unicorn_server;
      }
    }

Enable the site configuration

    cd /etc/nginx/site-enabled
    ln -s /etc/nginx/site-available/cashonodes-api

Verify that the configuration is correct

    sudo nginx -t

Restart nginx

    sudo service nginx restart


