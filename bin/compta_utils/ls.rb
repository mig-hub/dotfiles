require 'yaml'
require_relative 'helpers'

module Compta

  def ls_book_entries
    current_quarter = nil
    quarter_total = 0
    Dir[ "book-entries/*.yml" ].sort.each do |file|
      doc = YAML.load_file file
      quarter = quarter_for_date doc[:payment_date]
      if current_quarter and quarter != current_quarter
        print_quarter_summary current_quarter, quarter_total
        quarter_total = 0
      end
      print_book_entry doc
      current_quarter = quarter
      quarter_total += doc[:amount]
    end
    print_quarter_summary current_quarter, quarter_total
    $compta_return
  end

  private

  def print_book_entry doc
    print doc[:payment_date]
    print '  '
    print price_to_string( doc[:amount] ).rjust(8)
    print '  '
    print truncate( doc[:client_name], 24 )
    print '  '
    print truncate( doc[:transaction_reference], 48 )
    puts
  end

  def print_quarter_summary name, amount
    puts "#{ name.ljust(10) }  #{ price_to_string( amount ).rjust(8) }".blue
  end

end

