#!/usr/bin/env ruby

# sli_video_setup.rb
# Given a base video-workflow directory create the other necessary directories.

lib = File.expand_path(File.dirname(__FILE__) + '/../lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib) && !$LOAD_PATH.include?(lib)
require 'sli_video'

base_directory = ARGV[0] || (puts "Must give a base workflow directory"; exit)
full_base_directory = File.expand_path(base_directory)
['to-process', 'processing', 'processed_original', 'processed', 'published', 'tmp'].each do |directory_name|
  new_directory = File.join(full_base_directory, directory_name)
  FileUtils.mkdir(new_directory) if !File.exist?(new_directory)
end