module SliVideo
  module Config
    # we don't want to instantiate this class - it's a singleton,
    # so just keep it as a self-extended module
    extend self
    
    attr_accessor :workflow_directory, :ship_directory, :width, :verbose

  end
end