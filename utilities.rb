module Utilities
  def get_file_contents(filename)
    contents = ""
    file_in = File.new(filename, "r")
    file_in.each_line do |line|
      contents += line
    end
    file_in.close
    contents
  end
  
  def write_file(filename, content)
    file_out = File.new(filename, "w")
    file_out.write(content)
    file_out.close
  end
end