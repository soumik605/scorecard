module TournamentsHelper

  def getResultClass cap_a_id, cap_b_id, win_cap_id
    cls = ""
    if win_cap_id.present?
      if cap_a_id == win_cap_id
        cls = "bg-gradient-to-r from-green-500 via-white to-red-500"
      elsif cap_b_id == win_cap_id
        cls = "bg-gradient-to-r from-red-500 via-white to-green-500"
      end
    end

    return cls
  end

end
