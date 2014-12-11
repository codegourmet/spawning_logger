A Logger that is able to spawn sub-loggers.

Sub-loggers are created with a different filename.
Also supports a preset logfile subdirectory in case you create many subloggers.

Only the constructor is modified and the spawning factory method added,
everything else is delegated to the ruby stdlib ::Logger class.

## Examples:

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
