import React from 'react';
import ReactDOM from 'react-dom';
import { useState } from "react";
import { motion } from "framer-motion";
import "./styles.css";

export default function RSVPForm() {
  const [attending, setAttending] = useState(null);
  const [guests, setGuests] = useState(1);

  const handleSubmit = () => {
    const response = {
      attending,
      guests: attending ? guests : 0,
    };
    console.log("RSVP Response:", response);
    alert("RSVP Submitted! Thank you.");
  };

  return (
    <div className="container">
      <motion.div
        className="rsvp-card"
        initial={{ opacity: 0, y: 50 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <h2 className="title">Wedding RSVP</h2>
        <p className="question">Will you be attending?</p>
        <div className="button-group">
          <button 
            className={attending === true ? "btn selected" : "btn"} 
            onClick={() => setAttending(true)}
          >
            Yes
          </button>
          <button 
            className={attending === false ? "btn selected" : "btn"} 
            onClick={() => setAttending(false)}
          >
            No
          </button>
        </div>
        {attending && (
          <div className="dropdown-container">
            <label className="label">How many people?</label>
            <select className="dropdown" onChange={(e) => setGuests(parseInt(e.target.value))}>
              <option value="1">1</option>
              <option value="2">2</option>
            </select>
          </div>
        )}
        <button className="submit-btn" onClick={handleSubmit} disabled={attending === null}>
          Submit RSVP
        </button>
      </motion.div>
    </div>
  );
}