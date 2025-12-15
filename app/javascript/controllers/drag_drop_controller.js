import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.draggedPlayerId = null;
  }

  drag(event) {
    this.draggedPlayerId = event.target.dataset.playerId;
  }

  touchStart(event) {
    this.draggedPlayerId = event.target.dataset.playerId;
  }

  allow(event) {
    event.preventDefault();
  }

  drop(event) {
    event.preventDefault();

    const playerId = this.draggedPlayerId;
    const teamType = event.currentTarget.dataset.teamType;

    if (!playerId) {
      alert("Unable to detect player. Please tap again.");
      return;
    }

    fetch(`/rooms/${playerId}/update_team_type`, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        "Content-Type": "application/json",
        Accept: "text/vnd.turbo-stream.html, text/html",
      },
      body: JSON.stringify({ team_type: teamType }),
    }).then((response) => {
      if (response.redirected) {
        window.location.href = response.url;
      } else if (!response.ok) {
        alert("Max 11 players allowed.");
      }
    });
  }
}
