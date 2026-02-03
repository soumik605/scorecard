import "@hotwired/turbo-rails"
import "controllers"
import "chartkick"
import "Chart.bundle"







function initTeamCreator() {
  const button = document.getElementById("create_team_button");
  if (!button) return;

  button.addEventListener("click", (e) => {
    e.preventDefault();
    
    // Parse the JSON data from checkboxes
    const selectedData = Array.from(document.querySelectorAll(".player_shuffle:checked"))
      .map(cb => JSON.parse(cb.value));

    if (selectedData.length < 2) {
      alert("Select at least 2 players");
      return;
    }

    // Show results area and scroll to top
    const resultsArea = document.getElementById("results-area");
    resultsArea.classList.remove("hidden");
    window.scrollTo({ top: 0, behavior: 'smooth' });

    // Reset UI
    document.getElementById("team1").innerHTML = "";
    document.getElementById("team2").innerHTML = "";
    document.getElementById("common").innerHTML = "";
    document.getElementById("common-container").classList.add('hidden');

    shuffle(selectedData);

    let commonPlayer = (selectedData.length % 2 !== 0) ? selectedData.pop() : null;
    let teamSize = selectedData.length / 2;

    placeWithPhotoAnimation(selectedData, teamSize, (teamA, teamB) => {
      if (commonPlayer) {
        document.getElementById("common-container").classList.remove('hidden');
        document.getElementById("common").innerHTML = `
          <img src="/assets/${commonPlayer.photo}" class="w-16 h-16 rounded-full border-4 border-white/30 shadow-lg fade-in">
          <div class="font-bold fade-in">${commonPlayer.name}</div>
        `;
      }
    });
  });
}

function placeWithPhotoAnimation(players, teamSize, callback) {
  let teamA = [], teamB = [], index = 0;
  
  const interval = setInterval(() => {
    if (index >= players.length) {
      clearInterval(interval);
      callback(teamA, teamB);
      return;
    }

    const player = players[index];
    // HTML structure for "Name below Photo" in a 3-column grid
    const html = `
      <div class="fade-in flex flex-col items-center text-center">
        <div class="w-16 h-16 sm:w-16 sm:h-16 rounded-full p-0.5 border-2 border-slate-100 shadow-sm bg-white overflow-hidden mb-2">
          <img src="/assets/${player.photo}" class="w-full h-full rounded-full object-cover">
        </div>
        <span class="text-[10px] font-black text-slate-600 leading-tight uppercase tracking-tighter w-full truncate px-1">
          ${player.name.split(' ')[0]} 
        </span>
      </div>
    `;

    if (teamA.length < teamSize) {
      teamA.push(player);
      document.getElementById("team1").insertAdjacentHTML("beforeend", html);
      document.getElementById("team1-count").innerText = teamA.length;
    } else {
      teamB.push(player);
      document.getElementById("team2").insertAdjacentHTML("beforeend", html);
      document.getElementById("team2-count").innerText = teamB.length;
    }
    index++;
  }, 300);
}

// Helper: Standard Shuffle
function shuffle(arr) {
  for (let i = arr.length - 1; i > 0; i--) {
    let j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
}

document.addEventListener("turbo:load", initTeamCreator);