require_relative "./test_helper"
require_relative "../lib/spawning_logger"

class SpawningLoggerTest < MiniTest::Test

  def setup
    @log_base_dir = Dir.mktmpdir('spawning_logger_test')
    @log_dir = File.join(@log_base_dir, 'test_subdir')

    @logfile_name = 'test_file.log'
    @logfile_path = File.join(@log_base_dir, @logfile_name)
    @child_id = 'childid'

    reset_logger_config
  end

  def teardown
    FileUtils.remove_entry(@log_base_dir)
    reset_logger_config
  end

  def test_creates_subdir_if_doesnt_exist
    subdir = 'development'

    SpawningLogger.configure do |config|
      config.subdir = subdir
    end
    SpawningLogger.new(@logfile_path, true)

    expected_dir = File.join(@log_base_dir, subdir)
    expected_file = File.join(expected_dir, @logfile_name)

    assert File.exist?(expected_file)
    assert Dir.exist?(expected_dir)
  end

  def test_spawn_interface_yields_logger_for_child_id
    logger = SpawningLogger.new(@logfile_path)
    logger.spawn('childid')
    assert_creates_log_file('test_file_childid.log')
  end

  def test_child_logger_filename_includes_child_prefix
    SpawningLogger.configure do |config|
      config.child_prefix = 'childprefix'
    end

    logger = SpawningLogger.new(@logfile_path)
    logger.spawn('childid')

    assert_creates_log_file('test_file_childprefix_childid.log')
  end

  def test_raises_if_child_id_is_nil_or_empty
    logger = SpawningLogger.new(@logfile_path)

    assert_raises SpawningLogger::ArgumentError do
      logger.spawn(nil)
    end
  end

  def test_self_and_spawn_calls_both
    logger = SpawningLogger.new(@logfile_path)
    logger.self_and_spawn("childid", :error, "test_self_and_spawn_calls_both")

    parent_path = File.join(@log_dir, @logfile_name)
    child_path = File.join(@log_dir, 'test_file_childid.log')

    [parent_path, child_path].each do |path|
      result = File.read(path)
      assert_match(/test_self_and_spawn_calls_both/, result)
    end
  end

  def test_child_loggers_can_spawn_their_own_child_loggers
    child = SpawningLogger.new(@logfile_path).spawn('child1')
    sub_child = child.spawn('child2')

    assert_kind_of(::Logger, sub_child)
    assert File.exist?(File.join(@log_dir, 'test_file_child1_child2.log'))
  end

  def test_creates_child_logger_only_once
    skip "NYI"
    # TODO
    #   expect ::Logger.new(child_path) to be called only once
    #   spawn child logger 2x
  end

  protected

    def assert_creates_log_file(file_name)
      expected_path = File.join(@log_dir, file_name)
      assert File.exist?(expected_path)
    end

    def reset_logger_config
      SpawningLogger.configure do |config|
        config.child_prefix = nil
        config.subdir = 'test_subdir'
      end
    end

end
