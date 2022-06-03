require 'yaml'
require_relative '../ruby_utils/string_color'
require_relative '../ruby_utils/prompt_methods'

module Compta

  def float_to_price f
    ( f * 100 ).floor
  end

  def price_to_string p, style=:regular
    str = p.to_s.sub( /(\d\d)$/, '.\1' )
    case style
    when :no_zero_cents
      str.sub( '.00', '' )
    else
      str
    end
  end

  def string_to_date str
    Time.new( *str.split( '-' ) )
  end

  QUARTERS = {
    '01' => 'Q1', '02' => 'Q1', '03' => 'Q1',
    '04' => 'Q2', '05' => 'Q2', '06' => 'Q2',
    '07' => 'Q3', '08' => 'Q3', '09' => 'Q3',
    '10' => 'Q4', '11' => 'Q4', '12' => 'Q4',
  }.freeze

  def quarter_for_date date
    year, month, day = date.split '-'
    "#{ year } #{ QUARTERS[month] }"
  end

  def truncate str, length
    if str.length <= length
      str.ljust length, ' '
    else
      "#{ str.slice( 0..( length - 2 ) ) }…"
    end
  end

  # Methods to find docs.
  # Docs can be identified by their year and number.
  # By default we use the current year.

  def find_doc type, number, year=Time.now.year
    if type == :proposal or type == :invoice
      Dir[ "#{ type }s/#{ year }-*#{ number.to_s.rjust( 3, '0' ) }.yml" ].first
    elsif type == :book_entry
      # Invoice year is used to make sure we don't get a uniqueness problem
      # when an invoice is paid on the following year after it was issued.
      # e.g. Invoices issued in December and paid in January
      Dir[ "book-entries/????????????#{ year }-*#{ number.to_s.rjust( 3, '0' ) }.yml" ].first
    else
      nil
    end
  end

  def find_proposal number, year=Time.now.year
    find_doc :proposal, number, year
  end

  def find_invoice number, year=Time.now.year
    find_doc :invoice, number, year
  end

  def find_book_entry number, year=Time.now.year
    find_doc :book_entry, number, year
  end

  # Loading docs

  def load_doc type, number, year=Time.now.year
    file = find_doc type, number, year
    if file.nil? or not File.exist? file
      return nil
    end
    YAML.load_file file
  end

  # PDF location for a doc

  def pdf_file_for type, doc
    if type != :proposal and type != :invoice
      raise "Wrong PDF type: #{ type }."
    end
    prefix = $compta_config["#{ type }_pdf_prefix".to_sym]
    "#{ type }s-pdf/#{ prefix }#{ doc[:id] }.pdf"
  end

end

