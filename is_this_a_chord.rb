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
	# if post_tonal is true, will check inversions, but won't establish a root
	def initialize(this_chord, post_tonal)
		@this_chord = this_chord
		@post_tonal = post_tonal
	end

	def getICPrimeForm # puts sonority in ic prime form (not pc prime form!)
		# this method won't necessarily work for sonorities of more than four pcs,
		# but for our purposes it's fine since four pcs is the maximum for this game.
		@icp_form = "" # ic prime form
		@fake_root = 0 # not always the musical root, just used to id unique chord
		card = @this_chord.length

		pcn_form, icn_form, icn_sonorities, icp_sonorities = Array.new(4) { [] }
		@this_chord.split("").each do |i| # puts in pc normal form
			pcn_form << i.to_i(12) # converts from duodecimal string
		end
		pcn_form.sort! # puts pcs in arbitrary sequential order

		# converts pc normal form to ic normal form
		card.times do |i| # puts in ic normal form
			icn_form[i] = (pcn_form[(i + 1) % card] - pcn_form[i]) % 12
		end

		# converts ic normal form to ic prime form, and gives the more compact
		# ic prime form if there are post_tonal
		icn_sonorities[0] = icn_form
		icn_sonorities[1] = icn_form.reverse if @post_tonal
		icn_sonorities.count.times do |i|
			this_sonority = icn_sonorities[i]
			smallest_ics_index =
				this_sonority.each_index.select{ |j| this_sonority[j] == this_sonority.min }
				# selects however many index values there are of the smallest ic
			temp_max = first_ic_index = 0 # just declaring variables
			smallest_ics_index.each do |ic|
				temp_gap = this_sonority[(ic - 1) % card]
				if temp_gap > temp_max
					temp_max = temp_gap
					first_ic_index = ic
				end
			end

			@fake_root = pcn_form[first_ic_index] unless @post_tonal
			temp_icp_form = ""
			card.times do |k| # puts in ic prime form
				temp_icp_form << this_sonority[(first_ic_index + k) % card].to_s(12) # rotates lineup
			end
			icp_sonorities[i] = temp_icp_form
		end

		@post_tonal ? @icp_form =
			[icp_sonorities[0], icp_sonorities[1]].min : @icp_form = icp_sonorities[0]
		print "The interval-class prime form of [#{@this_chord}] is (#{@icp_form}).\n"
	end

	def getLegality # identifies what type of chord, if any
		if @post_tonal
			oct_ics = [129, 138, 156, 237, 246, 336, 345, 1218, 1236, 1245, 1326, 1335, 1515, 1272, 1263, 2334, 2424, 1353, 2343, 3333]
			hex_ics = [138, 147, 228, 246, 345, 444, 1317, 1344, 1434, 2226, 2244, 2424, 1353]
		else
			# t for tonal, pt for post_tonal
			t_ics = [345, 354, 2334, 2343, 2433, 336, 444, 3333, 1344, 1434, 1443, 246, 2424]
			t_names = ["minor triad", "major triad", "half-diminished seventh", "minor seventh", "dominant seventh",
										"diminished triad", "augmented triad", "fully diminished seventh", "minor-major seventh",
										"major seventh", "augmented major seventh", "Italian sixth", "French sixth"]
			# adds to fake root to find correct root
			t_adjust_root = [0, 8, 2, 2, 2, 0, 0, 0, 1, 1, 1, 2, 2]
			# for each symmetric chord, first value is ics, second value is mod number
			t_symmetric = [[444, 3333, 2424], [4, 3, 6]]
			correct_root = String.new
			t_index = t_ics.index(@icp_form.to_i)
			if t_index == nil
			elsif t_index.between?(0, 4)
				under_rules = "folk"
			elsif t_index.between?(5, 7)
				under_rules = "rock"
			elsif t_index.between?(8, 10)
				under_rules = "jazz"
			elsif t_index.between?(11, 12)
				under_rules = "classical"
			end

			if t_index == nil
				print "This isn't a traditional chord.\n"
			else
				sym_index = t_symmetric[0].index(t_ics[t_index])
				if sym_index != nil
					mod = t_symmetric[1][sym_index]
					(12 / mod).times do |i|
						correct_root << (((@fake_root + t_adjust_root[t_index])% mod) + (mod * i)).to_s(12)
					end
				else
					correct_root = ((t_adjust_root[t_index] + @fake_root) % 12).to_s(12)
				end
				print "This is a #{correct_root} #{t_names[t_index]}, legal under #{under_rules} rules.\n"
			end
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
				userChord = Chord.new(askUser, false)
				userChord.getICPrimeForm
				userChord.getLegality
			end
		end
	end
end

UserPrompt.run
