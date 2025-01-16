if @tours.present?
  json.status "success"
  json.message ""
  json.data @tours, partial: 'api/tournaments/tour', as: :tour
end
