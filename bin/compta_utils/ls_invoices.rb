require 'yaml'
require_relative 'helpers'

module Compta

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

  private

  def print_invoice doc, payment_status
    out = doc[:date]
    out += '  '
    out += price_to_string( doc[:total] ).rjust(8)
    out += '  '
    out += truncate( doc[:client_name], 24 )
    out += '  '
    out += truncate( doc[:summary], 48 )
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
      puts "===================="
      puts "Total Due:  #{ price_to_string( total_due ).rjust(8).yellow }  (including overdue)"
      if total_overdue > 0
        puts "Overdue:    #{ price_to_string( total_overdue ).rjust(8).red }"
      end
    end
  end

end

