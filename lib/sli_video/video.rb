module SliVideo
  class Video
    
    attr_accessor :filepath, :basename, :extname
    
    def initialize(video_filepath)
      if File.exist? video_filepath
        @filepath = video_filepath 
        @extname = File.extname(filepath)
        @basename = File.basename(filepath, extname)
      else
        raise SliVideo::Error
      end 
    end
      
  end
end