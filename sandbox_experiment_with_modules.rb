module Hello
  def self.helloness(var)
    puts "Hello there, #{var}."
  end
end

class Howdy
  include Hello
end
