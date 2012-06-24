module SliVideo
  module Shipper
    
    # ship processed videos to VidStorage into the proper location
    def self.ship
      ship_path = SliVideo::Config.ship_directory
      Dir.glob(File.join(SliVideo::Config.workflow_directory, 'processed', '*')).each do |file|
        puts file
        extension = File.extname(file)
        basename = File.basename(file, extension)
        last_name = basename.split('-').first
        export_directory = File.join(ship_path, last_name, basename)
        if !File.exists?(export_directory)
          FileUtils.mkdir_p(export_directory)
        end
        # copy to remote directory
        FileUtils.cp(file, File.join(export_directory, basename + extension))
        published_directory_filename = File.join(SliVideo::Config.workflow_directory, 'published', basename + extension)
        FileUtils.mv(file, published_directory_filename)
      end
    end
    
  end
end