#!/usr/bin/env ruby

# sli_video.rb
# Given the path to a directory of videos, process each video

lib = File.expand_path(File.dirname(__FILE__) + '/../lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib) && !$LOAD_PATH.include?(lib)
require 'sli_video'
require 'slop'

opts = Slop.parse do
  banner "sli_video.rb --workflow /path/to/workflow_directory --ship /path/to/ship_directory [options]\n
--workflow is a required option.\n"
  on :w, :workflow=, 'Path to the Workflow Directory.', true
  on :s, :ship=, 'Directory to ship the resulting files to.', true
  on :i, :width=, 'Width of derivatives'
  # on :e, :endcap, 'Add an endscreen.mpg file to the end'
  on :t, :ship_only, 'Only ship files that are processed. Do not process new files.'
  on :r, :verbose, 'Enable verbose mode'
  on :v, :version, 'Print the version' do
    puts "sli_video version: #{SliVideo::VERSION}"
    exit
  end
end

if !opts[:workflow]
  puts opts.help
  exit
end

SliVideo::Config.workflow_directory = opts[:workflow]

if !opts[:ship_only]
  if opts.width?
    SliVideo::Config.width = opts[:width]
  else
    SliVideo::Config.width = '480'
  end
  puts "Width: #{SliVideo::Config.width}" if opts.verbose?

  
  SliVideo::Config.verbose = opts[:verbose]
  puts "Workflow Directory: #{SliVideo::Config.workflow_directory}" if opts.verbose?
  Dir.glob(File.join(SliVideo::Config.workflow_directory, 'to-process', '*mp4')).each do |video_path|
    puts video_path if opts.verbose?
    video = SliVideo::Video.new(video_path)
    processor = SliVideo::Processor.new(video)
    processor.process
  end
end

if opts[:ship]
  SliVideo::Config.ship_directory = opts[:ship]
  puts "Directory to ship processed files: #{SliVideo::Config.ship_directory}" if opts.verbose?
  SliVideo::Shipper.ship
else
  puts "Videos processed but not shipped."
end