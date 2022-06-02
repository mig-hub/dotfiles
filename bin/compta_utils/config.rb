require 'yaml'
require_relative '../ruby_utils/string_color'
require_relative '../ruby_utils/prompt_methods'

module Compta

  include PromptMethods

  def compta_init
    $compta_dir = Dir.getwd
    $compta_config = YAML.load_file 'compta.yml'
    $compta_return = 'DONE'
    puts "Aloha #{ $compta_config[:first_name].blue } !\nWelcome to Compta."
  end

  def create_config
    conf = {}
    printf 'First name: '
    conf[:first_name] = STDIN.gets.chomp
    printf 'Last name: '
    conf[:last_name] = STDIN.gets.chomp
    printf 'Hourly rate (default 70): '
    conf[:hourly_rate] = STDIN.gets.chomp
  end

  def confirm_structure
    if confirm "Would you like to create the directory structure?"
      ensure_structure
    end
  end

  DIRECTORIES = [
    'proposals',
    'invoices',
    'book-entries',
  ].freeze

  def ensure_structure
    DIRECTORIES.each do |d|
      puts "Making sure there is a #{ d } directory..."
      FileUtils.mkdir_p d
    end
  end

end
