# SpawningLogger

A Logger that is able to spawn sub-loggers.

## General

Example use case: you run a server and want to log different clients each into their own logfile (for example if you got a huge amount of clients connecting).

This logger can spawn sub-loggers with different files, each of those file's name is derived from the main logger's file and the sub-logger's id.

Also supports a preset logfile subdirectory in case you create many subloggers (for example you might be interested in splitting development, production, test logs into subdirectories).

Only the constructor is modified and the spawning factory method added, everything else is delegated to the ruby stdlib ::Logger class.

## Examples:

### quick-n-dirty:
```ruby
require 'spawning_logger'
logger = SpawningLogger.new('server.log')

logger.info('special test message')
logger.spawn('special').info('special test message')

# => writes message into ./server.log and ./server_special.log
```

### 1) usage same as ::Logger

```ruby
logger = SpawningLogger.new('server.log')

# => creates ./server.log
```

### 2) spawn child logger

```ruby
logger = SpawningLogger.new('server.log')
child_logger = logger.spawn('worker1')

# => creates ./server_worker1.log
# => returns a ::Logger instance logging into this file
```

### 3) spawn child logger with prefix

```ruby
SpawningLogger.configure do |config|
  config.child_prefix = 'worker'
end

logger = SpawningLogger.new('server.log')
child_logger = logger.spawn('1')

# => creates ./server_worker_1.log
# => returns a ::Logger instance logging into this file
```

### 4) create all logfiles inside subdir, injected into original path

```ruby
SpawningLogger.configure do |config|
  config.subdir = 'production'
end

logger = SpawningLogger.new('log/server.log')
child_logger = logger.spawn('1')

# => creates ./log/production/server.log
# => creates ./log/production/server_worker_1.log
```
