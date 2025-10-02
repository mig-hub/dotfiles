require 'yaml'

module Utils

  private

  def config
    # Returns the configuration hash, loading it from the YAML file if necessary.
    return @config if @config
    @config = {}
    config = YAML.load_file(options[:config]) if File.exist?(options[:config])
    if config.nil? || !config.is_a?(Hash)
      raise "Missing or invalid configuration file: webgum.yml"
    end
    if config.key?('includes') && config['includes'].is_a?(Array)
      config['includes'].each do |include_file|
        include_config = YAML.load_file(include_file)
        @config.merge!(include_config) if include_config.is_a?(Hash)
      end
    end
    @config.merge!(config)
  end

  def get_schema(schema_name)
    # Since each module method is supposed to work independantly, they all need
    # to be able to take schema names and field names as arguments. But if a
    # method already has these objects, they can send them in directly. So if
    # the argument is a string, we look it up, otherwise we assume it's already
    # the object we want. And an exception is raised if the name is not found.
    return schema_name unless schema_name.is_a?(String)
    schema = config['schemas'].find { |s| s['name'] == schema_name }
    if schema.nil?
      raise "Schema '#{schema_name}' not found."
    end
    schema
  end

  def get_field(schema_name, field_name)
    # Since each module method is supposed to work independantly, they all need
    # to be able to take schema names and field names as arguments. But if a
    # method already has these objects, they can send them in directly. So if
    # the argument is a string, we look it up, otherwise we assume it's already
    # the object we want. And an exception is raised if the name is not found.
    return field_name unless field_name.is_a?(String)
    schema = get_schema(schema_name)
    field = schema['fields'].find { |f| f['name'] == field_name }
    if field.nil?
      raise "Field '#{field_name}' not found in schema '#{schema_name}'."
    end
    field
  end

  def label_for(name)
    # Convert camelCase or PascalCase to "Camel Case" or "Pascal Case"
    atoms = name.split(/(?=[A-Z])/).map(&:downcase)
    atoms.map(&:capitalize).join(' ')
  end

  def confirm( prompt )
    # Ask the user a yes/no question and return true for 'y' and false for 'n'
    print "#{ prompt } [y/n] : "
    yn = STDIN.gets.chomp
    return yn.downcase == 'y'
  end

  def stdout_to( path )
    # Momentarily redirects stdout to a file at the given path for the duration
    # of the provided block. If the file already exists, the user is prompted
    # to confirm overwriting it.
    original_stdout = $stdout
    if !File.exist?(path) or confirm("File #{path} exists. Overwrite?")
      File.open(path, 'w') do |file|
        $stdout = file
        yield
      end
    end
  ensure
    $stdout = original_stdout
  end

  def javascript_object obj, indent=0
    # Convert a Ruby hash to a JavaScript object literal string
    # hash.to_json.gsub(/"([a-zA-Z0-9]+)":/, ' \1: ')
    space = '  ' * indent
    case obj
    when Hash
      items = obj.map do |k, v|
        "#{space}  #{k}: #{javascript_object(v, indent + 1)}"
      end
      if items.size == 1
        "{ #{items[0].strip} },"
      else
        "{\n#{items.join(",\n")}\n#{space}},"
      end
    when Array
      items = obj.map do |v|
        "#{space}  #{javascript_object(v, indent + 1)}"
      end
      if items.size == 0
        "[],"
      else
        "[\n#{items.join(",\n")}\n#{space}],"
      end
    when String
      "'#{obj.gsub("'", "\\'")}'"
    else
      obj.to_s
    end
  end

end
