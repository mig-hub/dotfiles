module Compta

  def float_to_price f
    ( f * 100 ).floor
  end

  def price_to_string p, style=:regular
    str = p.to_s.sub( /(\d\d)$/, '.\1' )
    case style
    when :no_zero_cents
      str.sub( '.00', '' )
    else
      str
    end
  end

  QUARTERS = {
    '01' => 'Q1', '02' => 'Q1', '03' => 'Q1',
    '04' => 'Q2', '05' => 'Q2', '06' => 'Q2',
    '07' => 'Q3', '08' => 'Q3', '09' => 'Q3',
    '10' => 'Q4', '11' => 'Q4', '12' => 'Q4',
  }.freeze

  def quarter_for_date date
    year, month, day = date.split '-'
    "#{ year } #{ QUARTERS[month] }"
  end

  def truncate str, length
    if str.length <= length
      str.ljust length, ' '
    else
      "#{ str.slice( 0..( length - 2 ) ) }…"
    end
  end

end
