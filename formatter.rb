require "json"

class Formatter
  attr_accessor :file_drescription, :filename, :data, :options

  @@JSON_format_options = {
    array_nl: "\n",
    object_nl: "\n",
    indent: '  ',
    space_before: ' ',
    space: ' '
  }

  def initialize(file_drescription, data, options=@@JSON_format_options)
    @file_drescription = file_drescription
    @data = data
    @options = options
    to_json
  end

  private
  
  def to_json
    # expecting input as Hash {}
    sorted_data = data.sort.to_h

    File.open("#{file_drescription}.json", 'a') do |file|
      file.write (JSON.generate(sorted_data, options))
    end 
  end
end