guard :minitest do

  # run all tests when lib main module file changes
  watch(%r{^lib/configuration.rb$}) { "test" }

  # run accompanying test for single source file if it changes
  watch(%r{^lib/(.*)\.rb$}) {|m| "test/#{m[1]}_test.rb" }

  # run test whenever it changes
  watch(%r{^test/(.*)\/?(.*)?_test\.rb$})

end

