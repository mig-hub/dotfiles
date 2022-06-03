require 'yaml'
require_relative 'helpers'

module Compta

  LENGTH_DATE_COL = 10
  LENGTH_ID_COL = 11
  LENGTH_BOOK_ID_COL = LENGTH_DATE_COL + LENGTH_ID_COL + 2
  LENGTH_PRICE_COL = 8
  LENGTH_CLIENT_COL = 24
  LENGTH_SUMMARY_COL = 48

  def ls_proposals
    Dir[ "proposals/*.yml" ].sort.each do |file|
      doc = YAML.load_file file
      print_proposal doc
    end
    $compta_return
  end
  alias_method :lsp, :ls_proposals

  PAYMENT_LIMIT = ( 30 * 24 * 60 * 60 ).freeze

  def ls_invoices
    total_due = 0
    total_overdue = 0
    now = Time.now
    Dir[ "invoices/*.yml" ].sort.each do |file|
      doc = YAML.load_file file
      payment_status = :clear
      unless doc[:status] == 'fully paid'
        payment_status = :due
        total_due += doc[:total]
        date = string_to_date doc[:date]
        if now > date + PAYMENT_LIMIT
          payment_status = :overdue
          total_overdue += doc[:total]
        end
      end
      print_invoice doc, payment_status
    end
    print_due_summary total_due, total_overdue
    $compta_return
  end
  alias_method :lsi, :ls_invoices

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
  alias_method :lsb, :ls_book_entries

  private

  def print_proposal doc
    print_invoice doc
  end

  def print_invoice doc, payment_status=:clear
    out = doc[:id]
    out += '  '
    out += doc[:date]
    out += '  '
    out += price_to_string( doc[:total] ).rjust(LENGTH_PRICE_COL)
    out += '  '
    out += truncate( doc[:client_name], LENGTH_CLIENT_COL )
    out += '  '
    out += truncate( doc[:summary], LENGTH_SUMMARY_COL )
    if payment_status == :due
      puts out.yellow
    elsif payment_status == :overdue
      puts out.red
    else
      puts out
    end
  end

  def print_due_summary total_due, total_overdue
    if total_due > 0
      puts '=' * ( LENGTH_ID_COL + LENGTH_DATE_COL + LENGTH_PRICE_COL + 4 )
      print truncate( 'Total Due:', LENGTH_ID_COL + LENGTH_DATE_COL + 2 )
      print '  '
      puts price_to_string( total_due ).rjust(LENGTH_PRICE_COL).yellow
      if total_overdue > 0
        print truncate( 'Overdue:', LENGTH_ID_COL + LENGTH_DATE_COL + 2 )
        print '  '
        puts price_to_string( total_overdue ).rjust(LENGTH_PRICE_COL).red
      end
    end
  end

  def print_book_entry doc
    print doc[:id]
    print '  '
    print price_to_string( doc[:amount] ).rjust(LENGTH_PRICE_COL)
    print '  '
    print truncate( doc[:client_name], LENGTH_CLIENT_COL )
    print '  '
    print truncate( doc[:transaction_reference], LENGTH_SUMMARY_COL )
    puts
  end

  def print_quarter_summary name, amount
    puts "#{ name.ljust(LENGTH_BOOK_ID_COL) }  #{ price_to_string( amount ).rjust(LENGTH_PRICE_COL) }".blue
  end

end

