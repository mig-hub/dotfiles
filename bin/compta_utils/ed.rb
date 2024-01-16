require_relative 'helpers'

module Compta

  EDITOR = 'nvim'.freeze

  def ed_config
    ed 'compta.yml'
  end
  alias_method :edc, :ed_config

  def ed_proposal number, year=Time.now.year
    ed( find_proposal( number, year ) )
    edit_total_if_mismatch :proposal, number, year
    $compta_return
  end
  alias_method :edp, :ed_proposal

  def ed_invoice number, year=Time.now.year
    ed( find_invoice( number, year ) )
    edit_total_if_mismatch :invoice, number, year
    $compta_return
  end
  alias_method :edi, :ed_invoice

  def ed_book_entry number, year=Time.now.year
    ed( find_book_entry( number, year ) )
  end
  alias_method :edb, :ed_book_entry

  def ed file
    if not file.nil? and File.exist? file
      system "#{ EDITOR } #{ file }"
    else
      raise "File #{ file } does not exist.".red
    end
    $compta_return
  end

  private

  def edit_total_if_mismatch type, number, year=Time.now.year
    # Offers to update the total if not equal to total item prices.
    # Presumably after a manual update of the items.
    if type != :invoice and type != :proposal
      puts "No total calculation for type #{ type }.".red
      return $compta_return
    end
    doc = load_doc type, number, year
    total = ( doc[:items] or [] ).inject( 0 ) do |sum, item|
      sum + item[:price]
    end
    if doc[:total] != total and confirm( "Total is not up-to-date. Would you like to update it?".yellow )
      doc[:total] = total
      save_doc type, doc
    end
  end

end
