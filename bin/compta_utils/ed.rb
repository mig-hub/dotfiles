module Compta

  EDITOR = 'nvim'.freeze

  def ed_config
    ed 'compta.yml'
  end
  alias_method :edc, :ed_config

  def ed_proposal number, year=Time.now.year
    ed( find_proposal( number, year ) )
  end
  alias_method :edp, :ed_proposal

  def ed_invoice number, year=Time.now.year
    ed( find_invoice( number, year ) )
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
      puts "File #{ file } does not exist.".red
    end
    $compta_return
  end

end
