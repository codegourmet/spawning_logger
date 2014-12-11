SimpleCov.start do
  coverage_dir "test/coverage"
  command_name "tests"

  use_merging true
  merge_timeout 3600

  add_filter "test/"

  add_group "All", "/lib/*.rb"

  formatter SimpleCov::Formatter::HTMLFormatter
end
