document.addEventListener("DOMContentLoaded", () => {
    const submitButton = document.getElementById("submit-btn");
    const attendanceDropdown = document.getElementById("attendance");
    const guestsDropdown = document.getElementById("guests");

    attendanceDropdown.addEventListener("change", function () {
        document.getElementById("guest-selection").style.display = this.value === "yes" ? "block" : "none";
    });

    submitButton.addEventListener("click", async () => {
        const name = document.getElementById("name").value;
        const attending = attendanceDropdown.value;
        const guests = attending === "yes" ? guestsDropdown.value : "0";

        if (!name || !attending) {
            alert("Please fill out all fields.");
            return;
        }

        const rsvpData = { name, attending, guests };

        try {
            const response = await fetch("https://1hzxscjflh.execute-api.us-east-1.amazonaws.com/prod/rsvp", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(rsvpData),
            });

            if (response.ok) {
                alert("RSVP Submitted! Thank you.");
            } else {
                alert("Submission failed. Please try again.");
            }
        } catch (error) {
            console.error("Error submitting RSVP:", error);
            alert("An error occurred. Please try again later.");
        }
    });
});
