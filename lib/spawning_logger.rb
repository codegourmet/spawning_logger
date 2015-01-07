# A Logger that is able to spawn sub-loggers.
#
# Sub-loggers are created with a different filename.
# Also supports a preset logfile subdirectory in case you create many subloggers.
#
# Only the constructor is modified and the spawning factory method added,
# everything else is delegated to the ruby stdlib ::Logger class.
#
# ## Examples:
#
# ### 1) usage same as ::Logger
#
# ```ruby
# logger = SpawningLogger.new('server.log')
#
# # => creates ./server.log
# ```
#
# ### 2) spawn child logger
#
# ```ruby
# logger = SpawningLogger.new('server.log')
# child_logger = logger.spawn('worker1')
#
# # => creates ./server_worker1.log
# # => returns a ::Logger instance logging into this file
# ```
#
# ### 3) spawn child logger with prefix
#
# ```ruby
# SpawningLogger.configure do |config|
#   config.child_prefix = 'worker'
# end
#
# logger = SpawningLogger.new('server.log')
# child_logger = logger.spawn('1')
#
# # => creates ./server_worker_1.log
# # => returns a ::Logger instance logging into this file
# ```
#
# ### 4) create all logfiles inside subdir, injected into original path
#
# ```ruby
# SpawningLogger.configure do |config|
#   config.subdir = 'production'
# end
#
# logger = SpawningLogger.new('log/server.log')
# child_logger = logger.spawn('1')
#
# # => creates ./log/production/server.log
# # => creates ./log/production/server_worker_1.log
# ```
#
#
# ### 5) log into main logfile and into a child logger's logfile
#
# ```ruby
# logger = SpawningLogger.new('log/server.log')
# logger.self_and_spawn('worker_1', :error, 'server shutdown')
#
# # this is a shortcut for:
# logger.error('server shutdown')
# logger.spawn('worker_1').error('server shutdown')
#
# # => "server shutdown" will show up in server.log and in server_worker_1.log
# ```
#
#
# ### 6) logger spawning recursion
#
# ```ruby
# logger = SpawningLogger.new('log/server.log')
# child = logger.spawn('child1')
# sub_child = child.spawn('child2')
#
# # => creates ./log/production/server.log
# # => creates ./log/production/server_child1.log
# # => creates ./log/production/server_child1_child2.log
# ```

require 'logger'

class SpawningLogger < ::Logger

  class ArgumentError < ::ArgumentError; end

  # cattr_accessor :child_prefix
  # cattr_accessor :subdir

  @@child_prefix = nil
  @@subdir = nil

  def self.configure
    yield self
  end

  def self.child_prefix=(value)
    @@child_prefix = value
  end

  def self.subdir=(value)
    @@subdir = value
  end

  # creates the logfile inside a subdir (optional).
  def initialize(file_path, subdir = nil)
    file_path = File.expand_path(file_path)

    @log_dir = File.dirname(file_path)
    @log_dir = File.join(@log_dir, @@subdir) unless @@subdir.nil?
    FileUtils.mkdir_p(@log_dir) if !Dir.exist?(@log_dir)

    @file_name = File.basename(file_path)
    @child_loggers = {} # these are the special sub-loggers

    super(File.join(@log_dir, @file_name)) # this creates the main logger
  end

  # creates a sub logger with filename <orig_file>_<child_prefix>_<child_name>.log
  # example: see class docstring or README.md
  def spawn(child_name)
    raise ArgumentError.new("empty child_name") if child_name.to_s.empty?

    @child_loggers[child_name] ||= create_child_logger(child_name)
    @child_loggers[child_name]
  end

  # logs into the main logfile and also logs into a spawned logfile.
  # @param child_name the child to spawn and log into
  # @param method the method name to call, like :error, :info, :debug, ...
  # @param message the message to send to both loggers
  def self_and_spawn(child_name, method, message)
    self.send(method, message)
    self.spawn(child_name).send(method, message)
  end

  protected

    # creates a logger for child_name. uses child_name and
    # child_prefix (if configured) for construction of the new logger's filename.
    #
    # example:
    #   origfile.log => origfile_childprefix_childname.log
    #
    def create_child_logger(child_name)
      # remove extension
      parent_filename = File.basename(@file_name, File.extname(@file_name))

      # add child_prefix + child_id
      file_basename = [
        parent_filename, @@child_prefix, child_name
      ].compact.join('_')

      # add extension
      file_name = file_basename + File.extname(@file_name)

      file_path = File.join(@log_dir, file_name)
      self.class.new(file_path)
    end

end
