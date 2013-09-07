# This just makes a chart for me to see how prevalent each sonority is
# under each set of rules. It's not great code, ha.

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
		@icp_form = "" # ic prime form
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

		@inversions ? @icp_form =
			[icp_sonorities[0], icp_sonorities[1]].min : @icp_form = icp_sonorities[0]

		print "For [#{@this_chord}], ic prime form is (#{@icp_form})"
	end

	def whatChord # identifies what type of chord, if any
		rules = String.new
		case @icp_form.to_i
		when 345; chordType = "minor triad"; rules = "folk"
		when 354; chordType = "major triad"; rules = "folk"
		when 2334; chordType = "half-diminished seventh"; rules = "folk"
		when 2343; chordType = "minor seventh"; rules = "folk"
		when 2433; chordType = "dominant seventh"; rules = "folk"
		when 336; chordType = "diminished triad"; rules = "rock"
		when 444; chordType = "augmented triad"; rules = "rock"
		when 3333; chordType = "fully diminished seventh"; rules = "rock"
		when 1344; chordType = "minor-major seventh"; rules = "jazz"
		when 1434; chordType = "major seventh"; rules = "jazz"
		when 1443; chordType = "augmented major seventh"; rules = "jazz"
		when 246; chordType = "Italian sixth"; rules = "clas"
		when 2424; chordType = "French sixth"; rules = "clas"
		else; chordType = "nonchord"
		end

		if ["a", "I"].include? chordType[0] # checks if first letter is vowel
			print ", legal under #{rules}"
		elsif chordType == "nonchord"
			print ", ----------------"
		else
			print ", legal under #{rules}"
		end
	end
end

class OctMembership
	def initialize(this_chord)
		@this_chord = this_chord
	end

	def belongsInOct
		condition = false
		this_array = Array.new
		oct = [%w(0 1 3 4 6 7 9 a), %w(0 2 3 5 6 8 9 a), %w(1 2 4 5 7 8 a b)]
		condition = true
		this_array = @this_chord.split("")
		needs_just_one = 0
		oct.each do |each_oct|
			good_so_far = 0
			# print "#{each_oct.class}\n"
			this_array.each do |each_pc|
				# print "#{each_pc.class}\n"
				good_so_far += 1 if each_oct.include?(each_pc)
			end
			needs_just_one = 1 if good_so_far == this_array.count
		end
		if needs_just_one == 1
			print ", in oct"
		else
			print ", ------"
		end
	end
end

class HexMembership
	def initialize(this_chord)
		@this_chord = this_chord
	end

	def belongsInHex
		condition = false
		this_array = Array.new
		hex = [%w(0 1 4 5 8 9 ), %w(1 2 5 6 9 a), %w(2 3 6 7 a b), %w(3 4 7 8 b 0), %w(0 2 4 6 8 a), %w(1 3 5 7 9 b)]
		condition = true
		this_array = @this_chord.split("")
		needs_just_one = 0
		hex.each do |each_hex|
			good_so_far = 0
			# print "#{each_hex.class}\n"
			this_array.each do |each_pc|
				# print "#{each_pc.class}\n"
				good_so_far += 1 if each_hex.include?(each_pc)
			end
			needs_just_one = 1 if good_so_far == this_array.count
		end
		if needs_just_one == 1
			print ", in hex or WT"
		else
			print ", ------------"
		end
		print "\n"
	end

end


# trichords and tetrachords
pc_form_array = %w(012 013 014 015 016 024 025 026 027 036 037 048 0123 0124 0125
										0126 0127 0134 0135 0136 0137 0145 0146 0147 0148 0156 0157 0158
										0167 0235 0236 0237 0246 0247 0248 0257 0258 0268 0347 0358 0369)

# pentachords
# pc_form_array = %w(01234 01235 01236 01237 01245 01246 01247 01248 01256 01257 01258
# 										01267 01268 01346 01347 01348 01356 01357 01358 01367 01368 01369
# 										01457 01458 01468 01469 01478 01568 02346 02347 02357 02358 02368
# 										02458 02468 02469 02479 03458)

#hexachords
# pc_form_array = %w(012345 012346 012347 012348 012357 012358 012367 012368 012369
# 										012378 012458 012468 012469 012478 012479 012569 012578 012579
# 										012678 013457 013458 013469 013479 013579 013679 023679 014568
# 										014579 014589 023457 023468 023469 023579 024579 02468a)

# gets all ic prime forms of pc prime forms
ic_form_w_inversion = Array.new

pc_form_array.each do |sonority|
	chord = Chord.new(sonority, true)
	print chord.getICPrimeForm
	print chord.whatChord
	belongs_oct = OctMembership.new(sonority)
	print belongs_oct.belongsInOct
	belongs_hex = HexMembership.new(sonority)
	print belongs_hex.belongsInHex
end


# class UserPrompt
# 	def self.run
# 		loop do
# 			askUser = ask("Enter a duodecimal sonority (e.g., 27a5)\nor 'n' for notation chart, or 'q' to quit: ")
# 			if askUser[0].downcase == "q"
# 				break
# 			elsif askUser[0].downcase == "n"
# 				ChrScale.run
# 			else
# 				userChord = Chord.new(askUser, true)
# 				userChord.getICPrimeForm
# 				userChord.whatChord
# 			end
# 		end
# 	end
# end

# UserPrompt.run
