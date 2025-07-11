json.status "success"
json.message ""
json.data do
  json.head_to_head @head_to_head
  json.players @players
end