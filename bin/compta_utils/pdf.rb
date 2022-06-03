require 'prawn' # Manual: http://prawnpdf.org/manual.pdf
require 'prawn/measurement_extensions'
require_relative 'helpers'

module Compta

  def export_pdf type, number, year=Time.now.year
    if type != :invoice and type != :proposal
      puts "Cannot export PDF for type #{ type }.".red
      return $compta_return
    end
    doc = load_doc type, number, year
    if doc.nil?
      puts "Cannot find this doc, year: #{ year }, number: #{ number }.".red
      return $compta_return
    end
    puts "About to create a PDF for the following document:".yellow
    puts doc[:id]
    puts doc[:client_name]
    puts doc[:summary]
    if confirm( 'Do you wish to proceed?' )
      pdf_file = pdf_file_for( type, doc )
      pdf = PdfExport.new( type, doc ).document
      pdf.render_file pdf_file
      puts "PDF #{ pdf_file } was created.".green
    end
    return $compta_return
  end

  def export_pdf_proposal number, year=Time.now.year
    export_pdf :proposal, number, year
  end
  alias_method :pdfp, :export_pdf_proposal

  def export_pdf_invoice number, year=Time.now.year
    export_pdf :invoice, number, year
  end
  alias_method :pdfi, :export_pdf_invoice

  class PdfExport

    include Prawn::View

    attr_reader :type, :doc

    def initialize type, doc

      @type = type
      @doc = doc

      set_fonts
      stroke_color 'cccccc'

      repeat :all do
        print_header
      end

      doc[:items].each do |item|
        print_item item[:description], item[:price]
      end

      move_down 4.pt
      stroke_horizontal_rule
      print_item "TOTAL\n#{ doc[:tax_comment] }", doc[:total], '= '
      print_outro
      print_page_numbers

    end

    def document
      @document ||= Prawn::Document.new({
        page_size: 'A4',
        page_layout: :portrait,
        margin: 1.cm,
      })
    end

    private

    def doctype
      if type == :invoice
        if doc[:lang] == 'fr'
          'FACTURE'
        else
          'INVOICE'
        end
      else
        if doc[:lang] == 'fr'
          'DEVIS'
        else
          'PROPOSAL'
        end
      end
    end

    def set_fonts
      if $compta_config[:font]
        font_families.update(
         $compta_config[:font][:name] => {
           normal: $compta_config[:font][:file],
         }
        )
        font $compta_config[:font][:name]
      end
      font_size 8.pt
      default_leading 1.pt
    end

    def start_new_page_if_needed
      safe_height = bounds.height / 6
      if cursor <= safe_height
        start_new_page
        move_down header_height
      end
    end

    def header_height
      bounds.height / 4
    end

    def print_header
      bounding_box( [0, bounds.top], width: bounds.width, height: header_height ) do
        define_grid( rows: 1, columns: 4, gutter: 0.5.cm )

        if $compta_config[:logo]
          grid( 0, 0 ).bounding_box do
            image $compta_config[:logo], width: 3.cm, position: :left, vposition: :top
          end
        end

        grid( 0, 1 ).bounding_box do
          text( "#{ $compta_config[:first_name] } #{ $compta_config[:last_name] }".upcase, size: 9.pt )
          move_down 9.pt
          text doc[:my_details]
        end

        grid( 0, 2 ).bounding_box do
          text( doctype.upcase, size: 9.pt )
          info = $compta_config["#{ type }_pdf_prefix".to_sym].to_s
          info << doc[:id]
          info << "\n\n</date>\n"
          info << doc[:date].split( '-' ).reverse.join( '/' )
          info << "\n\n</#{ doc[:lang] == 'fr' ? 'prestation' : 'description' }>\n"
          info << doc[:summary]
          info << "\n\n</client>\n"
          info << doc[:client_name]
          info << "\n\n"
          info << doc[:client_details]
          text info
        end

      end # header
      stroke_horizontal_rule
      # move_down header_height
    end

    def print_item description, price, price_prefix=''
      start_new_page_if_needed
      move_down 10.pt
      float do
        bounding_box( [ bounds.width * 0.75, cursor ], width: bounds.width / 4 ) do
          text("#{ price_prefix }#{ price_to_string( price ) } €", align: :right )
        end
      end
      bounding_box( [ bounds.width / 4, cursor ], width: bounds.width / 2 ) do
        text description
      end
      move_down 10.pt
      stroke_horizontal_rule
    end

    def print_outro
      start_new_page_if_needed
      move_down 10.pt
      bounding_box( [ bounds.width / 4, cursor ], width: bounds.width / 2 ) do
        text doc[:payment_details]
      end
    end

    def print_page_numbers
      number_pages "Page <page>/<total>", {
        at: [ 0, bounds.top ],
        align: :right,
      }
    end

  end

end

