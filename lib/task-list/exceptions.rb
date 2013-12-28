module TaskList
  module Exceptions
  end
end

Dir[File.dirname(__FILE__) + "/exceptions/*.rb"].each do |file|
  require file
end
