require 'thor'
require_relative './utils'

class Webgum < Thor

  class Groq < Thor

    include Utils

    desc "schemas", "List all schema GROQ field definitions"
    def schemas
      config['schemas'].each do |s|
        schema(s['name'])
      end
    end

    desc "schema SCHEMA_NAME", "List all GROQ fields in the specified schema"
    def schema(schema_name)
      s = get_schema(schema_name)
      puts "const #{s['name']}Fields = `"
      puts "  ...,"
      s['fields'].each do |f|
        if f['type'] == 'image' or f['type'] == 'file'
          puts "  \"#{f['name']}Url\": #{f['name']}.asset->url,"
        elsif f['type'] == 'reference'
          puts "  \"#{f['name']}\": #{f['name']}->{"
          f['to'].each do |to_item|
            puts "    _type == '#{ to_item['type'] }' => @{ ${#{ to_item['type'] }Fields} },"
          end
          puts "  },"
        elsif f['type'] == 'array'
          puts "  \"#{f['name']}\": #{f['name']}[]{"
          f['of'].each do |of_item|
            if of_item['type'] == 'reference'
              puts "    _type == 'reference' => @->{"
              of_item['to'].each do |to_item|
                puts "      _type == '#{ to_item['type'] }' => @{ ${#{ to_item['type'] }Fields} },"
              end
              puts "    },"
            else
              puts "    _type == '#{ of_item['type'] }' => @{ ${#{ of_item['type'] }Fields} },"
            end
          end
          puts "  },"
        end
      end
      puts "`;"
      puts
    end

  end
end

