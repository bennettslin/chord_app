class GetChordStatus
  # argument is duodecimal string, i.e. '4b70'
  # if post-tonal is true, will check inversions, but won't establish a root

  def initialize(this_chord, rule)
    @this_chord = this_chord
    @rule = rule
  end

  def isThisAChord(game_chords)
    icp_form, fake_root = getICPrimeForm
    legal_chord = isThisLegal(icp_form, game_chords)
    print "This is #{legal_chord ? "legal" : "illegal"} under rule #{@rule}.\n"
    if @rule < 5
      real_root, chord_type = getRootAndType(icp_form, fake_root)
      print "This is a #{real_root} #{chord_type}.\n"
    end
  end

  def getICPrimeForm # puts sonority in ic prime form (not pc prime form!)
    # this method won't necessarily work for sonorities of more than four pcs,
    # but for our purposes it's fine since four pcs is the maximum for this game.
    icp_form = String.new
    fake_root = 0 # not always the musical root, just used to id unique chord
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
    # ic prime form if there are post-tonal
    icn_sonorities[0] = icn_form
    icn_sonorities[1] = icn_form.reverse if @rule.between?(5, 6)
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

      fake_root = pcn_form[first_ic_index] unless @rule.between?(5, 6)
      temp_icp_form = ""
      card.times do |k| # puts in ic prime form
        temp_icp_form << this_sonority[(first_ic_index + k) % card].to_s(12) # rotates lineup
      end
      icp_sonorities[i] = temp_icp_form
    end

    @rule.between?(5, 6) ? icp_form =
      [icp_sonorities[0], icp_sonorities[1]].min : icp_form = icp_sonorities[0]
    print "The interval-class prime form of [#{@this_chord}] is (#{icp_form}).\n"
    return icp_form, fake_root
  end

  def isThisLegal(icp_form, game_chords)
    game_chords.include?(icp_form.to_i)
  end

  def getRootAndType(icp_form, fake_root) # returns string for real root
    real_root = String.new
    # refactor? same array as superset of tonal ics in method to create array of all legal chords
    tonal_ics = [345, 354, 2334, 2343, 2433, 336, 444, 3333, 1344, 1434, 1443, 246, 2424]
    t_names = ["minor triad", "major triad", "half-diminished seventh", "minor seventh", "dominant seventh",
              "diminished triad", "augmented triad", "fully diminished seventh", "minor-major seventh",
              "major seventh", "augmented major seventh", "Italian sixth", "French sixth"]
    t_adjust_root = [0, 8, 2, 2, 2, 0, 0, 0, 1, 1, 1, 2, 2] # adds to fake root to find correct root
    # for each symmetric chord, first value is ics, second value is mod number
    t_symmetric = [[444, 3333, 2424], [4, 3, 6]]
    t_index = tonal_ics.index(icp_form.to_i)
    sym_index = t_symmetric[0].index(tonal_ics[t_index])
    if sym_index != nil
      mod = t_symmetric[1][sym_index]
      (12 / mod).times do |i|
        real_root << (((fake_root + t_adjust_root[t_index])% mod) + (mod * i)).to_s(12)
      end
    else
      real_root = ((t_adjust_root[t_index] + fake_root) % 12).to_s(12)
    end
    return real_root, t_names[t_index]
  end
end
