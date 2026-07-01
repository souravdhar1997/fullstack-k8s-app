const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config();

const Note = require("./models/Note");

const app = express();

app.use(cors());
app.use(express.json());

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("MongoDB Connected"))
  .catch((err) => console.log(err));

app.get("/", (req, res) => {
  res.send("Backend Running");
});

app.get("/notes", async (req, res) => {
  const notes = await Note.find();
  res.json(notes);
});

app.post("/notes", async (req, res) => {
  const note = new Note({
    text: req.body.text,
  });
  await note.save();
  res.json(note);
});

app.get("/health/live", (req, res) => {
    res.status(200).json({
        status: "alive"
    });
});

app.get("/health/ready", async (req, res) => {
    try {
        await mongoose.connection.db.admin().ping();
        res.status(200).json({
            status: "ready"
        });
    } catch (error) {
        res.status(500).json({
            status: "not ready"
        });
    }
});

app.listen(process.env.PORT, () => {
  console.log(`Server running on port ${process.env.PORT}`);
});