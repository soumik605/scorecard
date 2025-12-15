// app/javascript/controllers/drag_drop_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  drag(event) {
    event.dataTransfer.setData("player_id", event.target.dataset.id);
  }

  allow(event) {
    event.preventDefault();
  }

  drop(event) {
    event.preventDefault();

    const playerId = event.dataTransfer.getData("player_id");
    const teamType = event.currentTarget.dataset.teamType;

    fetch(`/rooms/${playerId}/update_team_type`, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")
          .content,
        "Content-Type": "application/json",
        Accept: "text/vnd.turbo-stream.html, text/html",
      },
      body: JSON.stringify({ team_type: teamType }),
    }).then((response) => {
      if (response.redirected) {
        // Rails redirect → follow it
        window.location.href = response.url;
      } else if (!response.ok) {
        alert("Max 11 players allowed.");
      }
    });
  }
}
