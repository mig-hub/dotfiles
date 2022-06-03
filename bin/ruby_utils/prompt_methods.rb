module PromptMethods

  def confirm( prompt )
    print "#{ prompt } [y/n] : "
    yn = STDIN.gets.chomp
    return yn.downcase == 'y'
  end

end

