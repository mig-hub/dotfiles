module Compta

  def email_pdf type, number, year=Time.now.year
    if type != :invoice and type != :proposal
      puts "Cannot email PDF for type #{ type }.".red
      return $compta_return
    end
    doc = load_doc type, number, year
    if doc.nil?
      puts "Cannot find this doc, year: #{ year }, number: #{ number }.".red
      return $compta_return
    end
    pdf_file = pdf_file_for type, doc
    unless File.exist? pdf_file
      puts "Pdf #{ pdf_file } was not created yet.".yellow
      if confirm( 'Would you like to create it now?' )
        export_pdf type, number, year
      else
        return $compta_return
      end
    end

    pdf_id = File.basename( pdf_file, '.pdf' )
    subject = "Rive #{ doctype( type, doc[:lang] ) } — #{ pdf_id } — #{ doc[:summary] }"
    content = "#{ type } #{ pdf_id } #{ doc[:summary] }"
    client = ( $compta_config[:clients] or [] ).find do |c|
      c[:client_name] == doc[:client_name]
    end
    if client.nil? or not client.key?( :recipients )
      recipients = []
    else
      recipients = client[:recipients]
    end
    recipients_code = recipients.map do |r|
      "make new to recipient at end of to recipients with properties {address:\"#{ r }\"}"
    end.join( "\n" )
    from = 'mickael@rive.studio'

    osascript <<-END
    tell application "Mail"
      set newMessage to make new outgoing message with properties {sender: "#{ from }", subject:"#{ subject }", content:"#{ content }" & linefeed & linefeed}
      tell newMessage
        set visible to true
        #{ recipients_code }
      end tell
      tell content of newMessage
        make new attachment with properties {file name: POSIX path of "#{ File.expand_path( pdf_file ) }"} at after last paragraph
      end tell
      activate
    end tell
    END

    return $compta_return
  end

  def emailp number, year=Time.now.year
    email_pdf :proposal, number, year
  end

  def emaili number, year=Time.now.year
    email_pdf :invoice, number, year
  end

end

