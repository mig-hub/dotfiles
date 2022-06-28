require_relative 'helpers'

module Compta

  include PromptMethods

  def compta_init
    $compta_dir = Dir.getwd
    $compta_config = YAML.load_file 'compta.yml'
    $compta_return = 'DONE'
    puts "Aloha #{ $compta_config[:first_name].blue } !\nWelcome to Compta."
  end

  def collect_clients
    clients = []
    Dir['invoices/*.yml'].each do |file|
      doc = YAML.load_file file
      current_client = {
        client_name: doc[:client_name],
        client_details: doc[:client_details],
      }
      unless clients.include? current_client
        clients << current_client
      end
    end
    $compta_config[:clients] = clients
    if confirm "Would you like to write clients in config"
      File.open("compta.yml", "r+") do |file|
        file.write($compta_config.to_yaml)
      end
      puts "Clients where added to compta.yml config file.".green
    end
    $compta_return
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
