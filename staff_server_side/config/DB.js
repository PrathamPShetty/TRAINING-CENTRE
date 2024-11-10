require('dotenv').config(); // Load environment variables from .env

const mongoose = require("mongoose");

const connectDB = async () => {
  try {
    // Use the environment variable for the MongoDB URI
    const DB = process.env.DB;

    if (!DB) {
      console.log("MongoDB URI is missing in environment variables.");
      process.exit(1);
    }

    // Connect to MongoDB
    await mongoose.connect(DB);
    console.log("MongoDB Connected");
  } catch (error) {
    console.log("Mongodb connection error:", error);
    process.exit(1);
  }
};

module.exports = connectDB;
