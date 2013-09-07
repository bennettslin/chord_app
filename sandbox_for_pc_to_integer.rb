  @legal_chords = [345, 354, 2334, 2343, 2433, 336, 444, 3333, 1344, 1434, 1443, 246, 2424]
  @legal_incompletes = [264, 237, 336, 273, 246, 174, 138, 147, 183]





print returnRandomSonority(3)



  def returnRandomSonority(card) # accepts a cardinal value
    sonority = Array.new
    until sonority.count == card
      temp_pc = rand(12).to_s(12)
      sonority << temp_pc unless sonority.include?(temp_pc)
    end
    return sonority.join("")
  end

  def testRandomSonorities(sample_size)
    # for dev purposes, returns probability of given sonorities
    # being able to form legal chords or incompletes
    tally_of_legal_chords = Array.new(@legal_chords.count){ 0 }
    tally_of_legal_incompletes = Array.new(@legal_incompletes.count){ 0 }
    illegal_sonorities = 0
    sample_size.times do |i|
      icp_form, fake_root = getICPrimeForm(returnRandomSonority(3))
      if isThisSonorityLegal?(icp_form, @legal_chords)
        index = @legal_chords.index icp_form
        tally_of_legal_chords[index] += 1
      elsif isThisSonorityLegal?(icp_form, @legal_incompletes)
        index = @legal_incompletes.index icp_form
        tally_of_legal_incompletes[index] += 1
      else
        illegal_sonorities += 1
      end
    end
    print "Legal chords: #{tally_of_legal_chords }\n"
    print "Legal incompletes: #{tally_of_legal_incompletes }\n"
    print "Illegal sonorities: #{illegal_sonorities }\n"
  end


  print testRandomSonorities(500)
