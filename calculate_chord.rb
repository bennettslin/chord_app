# any argument passed in will already be limited to cardinality 3 or 4, and no repeated pc

require

class Chord # Question: is it possible to pass array as an argument into a class?

	def initialize(this_chord) # argument is duodecimal string, i.e. '4b70'
		@this_chord = this_chord
	end

	def getPrimeForm # puts in ic prime form (not pc prime form!)
		cardinal = @this_chord.length # finds cardinality (can only be 3 or 4)
		n_form, i_form = Array.new(2) { [] } # normal, ic forms
		@p_form = "" # ic prime form

		@this_chord.split("").each do |i| # puts in normal form
			n_form << i.to_i(12) # converts from duodecimal string
		end
		n_form.sort! # this minimizes ics

		cardinal.times do |i| # puts in ic form
			i_form[i] = (n_form[(i + 1) % cardinal] - n_form[i]) % 12
		end

		lowest_ic = i_form.index(i_form.min) # finds first occurrence of lowest ic
		cardinal.times do |i| # puts in prime form
			@p_form << i_form[(lowest_ic + i) % cardinal].to_s(12) # rotates lineup, lowest first
		end

		print "#{n_form}, #{i_form}, #{@p_form}\n"
	end

	def isThisLegal # determines whether chord is legal under these rules:
	# folk = 1, rock = 2, jazz = 3, classical = 4, illegal = 0
		case @p_form.to_i
		when 345, 354, 2334, 2343, 2433
		# min, maj triads; half-dim, min, dom sevenths
			return 1
		when 336, 363, 444, 3333
		# dim, aug triads; full-dim seventh
			return 2
		when 1344, 1434, 1443
		# min-maj, maj, aug-maj sevenths
			return 3
		when 246, 2424
		# Italian, French sixths
			return 4
		else
			return 0
		end
	end

end

newChord = Chord.new("6904")
newChord.getPrimeForm
puts newChord.isThisLegal

