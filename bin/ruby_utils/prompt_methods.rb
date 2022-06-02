module PromptMethods

  def confirm( prompt )
    printf "#{ prompt } [y/n] : "
    yn = STDIN.gets.chomp
    return yn.downcase == 'y'
  end

end

