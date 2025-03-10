document.addEventListener("DOMContentLoaded", () => {
  const apiUrl = "https://nq0wpuawx5.execute-api.us-east-1.amazonaws.com/prod/rsvp";  // Injected manually for now

  // Automatically display the API URL at the top of the page
  const apiUrlDisplay = document.getElementById("api-url-display");
  if (apiUrlDisplay) {
    apiUrlDisplay.textContent = `API URL: ${apiUrl}`;
  }

  const submitButton = document.getElementById("submit-btn");
  const attendanceDropdown = document.getElementById("attendance");
  const guestsDropdown = document.getElementById("guests");

  attendanceDropdown.addEventListener("change", function () {
    document.getElementById("guest-selection").style.display = this.value === "yes" ? "block" : "none";
  });

  submitButton.addEventListener("click", async () => {
    const name = document.getElementById("name").value.trim();
    const attending = attendanceDropdown.value;
    const guests = attending === "yes" ? guestsDropdown.value : "0";

    if (!name || !attending) {
      alert("Please fill out all fields.");
      return;
    }

    const rsvpData = { name, attending, guests };

    try {
      const response = await fetch(apiUrl, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(rsvpData),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! Status: ${response.status}`);
      }

      alert("RSVP Submitted! Thank you.");
    } catch (error) {
      console.error("Error submitting RSVP:", error);
      alert("Submission failed. Please try again.");
    }
  });
});
