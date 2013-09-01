class LegalChords
  def initialize(rule)
    @rule = rule
    @legal_ics = Array.new
  end

  def createLegalChords # creates array of which chords are legal
    if @rule < 5 # tonal chords
      superset_ics = [345, 354, 2334, 2343, 2433, 336, 444, 3333, 1344, 1434, 1443, 246, 2424]
      case @rule
      when 0
        @legal_ics = superset_ics[0, 5]
      when 1, 2
        @legal_ics = superset_ics[0, 8]
      when 3, 4
        @legal_ics = superset_ics[0, 11]
      else
      end
      [11, 12].each { |i| @legal_ics.push(superset_ics[i]) } if [2, 4].include?(@rule)
    elsif @rule == 5 # octatonic membership
      @legal_ics = [129, 138, 156, 237, 246, 336, 345, 1218, 1236, 1245, 1326, 1335, 1515,
        1272, 1263, 2334, 2424, 1353, 2343, 3333]
    elsif @rule == 6 # hexatonic and whole-tone
      @legal_ics = [138, 147, 228, 246, 345, 444, 1317, 1344, 1434, 2226, 2244, 2424, 1353]
    end
    return @legal_ics
  end
end
