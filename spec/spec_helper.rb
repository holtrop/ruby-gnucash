require "simplecov"

SimpleCov.start do
  minimum_coverage 100
  add_filter "/.bundle/"
  add_filter "/spec/"
end

require "gnucash"
