require "json"

class Formatter
  attr_reader :file_drescription, :filename, :data, :options

  @@JSON_format_options = {
    array_nl: "\n",
    object_nl: "\n",
    indent: '  ',
    space_before: ' ',
    space: ' '
  }

  def initialize(file_drescription, filename, data, options=@@JSON_format_options)
    @file_drescription = file_drescription
    @filename = filename
    @data = data
    @options = options
  end

  def to_json
    # expecting input as Hash {}
    sorted_data = data.sort.to_h

    File.open("#{file_drescription} #{filename}.json", 'a') do |file|
      file.write (JSON.generate(sorted_data, options ))
    end 
  end

end