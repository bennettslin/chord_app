  def getPrimeForm(this_chord)

    @this_chord = this_chord

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

# running code

def makeMap # make mod-120 hexagonal grid using 2-axis coordinates
  map = Array.new
    (-3..3).each do |q| # (q,r)
      if q > 0

      ((q - 3)..3).each do |r|
        if q > 0
    end
end
