# slightly modified version of calculate_chord.rb to run in console

require 'highline/import'

class ChrScale # prints out duodecimal chart for reference
	def self.run

		12.times do |i| # prints out duodecimal integers
			duo = i.to_s(12) # converts to duodecimal notation
			if [1, 3, 6, 8, 10].include? i # these pcs represent accidentals
				print "#{duo}________"
			elsif i == 11
				print "#{duo}___\n"
			else
				print "#{duo}___"
			end
		end

		sharp = "\u266f" # Unicode symbols for sharp and flat signs
		flat = "\u266d" # Sublime Text 2 console doesn't recognize them
		diaScale = ["C", "D", "E", "F", "G", "A", "B"]
		7.times do |i|
			if i == 2 # no accidental
				print "#{diaScale[i]}   "
			elsif i == 6 # no accidental, end of line
				print "#{diaScale[i]}\n"
			else
				print "#{diaScale[i]}   #{diaScale[i]}#{sharp} /#{diaScale[(i + 1) % 7]}#{flat}   "
			end
		end
	end
end

class Chord
	def initialize(this_chord) # argument is duodecimal string, i.e. '4b70'
		@this_chord = this_chord
	end

	def getPrimeForm # puts chord in ic prime form (not pc prime form!)

		card = @this_chord.length # finds cardinality (can only be 3 or 4)
		n_form, i_form = Array.new(2) { [] } # normal, ic forms
		@p_form = "" # ic prime form

		@this_chord.split("").each do |i| # puts in normal form
			n_form << i.to_i(12) # converts from duodecimal string
		end
		n_form.sort! # this minimizes ics

		card.times do |i| # puts in ic form
			i_form[i] = (n_form[(i + 1) % card] - n_form[i]) % 12
		end

		lowest_ic = i_form.index(i_form.min) # finds first occurrence of lowest ic
		card.times do |i| # puts in ic-prime form
			@p_form << i_form[(lowest_ic + i) % card].to_s(12) # rotates lineup, lowest first
		end

		puts "The interval-class prime form is (#{@p_form})."
	end

	def whatChord # identifies what type of chord, if any
		case @p_form.to_i
		when 345; chordType = "minor triad"
		when 354; chordType = "major triad"
		when 2334; chordType = "half-diminished seventh"
		when 2343; chordType = "minor seventh"
		when 2433; chordType = "dominant seventh"
		when 336; chordType = "diminished triad"
		when 363; chordType = "diminished triad"
		when 444; chordType = "augmented triad"
		when 3333; chordType = "fully diminished seventh"
		when 1344; chordType = "minor-major seventh"
		when 1434; chordType = "major seventh"
		when 1443; chordType = "augmented major seventh"
		when 246; chordType = "Italian sixth"
		when 2424; chordType = "French sixth"
		else; chordType = "nonchord"
		end

		if ["a", "I"].include? chordType[0] # checks if first letter is vowel
			puts "This is an #{chordType}."
		elsif chordType == "nonchord"
			puts "This isn't a traditional chord."
		else
			puts "This is a #{chordType}."
		end
	end
end

class UserPrompt
	def self.run
		loop do
			askUser = ask("Enter a duodecimal sonority (e.g., 27a5)\nor 'n' for notation chart, or 'q' to quit: ")
			if askUser[0].downcase == "q"
				break
			elsif askUser[0].downcase == "n"
				ChrScale.run
			else
				userChord = Chord.new(askUser)
				userChord.getPrimeForm
				userChord.whatChord
			end
		end
	end
end

UserPrompt.run
