import { useEffect, useState } from "react";
import axios from "axios";

function App() {
  const [text, setText] = useState("");
  const [notes, setNotes] = useState([]);

  const API = "http://localhost:5000";

  const fetchNotes = async () => {
    try {
      const res = await axios.get(`${API}/notes`);
      setNotes(res.data);
    } catch (error) {
      console.error("Error fetching notes:", error);
    }
  };

  const addNote = async () => {
    if (!text.trim()) return;

    try {
      await axios.post(`${API}/notes`, {
        text,
      });

      setText("");
      fetchNotes();
    } catch (error) {
      console.error("Error adding note:", error);
    }
  };

  useEffect(() => {
    fetchNotes();
  }, []);

  return (
    <div style={{ padding: "20px" }}>
      <h1>Notes App</h1>

      <label htmlFor="note">Enter Note</label>
      <br />

      <input
        id="note"
        name="note"
        type="text"
        value={text}
        onChange={(e) => setText(e.target.value)}
        placeholder="Enter note"
      />

      <button
        onClick={addNote}
        style={{ marginLeft: "10px" }}
      >
        Add
      </button>

      <ul>
        {notes.map((note) => (
          <li key={note._id}>{note.text}</li>
        ))}
      </ul>
    </div>
  );
}

export default App;