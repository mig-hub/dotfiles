require 'thor'
require_relative './utils'

class Compta < Thor

  desc :default_item, "Print a default item"
  def default_item
    puts "  - :description: Item description"
    puts "    :price: 8000"
  end

  desc :default_long_item, "Print a default item with long description"
  def default_long_item
    puts "  - :description: |-"
    puts "      Item description on several lines"
    puts "    :price: 64000"
  end

end

