desc "Add global rake tasks"
task 'add-rake-tasks' do
  if File.exists?('~/.rake')
    puts "A ~/.rake directory already exists."
  else
    ln_s File.expand_path('rake'), File.expand_path('~/.rake')
  end
end
