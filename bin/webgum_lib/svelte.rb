require 'thor'
require_relative './utils'

class Webgum < Thor

  class Svelte < Thor

    include Utils

    desc "component SCHEMA_NAME", "Generate a Svelte component"
    def component(schema_name)
      s = get_schema(schema_name)
      puts "<script>"
      puts
      puts "  let {"
      s['fields'].each do |f|
        if f['validations'].is_a?(Array) and f['validations'].include?('required')
          puts "    #{field_name(f)},"
        else
          puts "    #{field_name(f)} = #{field_default(s,f)},"
        end
      end
      puts "  } = $props();"
      puts
      puts "</script>"
      puts
    end

    private

    def field_name(f)
      if f['type'] == 'image' or f['type'] == 'file'
        return "#{f['name']}Url"
      end
      f['name']
    end

    def field_default(s,f)
      if s['defaults'] and s['defaults'][f['name']]
        return s['defaults'][f['name']].inspect
      end
      field_empty_value(f)
    end

    def field_empty_value(f)
      if f['type'] == 'string' or f['type'] == 'text'
        return "''"
      elsif f['type'] == 'number'
        return "0"
      elsif f['type'] == 'boolean'
        return "false"
      elsif f['type'] == 'image' or f['type'] == 'file'
        return "''"
      elsif f['type'] == 'array'
        return "[]"
      elsif f['type'] == 'object'
        return "{}"
      else
        return "null"
      end
    end

  end
end

