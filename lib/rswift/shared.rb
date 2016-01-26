Dir.glob(File.expand_path('shared/tasks/*.rake', File.dirname(__FILE__))).each { |r| load r}

module RSwift
  module Shared
  end
end
