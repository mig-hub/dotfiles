require 'thor'
require_relative './utils'

class Webgum < Thor

  class Groq < Thor

    include Utils

  end
end

