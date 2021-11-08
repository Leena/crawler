require 'json'

class Formatter
  attr_accessor :file_drescription, :filename, :data, :options

  JSON_FORMAT_OPTIONS = {
    array_nl: "\n",
    object_nl: "\n",
    indent: '  ',
    space_before: ' ',
    space: ' '
  }.freeze

  def initialize(file_drescription, data)
    @file_drescription = file_drescription
    @data = data
    to_json
  end

  private

  def to_json
    sorted_data = data.sort.to_h
    File.open("#{file_drescription}.json", 'a') do |file|
      file.write(JSON.generate(sorted_data, JSON_FORMAT_OPTIONS))
    end
  end
end
