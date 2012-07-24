module SliVideo
  class Processor
    
    # height and width are the values for the converted final version. They are used to help match up with the correct
    # end screen.
    attr_accessor :video, :height, :width
    
    def initialize(video)
      @video = video
    end
    
    def process
      move_original_to_processing
      puts "===============done: move_original_to_processing" if verbose?

      to_mp4_tmp
      puts "===============done: to_mp4_tmp" if verbose?

      determine_height_and_width
      puts "===============done: determine_height_and_width #{height}x#{width}" if verbose?

      add_endcap_to_mp4
      puts "===============done: add_endcap_to_mp4" if verbose?

      process_good_mp4
      puts "===============done: process_good_mp4" if verbose?

      to_webm
      puts "===============done: to_webm" if verbose?

      FileUtils.rm tmp2_mp4_output_filename
      puts "===============done: FileUtils.rm tmp2_mp4_output_filename" if verbose?

      create_poster_image
      puts "===============done: create_poster_image" if verbose?

      original_to_processed_original
    end
    
    def create_poster_image
      `ffmpeg -i "#{mp4_output_filename}" -vcodec png -vframes 1 "#{File.join(output_directory, video.basename + '.png')}"`
    end
    
    def move_original_to_processing
      FileUtils.mv(video.filepath, processing_filename)
    end
    
    # if we are going to add an endcap, then convert to an mpg first so that we can just use cat
    def add_endcap_to_mp4
      `ffmpeg -i "#{tmp_mp4_output_filename}" -sameq "#{tmp_file_number(1)}"`
      `cat "#{tmp_file_number(1)}" "#{endcap_filename}" | ffmpeg -f mpeg -i - -sameq -vcodec mpeg4 "#{tmp2_mp4_output_filename}"`
      FileUtils.rm tmp_file_number(1)
      FileUtils.rm tmp_mp4_output_filename
      # tmp2_mp4_output_filename isn't removed because we still need it around
    end
    
    def process_good_mp4
      run_handbrake(tmp2_mp4_output_filename, mp4_output_filename, '20')      
    end
    def run_handbrake(input, output, quality)
      # The version used is basically the "iPhone & iPod Touch" preset except expanded to allow us to use our own width setting
      # `HandBrakeCLI --preset "iPhone & iPod Touch" --width #{SliVideo::Config.width} --vb 600 --two-pass --turbo --optimize --input "#{input}" --output "#{output}"`
      `HandBrakeCLI -i "#{input}" -o "#{output}" -e x264 -q #{quality} -a 1 -E faac -B 128 -6 dpl2 -R Auto -D 0.0 -f mp4 -X #{SliVideo::Config.width} -m -x cabac=0:ref=2:me=umh:bframes=0:weightp=0:subme=6:8x8dct=0:trellis=0 --vb 600 --two-pass --turbo --optimize`
    end
    def to_mp4_tmp
      run_handbrake(processing_filename, tmp_mp4_output_filename, '0')
    end
    def tmp_mp4_output_filename
      File.join(tmp_directory, video.basename + '_tmp.mp4')
    end
    def tmp2_mp4_output_filename
      File.join(tmp_directory, video.basename + '_tmp2.mp4')
    end
    def mp4_output_filename
      output_filename('.mp4')
    end
    
    def to_webm
      `ffmpeg -quality good -qmin 10 -qmax 51 -i "#{tmp2_mp4_output_filename}" "#{webm_output_filename}"`
    end
    def webm_output_filename
      output_filename('.webm')
    end
    
    def output_filename(extension)
      File.join(output_directory, video.basename + extension)
    end
    
    def processed_original_directory
      File.join(workflow_directory, "processed_original")
    end
    def processed_original_filename
      File.join(processed_original_directory, video.basename + video.extname)
    end
    def processed_filename
      File.join(processed_original_directory, video.basename + video.extname)
    end
    
    def output_directory
      File.join(workflow_directory, "processed")
    end
    
    def processing_directory
      File.join(workflow_directory, "processing")
    end
    def processing_filename
      File.join(processing_directory, video.basename + video.extname)
    end
    
    def tmp_directory
      File.join(workflow_directory, 'tmp')
    end
    def tmp_file_number(number)
      File.join(tmp_directory, "#{number}.mpg")
    end
    
    def endcap_filename
      File.join(workflow_directory, "endscreen-#{height}x#{width}.mpg")
    end
    
    def workflow_directory
      SliVideo::Config.workflow_directory
    end

    def verbose?
      SliVideo::Config.verbose
    end
    
    def original_to_processed_original
      FileUtils.mv(processing_filename, processed_original_filename)
    end

    def determine_height_and_width      
      height_and_width_command = %Q{mediainfo --Inform="Video;%Width%x%Height%" "#{tmp_mp4_output_filename}"}
      puts height_and_width_command if verbose?
      height_and_width = `#{height_and_width_command}`.chomp
      puts height_and_width.inspect if verbose?
      @height, @width = height_and_width.split('x') 
    end
    
  end
end