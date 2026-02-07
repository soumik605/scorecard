import "@hotwired/turbo-rails"
import "controllers"
import "chartkick"
import "Chart.bundle"







function initTeamCreator() {
  const button = document.getElementById("create_team_button");
  const resultsArea = document.getElementById("results-area");
  if (!button || !resultsArea) return;

  button.addEventListener("click", (e) => {
    e.preventDefault();
    
    const selectedData = Array.from(document.querySelectorAll(".player_shuffle:checked"))
      .map(cb => JSON.parse(cb.value));

    if (selectedData.length < 2) return alert("Select at least 2 players");

    // Get Points Data from HTML
    const pointsLookup = JSON.parse(resultsArea.getAttribute("data-points"));

    resultsArea.classList.remove("hidden");
    window.scrollTo({ top: 0, behavior: 'smooth' });

    // Reset UI
    document.getElementById("team1").innerHTML = "";
    document.getElementById("team2").innerHTML = "";
    document.getElementById("team1-strength").innerText = "Strength: 0";
    document.getElementById("team2-strength").innerText = "Strength: 0";
    document.getElementById("strength-badge").classList.add("hidden");

    shuffle(selectedData);
    let commonPlayer = (selectedData.length % 2 !== 0) ? selectedData.pop() : null;
    let teamSize = selectedData.length / 2;

    let team1Points = 0;
    let team2Points = 0;

    placeWithPhotoAnimation(selectedData, teamSize, pointsLookup, (t1Sum, t2Sum) => {
      // Comparison logic after animation finishes
      const badge = document.getElementById("strength-badge");
      badge.classList.remove("hidden");
      
      const diff = Math.abs(t1Sum - t2Sum);
      
      if (diff < 5) {
        badge.innerText = "⚖️ Balanced Matchup";
        badge.className = "px-4 py-2 rounded-full text-xs font-black uppercase tracking-widest bg-slate-100 text-slate-600";
      } else if (t1Sum > t2Sum) {
        badge.innerText = `🔥 ${document.getElementById("team1-name").innerText} are Favorites`;
        badge.className = "px-4 py-2 rounded-full text-xs font-black uppercase tracking-widest bg-orange-100 text-orange-600";
      } else {
        badge.innerText = `🔥 ${document.getElementById("team2-name").innerText} are Favorites`;
        badge.className = "px-4 py-2 rounded-full text-xs font-black uppercase tracking-widest bg-orange-100 text-orange-600";
      }

      if (commonPlayer) {
        document.getElementById("common-container").classList.remove('hidden');
        document.getElementById("common").innerHTML = `
          <div class="relative">
            <img src="${commonPlayer.photo}" class="w-16 h-16 rounded-full border-4 border-white/20 shadow-lg fade-in">
          </div>
          <div class="font-bold mt-2 fade-in text-xs text-white">${commonPlayer.name}</div>
        `;
      }
    });
  });
}

function placeWithPhotoAnimation(players, teamSize, pointsLookup, callback) {
  console.log("🚀 ~ placeWithPhotoAnimation ~ players:", players)
  console.log("🚀 ~ placeWithPhotoAnimation ~ pointsLookup:", pointsLookup)
  let index = 0;
  let t1Sum = 0;
  let t2Sum = 0;
  let t1Count = 0;
  let t2Count = 0;
  
  const interval = setInterval(() => {
    if (index >= players.length) {
      clearInterval(interval);
      callback(t1Sum, t2Sum);
      return;
    }

    const player = players[index];
    
    console.log("🚀 ~ placeWithPhotoAnimation ~ player:", player)
    console.log("🚀 ~ placeWithPhotoAnimation ~ player.id:", player.id)

    const pPoints = parseFloat(pointsLookup[player.id]) || 0;
    console.log("🚀 ~ placeWithPhotoAnimation ~ pPoints:", pPoints)
    
    const html = `
      <div class="fade-in flex flex-col items-center">
        <div class="w-12 h-12 rounded-full border-2 border-slate-100 overflow-hidden mb-1">
          <img src="${player.photo}" class="w-full h-full object-cover">
        </div>
        <span class="text-[9px] font-bold text-slate-500 truncate w-full text-center">${player.name.split(' ')[0]}</span>
      </div>
    `;

    if (t1Count < teamSize) {
      document.getElementById("team1").insertAdjacentHTML("beforeend", html);
      t1Sum += pPoints;
      t1Count++;
      document.getElementById("team1-count").innerText = t1Count;
      document.getElementById("team1-strength").innerText = `Strength: ${t1Sum.toFixed(1)}`;
    } else {
      document.getElementById("team2").insertAdjacentHTML("beforeend", html);
      t2Sum += pPoints;
      t2Count++;
      document.getElementById("team2-count").innerText = t2Count;
      document.getElementById("team2-strength").innerText = `Strength: ${t2Sum.toFixed(1)}`;
    }
    index++;
  }, 250);
}

// Helper: Standard Shuffle
function shuffle(arr) {
  for (let i = arr.length - 1; i > 0; i--) {
    let j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
}

document.addEventListener("turbo:load", initTeamCreator);