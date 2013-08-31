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
	# argument is duodecimal string, i.e. '4b70'
	# inversions is false for tonal, true for post-tonal
	def initialize(this_chord, inversions)
		@this_chord = this_chord
		@inversions = inversions
	end

	def getICPrimeForm # puts sonority in ic prime form (not pc prime form!)
		# this method won't necessarily work for sonorities of more than four pcs,
		# but for our purposes it's fine since four pcs is the maximum for this game.
		card = @this_chord.length
		pcn_form, icn_form, icn_sonorities, icp_sonorities = Array.new(4) { [] }
		icp_form = "" # ic prime form
		@this_chord.split("").each do |i| # puts in pc normal form
			pcn_form << i.to_i(12) # converts from duodecimal string
		end
		pcn_form.sort! # puts pcs in arbitrary sequential order

		# converts pc normal form to ic normal form
		card.times do |i| # puts in ic normal form
			icn_form[i] = (pcn_form[(i + 1) % card] - pcn_form[i]) % 12
		end

		# converts ic normal form to ic prime form, and gives the more compact
		# ic prime form if there are inversions
		icn_sonorities[0] = icn_form
		icn_sonorities[1] = icn_form.reverse if @inversions
		icn_sonorities.count.times do |i|
			this_sonority = icn_sonorities[i]
			smallest_ics_index =
				this_sonority.each_index.select{ |index| this_sonority[index] == this_sonority.min }
			temp_max = first_ic_index = 0 # just declaring variables
			smallest_ics_index.each do |ic|
				temp_gap = this_sonority[(ic - 1) % card]
				if temp_gap > temp_max
					temp_max = temp_gap
					first_ic_index = ic
				end
			end
			temp_icp_form = ""
			card.times do |j| # puts in ic prime form
				temp_icp_form << this_sonority[(first_ic_index + j) % card].to_s(12) # rotates lineup
			end
			icp_sonorities[i] = temp_icp_form
		end

		@inversions ? icp_form =
			[icp_sonorities[0], icp_sonorities[1]].min : icp_form = icp_sonorities[0]

		puts "For #{@this_chord}, the interval-class prime form is (#{icp_form})."
	end

	def whatChord # identifies what type of chord, if any
		case @icp_form.to_i
		when 345; chordType = "minor triad"
		when 354; chordType = "major triad"
		when 2334; chordType = "half-diminished seventh"
		when 2343; chordType = "minor seventh"
		when 2433; chordType = "dominant seventh"
		when 336; chordType = "diminished triad"
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
				userChord = Chord.new(askUser, true)
				userChord.getICPrimeForm
				userChord.whatChord
			end
		end
	end
end

UserPrompt.run
