#!/usr/bin/env ruby
require 'utilities'

include Utilities

# Usage: imr <filename.html>
if ARGV.count != 5
  puts "Usage: ./imr.rb <filename> <original_width> <original_height> <new_width> <new_height>"
  exit
end

# Set variables from arguments
filename_in = ARGV[0]
original_width = ARGV[1]
original_height = ARGV[2]
new_width = ARGV[3]
new_height = ARGV[4]

# Debug what we're doing
puts "Converting image map coords from #{original_width}x#{original_height} to #{new_width}x#{new_height}..."

# Read input file
html_in = get_file_contents(filename_in)

# Get all COORD sets
original_coord_strings = [] # store full coord="1,2,3,4" string
original_coord_data = [] # store raw data: [1, 2, 3, 4]
last_coord_ended_at = 0
while !last_coord_ended_at.nil? do
  last_coord_ended_at = html_in.index(/(coords=\"\d+\,\d+\,\d+\,\d+\")/i, last_coord_ended_at)
  if last_coord_ended_at
    last_coord_ended_at += $1.size
    original_coord_strings << $1
    original_coord_data << $1.gsub(/coords=\"(\d+\,\d+\,\d+\,\d+)\"/i, '\1').split(',').map{|x| x.to_i}
  end
end

# Calculate transform scale
x_scale_factor = new_width.to_f / original_width.to_f
y_scale_factor = new_height.to_f / original_height.to_f

puts "Scaling width to #{(x_scale_factor * 100).round}%"
puts "Scaling height to #{(y_scale_factor * 100).round}%"

new_coord_data = []
# Transform the COORD sets
original_coord_data.each_with_index do |coord_set, i|
  new_coord_data << [
    (coord_set[0] * x_scale_factor).round,
    (coord_set[1] * y_scale_factor).round,
    (coord_set[2] * x_scale_factor).round,
    (coord_set[3] * y_scale_factor).round
  ]
end

# Generate real strings from new coordinate data
new_coord_strings = []
new_coord_data.each do |coord_set|
  new_coord_strings << "coords=\"#{coord_set[0]},#{coord_set[1]},#{coord_set[2]},#{coord_set[3]}\""
end

# Replace old coord strings with new one
html_out = html_in.dup
original_coord_data.each_with_index do |original_coord_set, i|
  html_out.gsub!(/coords=\"#{Regexp.escape(original_coord_set[0].to_s)}\,#{Regexp.escape(original_coord_set[1].to_s)}\,#{Regexp.escape(original_coord_set[2].to_s)}\,#{Regexp.escape(original_coord_set[3].to_s)}\"/i, "coordsMODIFIED=\"#{new_coord_data[i][0]},#{new_coord_data[i][1]},#{new_coord_data[i][2]},#{new_coord_data[i][3]}\"")
end

# Remove "MODIFIED" from coords
html_out.gsub!("coordsMODIFIED", "coords")

# Write HTML!
write_file("#{filename_in}.resized.html", html_out)

# Disclaimers
puts "RECT coords converted; CIRCLE and POLY coords are not yet supported."
puts "You must change the WIDTH of your image to #{new_width} and the HEIGHT to #{new_height} in #{filename_in}.resized.html."