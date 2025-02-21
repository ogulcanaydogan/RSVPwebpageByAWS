document.addEventListener("DOMContentLoaded", () => {
    const yesButton = document.getElementById("yes-btn");
    const noButton = document.getElementById("no-btn");
    const guestsDropdown = document.getElementById("guests");
    const submitButton = document.getElementById("submit-btn");

    let attending = null;

    yesButton.addEventListener("click", () => {
        attending = true;
        guestsDropdown.style.display = "block";
    });

    noButton.addEventListener("click", () => {
        attending = false;
        guestsDropdown.style.display = "none";
    });

    submitButton.addEventListener("click", async () => {
        const guests = attending ? parseInt(document.getElementById("guests").value) : 0;
        
        const response = {
            attending,
            guests
        };

        try {
            const res = await fetch("https://your-api-gateway-url.amazonaws.com/prod/rsvp", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(response),
            });

            if (res.ok) {
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
