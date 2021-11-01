class Formatter
  attr_reader :data, :name, :format_options

  @@default_options = {
    array_nl: "\n",
    object_nl: "\n",
    indent: '  ',
    space_before: ' ',
    space: ' '
  }

  def initialize(name, data, options=@@default_options)
    @name = name
    @data = data
    @format_options = @@default_options
  end

  def sorted_data
    data.sort.to_h
  end

  def write_json
    File.open(" #{name}.json", 'a') do |file|
      file.write (JSON.generate(sorted_data, format_options))
    end 
  end

end