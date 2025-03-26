require_relative 'helpers'
require_relative 'ls'

module Compta

  PAYMENT_METHODS = [
    'virement bancaire',
    'virement électronique',
    'chèque',
    'espèces',
  ]

  STATUS_OPTIONS_PROPOSAL = [
    'draft', 'sent to client', 'accepted', 'deposit paid', 'fully paid'
  ]

  STATUS_OPTIONS_INVOICE = [
    'draft', 'sent to client', 'fully paid'
  ]

  def default_doc type
    potential_id = next_doc_id type
    {
      id: potential_id,
      lang: 'en',
      my_details: $compta_config[:my_details],
      payment_details: payment_details_for( type, 'en' ),
      client_name: "",
      client_details: "",
      date: date_to_string( Time.now ),
      incremental_number: potential_id[ /\d\d\d$/ ].to_i( 10 ),
      tax_comment: $compta_config[:tax_comment],
      summary: "",
      status: type == :proposal ? STATUS_OPTIONS_PROPOSAL[0] : STATUS_OPTIONS_INVOICE[0],
      items: [],
      total: 0,
    }
  end

  def new_doc type
    doc = default_doc type

    print "ID ( or '#{ doc[:id] }' ) : "
    id = STDIN.gets.chomp
    unless id == ''
      doc[:id] = id
      doc[:incremental_number] = id[ /\d\d\d$/ ].to_i( 10 )
    end

    print "Lang ( or '#{ doc[:lang] }' ) : "
    lang = STDIN.gets.chomp.downcase
    unless lang == ''
      doc[:lang] = lang
      doc[:payment_details] = payment_details_for( type, lang )
    end

    ls_clients
    print "Client ID ( pick a digit or blank for new client ) : "
    client_index_str = STDIN.gets.chomp
    if client_index_str == ''
      print "Client name : "
      doc[:client_name] = STDIN.gets.chomp
      print "Client details (end lines with CTRL-D): "
      doc[:client_details] = STDIN.readlines.join.chomp
    elsif client_index_str =~ /^\d+$/
      client = $compta_config[:clients][client_index_str.to_i]
      if client.nil?
        puts "Unknown client: digit out of range.".red
      else
        doc[:client_name] = client[:client_name]
        doc[:client_details] = client[:client_details]
      end
    else
      puts "Unknown client: digit or blank for new client expected.".red
    end

    print "Title ( e.g. 'Website for Company.com' ) : "
    doc[:summary] = STDIN.gets.chomp

    while confirm( "Add an item ?".yellow ) do
      item = {}
      print "Description ( end lines with CTRL-D ) : "
      item[:description] = STDIN.readlines.join.chomp
      print "Price ( e.g. 140, 12.5K, 2h, 3:45 ) : "
      item[:price] = string_to_price( STDIN.gets.chomp )
      doc[:items] << item
      doc[:total] += item[:price]
    end

    if confirm "Would you like to save this new #{ type } ?".yellow
      save_doc type, doc
    end

    $compta_return
  end

  def new_proposal
    new_doc :proposal
  end
  alias_method :newp, :new_proposal

  def new_invoice proposal_number=nil, proposal_year=Time.now.year
    if proposal_number.nil?
      new_doc :invoice
    else
      if confirm "Would you like to create a deposit invoice for this proposal ?".yellow
        new_deposit_invoice proposal_number, proposal_year
      elsif confirm "Would you like to create a completion invoice for this proposal ?".yellow
        new_invoice_from_proposal proposal_number, proposal_year
      end
    end
  end
  alias_method :newi, :new_invoice

  def new_deposit_invoice proposal_number, proposal_year=Time.now.year

    proposal = load_doc :proposal, proposal_number, proposal_year

    if proposal.nil?
      puts "Cannot find proposal number #{ proposal_number } in year #{ proposal_year }.".red
      return $compta_return
    end

    doc = default_doc :invoice

    print "ID ( or '#{ doc[:id] }' ) : "
    id = STDIN.gets.chomp
    unless id == ''
      doc[:id] = id
      doc[:incremental_number] = id[ /\d\d\d$/ ].to_i( 10 )
    end

    doc[:lang] = proposal[:lang]
    doc[:payment_details] = payment_details_for( :invoice, proposal[:lang] )
    doc[:client_name] = proposal[:client_name]
    doc[:client_details] = proposal[:client_details]
    doc[:summary] = "Deposit #{proposal[:summary]}"

    print "Title ( or '#{doc[:summary]}' ) : "
    summary = STDIN.gets.chomp
    unless summary == ''
      doc[:summary] = summary
    end

    prefix = $compta_config[:proposal_pdf_prefix]
    item = {
      description: "50% Deposit for proposal #{prefix}#{proposal[:id]}, #{proposal[:summary]}",
      price: proposal[:total] / 2,
    }
    print "Price ( or #{price_to_string(item[:price])} ) : "
    price_string = STDIN.gets.chomp
    unless price_string == ''
      item[:price] = string_to_price( price_string )
    end
    doc[:items] << item

    doc[:total] = item[:price]

    if confirm "Would you like to save this new deposit invoice ?".yellow
      save_doc :invoice, doc
    end

    $compta_return
  end

  def new_invoice_from_proposal proposal_number, proposal_year=Time.now.year

    proposal = load_doc :proposal, proposal_number, proposal_year

    if proposal.nil?
      puts "Cannot find proposal number #{ proposal_number } in year #{ proposal_year }.".red
      return $compta_return
    end

    doc = default_doc :invoice

    print "ID ( or '#{ doc[:id] }' ) : "
    id = STDIN.gets.chomp
    unless id == ''
      doc[:id] = id
      doc[:incremental_number] = id[ /\d\d\d$/ ].to_i( 10 )
    end

    doc[:lang] = proposal[:lang]
    doc[:payment_details] = payment_details_for( :invoice, proposal[:lang] )
    doc[:client_name] = proposal[:client_name]
    doc[:client_details] = proposal[:client_details]
    doc[:summary] = proposal[:summary]
    doc[:items] = proposal[:items].dup
    doc[:total] = proposal[:total]

    if confirm "Would you like to substract the deposit ?".yellow
      item = {
        description: "50% Deposit already paid",
        price: -proposal[:total] / 2,
      }
      print "Price ( or #{price_to_string(item[:price])} ) : "
      price_string = STDIN.gets.chomp
      unless price_string == ''
        item[:price] = string_to_price( price_string )
      end
      doc[:items] << item
      doc[:total] += item[:price]
    end

    if confirm "Would you like to save this new invoice ?".yellow
      save_doc :invoice, doc
    end

    $compta_return
  end

  def book_entry_for invoice
    date_string = date_to_string Time.now
    {
      id: "#{ date_string }--#{ invoice[:id] }",
      payment_date: date_string,
      invoice_number: invoice[:id],
      client_name: invoice[:client_name],
      transaction_reference: invoice[:summary],
      amount: invoice[:total],
      payment_method: PAYMENT_METHODS[0],
    }
  end

  def new_book_entry invoice_number, invoice_year=Time.now.year

    invoice = load_doc :invoice, invoice_number, invoice_year

    if invoice.nil?
      puts "Cannot find invoice number #{ invoice_number } in year #{ invoice_year }.".red
      return $compta_return
    end

    doc = book_entry_for invoice

    print "Payment Date ( or '#{ doc[:payment_date] }' ) : "
    date = STDIN.gets.chomp
    unless date == ''
      unless date =~ /^\d\d\d\d-\d\d-\d\d$/
        puts "Error: Malformed payment date `#{ date }`, it should be of the form `yyyy-mm-dd`.".red
        return $config_return
      end
      doc[:payment_date] = date
      doc[:id] = "#{ doc[:payment_date] }--#{ doc[:invoice_number] }"
    end

    ls_payment_methods
    print "Payment Method ( pick a digit or blank for '#{ doc[:payment_method] }' ) : "
    method_index_str = STDIN.gets.chomp
    unless method_index_str == ''
      if method_index_str =~ /^\d+$/
        method = PAYMENT_METHOD[method_index_str.to_i]
        if method.nil?
          puts "Payment method digit is out of range. We will keep the default value `#{ doc[:payment_method] }` instead. Feel free to edit it afterward with the command `edb <number>` or  `edb <number>, <year>`.".red
        else
          doc[:payment_method] = method
        end
      else
        puts "Payment method should be a digit or blank for '#{ doc[:payment_method] }'. We will keep the default value instead. Feel free to edit it afterward with the command `edb <number>` or  `edb <number>, <year>`.".red
      end
    end

    if confirm "Would you like to save this new book entry ?".yellow
      save_doc :book_entry, doc
      if confirm "Would you like to mark the invoice as 'fully paid' ?".yellow
        invoice[:status] = STATUS_OPTIONS_INVOICE.last
        save_doc :invoice, invoice
      end
    end

    $compta_return
  end
  alias_method :newb, :new_book_entry

end

