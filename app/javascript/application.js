// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "chartkick"
import "Chart.bundle"


document.addEventListener("turbo:render", (e) => {
  createTeam()
})

createTeam()


function createTeam() {
  let create_team_button = document.getElementById("create_team_button")

  if (create_team_button) {
    create_team_button.addEventListener("click", (e) => {
      let all_players = []
      let players = document.getElementsByClassName("player_shuffle")
      if (players) {
        Array.from(players).map(p => {
          if(p.checked){
            all_players.push(p.dataset.playerName);
          }
        })
  
        // console.log(all_players);
  
        all_players = all_players.sort(() => Math.random() - 0.5)
        all_players = all_players.sort(() => Math.random() - 0.5)
        all_players = all_players.sort(() => Math.random() - 0.5)
        all_players = all_players.sort(() => Math.random() - 0.5);
  
        // Split players into two teams
        let mid = Math.ceil(all_players.length / 2);
        let team1Players = all_players.slice(0, mid);
        let team2Players = all_players.slice(mid);
  
        // Get the team divs
        let team1 = document.getElementById("team1");
        let team2 = document.getElementById("team2");
  
        // Show the players in each team
        team1.innerHTML = team1Players.map(player => `<div>${player}</div>`).join('');
        team2.innerHTML = team2Players.map(player => `<div>${player}</div>`).join('');
        
      }
    })
  
  }
}