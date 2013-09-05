
  def convertPCIntegerToLetter(pc_integer)
    pc_letter = Array.new
    sharp = "\u266f" # Unicode symbols for sharp and flat signs
    flat = "\u266d" # Sublime Text 2 console doesn't recognize them
    scale = ["C", "D", "E", "F", "G", "A", "B"]
    pc_integer.each_char do |pc|
      case pc.to_i(12)
        when 0; temp_pc_letter = "C"
        when 1; temp_pc_letter = "C#{sharp} /D#{flat} "
        when 2; temp_pc_letter = "D"
        when 3; temp_pc_letter = "D#{sharp} /E#{flat} "
        when 4; temp_pc_letter = "E"
        when 5; temp_pc_letter = "F"
        when 6; temp_pc_letter = "F#{sharp} /G#{flat} "
        when 7; temp_pc_letter = "G"
        when 8; temp_pc_letter = "G#{sharp} /A#{flat} "
        when 9; temp_pc_letter = "A"
        when 10; temp_pc_letter = "A#{sharp} /B#{flat} "
        when 11; temp_pc_letter = "B"
      end
      pc_letter << temp_pc_letter
    end
    return pc_letter.join("-")
  end

puts convertPCIntegerToLetter("147a")

  #   12.times do |i| # prints out duodecimal integers
  #     duo = i.to_s(12) # converts to duodecimal notation
  #     if [1, 3, 6, 8, 10].include? i # these pcs represent accidentals
  #       print "#{duo}________"
  #     elsif i == 11
  #       print "#{duo}___\n"
  #     else
  #       print "#{duo}___"
  #     end
  #   end



  #   sharp = "\u266f" # Unicode symbols for sharp and flat signs
  #   flat = "\u266d" # Sublime Text 2 console doesn't recognize them
  #   diaScale = ["C", "D", "E", "F", "G", "A", "B"]
  #   7.times do |i|
  #     if i == 2 # no accidental
  #       print "#{diaScale[i]}   "
  #     elsif i == 6 # no accidental, end of line
  #       print "#{diaScale[i]}\n"
  #     else
  #       print "#{diaScale[i]}   #{diaScale[i]}#{sharp} /#{diaScale[(i + 1) % 7]}#{flat}   "
  #     end
  #   end
  # end
