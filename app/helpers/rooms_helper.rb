module RoomsHelper
  def country_gradient(country_code)
    {
      "IN"  => "from-blue-600 to-white",        #  India – classic blue
      "AU"  => "from-yellow-400 to-white",      #  Australia – gold
      "ENG" => "from-sky-600 to-white",         #  England – light blue (distinct from reds)
      "SA"  => "from-green-700 to-white",       #  South Africa – dark green
      "PAK" => "from-emerald-500 to-white",     #  Pakistan – emerald green
      "SL"  => "from-blue-900 to-white",        #  Sri Lanka – deep blue
      "BAN" => "from-lime-600 to-white",        #  Bangladesh – lime green
      "WI"  => "from-rose-700 to-white",        #  West Indies – maroon
      "AFG" => "from-orange-600 to-white",      #  Afghanistan – orange (unique)
      "NZ"  => "from-gray-800 to-white"         #  New Zealand – black/gray
    }[country_code] || "from-gray-200 to-white"
  end

  def country_button_style(country_code)
    {
      "IN"  => "bg-blue-600 hover:bg-blue-700 text-white",
      "AU"  => "bg-yellow-400 hover:bg-yellow-500 text-black",
      "ENG" => "bg-sky-600 hover:bg-sky-700 text-white",
      "SA"  => "bg-green-700 hover:bg-green-800 text-white",
      "PAK" => "bg-emerald-600 hover:bg-emerald-700 text-white",
      "SL"  => "bg-blue-800 hover:bg-blue-900 text-white",
      "BAN" => "bg-lime-600 hover:bg-lime-700 text-black",
      "WI"  => "bg-rose-700 hover:bg-rose-800 text-white",
      "AFG" => "bg-orange-600 hover:bg-orange-700 text-white",
      "NZ"  => "bg-gray-800 hover:bg-gray-900 text-white"
    }[country_code] || "bg-gray-500 hover:bg-gray-600 text-white"
  end

  def country_flag(country_code)
    {
      "IN"  => "🇮🇳",
      "AU"  => "🇦🇺",
      "ENG" => "🇫🇴",
      "SA"  => "🇿🇦",
      "PAK" => "🇵🇰",
      "SL"  => "🇱🇰",
      "BAN" => "🇧🇩",
      "WI"  => "🌴",
      "AFG" => "🇦🇫",
      "NZ"  => "🇳🇿"
    }[country_code] || ""
  end

end
