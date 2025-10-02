require 'thor'
require_relative './utils'

class Webgum < Thor

  class Sanity < Thor

    include Utils

    desc :all, "Generate all schema types and index"
    def all
      stdout_to('./schemaTypes/index.ts') do
        index
      end
      config['schemas'].each do |s|
        stdout_to("./schemaTypes/#{s['name']}.ts") do
          schema(s['name'])
        end
      end
    end

    desc :index, "Print index.ts importing all schemas"
    def index
      config['schemas'].each do |s|
        puts "import #{ s['name'] } from './#{ s['name'] }'"
      end
      puts
      puts "export const schemaTypes = ["
      config['schemas'].each do |s|
        puts "  #{ s['name'] },"
      end
      puts "]"
    end

    desc "schema SCHEMA_NAME", "Print a schema definition"
    def schema schema_name
      s = get_schema(schema_name)
      label = s.fetch( s['label'], label_for( s['name'] ) )
      puts "export default {"
      puts "  title: '#{ label }',"
      puts "  name: '#{ s['name'] }',"
      puts "  type: '#{ s['type'] || 'document' }',"
      fields(s)
      schema_defaults(s)
      preview(s)
      puts "}"
    end

    desc "fields SCHEMA_NAME", "Print fields array for a schema"
    def fields schema_name
      s = get_schema(schema_name)
      puts "  fields: ["
      s['fields'].each do |f|
        field(s, f)
      end
      puts "  ],"
    end

    desc "field SCHEMA_NAME FIELD_NAME", "Print a field definition"
    def field schema_name, field_name
      s = get_schema(schema_name)
      f = get_field(schema_name, field_name)
      label = f.fetch( 'label', label_for( f['name'] ) )
      puts "    {"
      puts "      title: '#{ label }',"
      puts "      name: '#{ f['name'] }',"
      puts "      type: '#{ f['type'] || 'string' }',"
      reference_to(s, f)
      array_of(s, f)
      opts(s, f)
      validations(s, f)
      puts "    },"
    end

    desc "reference_to SCHEMA_NAME FIELD_NAME", "Print 'to' for a reference field"
    def reference_to schema_name, field_name
      f = get_field(schema_name, field_name)
      if f['type'] == 'reference' && f.key?('to') && f['to'].is_a?(Array)
        puts "      to: ["
        ref_list(f['to'])
        puts "      ],"
      end
    end

    desc "array_of SCHEMA_NAME FIELD_NAME", "Print 'of' for an array field"
    def array_of schema_name, field_name
      f = get_field(schema_name, field_name)
      if f['type'] == 'array' && f.key?('of') && f['of'].is_a?(Array)
        puts "      of: ["
        ref_list(f['of'])
        puts "      ],"
      end
    end

    desc "opts SCHEMA_NAME FIELD_NAME", "Print options for a field"
    def opts schema_name, field_name
      s = get_schema(schema_name)
      f = get_field(schema_name, field_name)
      if f.key?('options') && f['options'].is_a?(Hash)
        puts "      options: {"
        opts_list( s, f )
        puts "      },"
      end
    end

    desc "opts_list SCHEMA_NAME FIELD_NAME", "Print options list for a field"
    def opts_list schema_name, field_name
      f = get_field(schema_name, field_name)
      if f.key?('options') && f['options'].is_a?(Hash) && f['options'].key?('list') && f['options']['list'].is_a?(Array)
        puts "        list: ["
        f['options']['list'].each do |item|
          if item.is_a?(String)
            puts "          { title: '#{ item }', value: '#{ item }' },"
          elsif item.is_a?(Hash)
            puts "          { title: '#{ item['label'] || item['title'] }', value: '#{ item['value'] }' },"
          end
        end
        puts "        ],"
      end
    end

    desc "validations SCHEMA_NAME FIELD_NAME", "Print validations for a field"
    def validations schema_name, field_name
      f = get_field(schema_name, field_name)
      if f.key?('validations') && f['validations'].is_a?(Array)
        out = "      validation: (Rule) => Rule"
        f['validations'].each do |validation|
          if validation.is_a?(String)
            out << ".#{ validation }"
            if validation !~ /\(.*\)$/
              out << "()"
            end
          end
        end
        out << ","
        puts out
      end
    end

    desc "schema_defaults SCHEMA_NAME", "Print initialValue for a schema"
    def schema_defaults schema_name
      s = get_schema(schema_name)
      if s.key?('defaults') && s['defaults'].is_a?(Hash)
        puts "  initialValue: {"
        s['defaults'].each do |key, value|
          if value.is_a?(String)
            puts "    #{ key }: '#{ value }',"
          else
            puts "    #{ key }: #{ value },"
          end
        end
        puts "  },"
      end
    end

    desc "preview SCHEMA_NAME", "Print preview block for a schema"
    def preview schema_name
      s = get_schema(schema_name)
      if s.key?('preview') && s['preview'].is_a?(Hash)
        puts "  preview: {"
        if s['preview'].key?('select') && s['preview']['select'].is_a?(Hash)
          puts "    select: {"
          s['preview']['select'].each do |key, value|
            puts "      #{ key == 'thumbnail' ? 'media' : key }: '#{ value }',"
          end
          puts "    },"
        end
        if s['preview'].key?('prepare') && s['preview']['prepare'].is_a?(String)
          puts "    prepare(selection) {"
          puts "      const { #{ s['preview']['select'].keys.join(', ')} } = selection"
          puts "      return {"
          # puts "        title: #{ schema['preview']['prepare'] },"
          puts "      }"
          puts "    },"
        end
        puts "  },"
      end
    end

    private

    def ref_list( items )
      items.each do |item|
        if item.is_a?(String)
          puts "        { type: '#{ item }' },"
        elsif item.is_a?(Hash)
          puts "        #{ javascript_object(item, 4) }"
        end
      end
    end

  end

end
