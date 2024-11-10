const mongoose = require("mongoose");

const connectDB = async () => {
  try {
    
    const DB ='mongodb+srv://emergency:emergency@prathampshetty99sai.j4iophu.mongodb.net/trainingcentre?retryWrites=true&w=majority';
   await mongoose.connect(DB);

    console.log(`MongoDB Connected`);
  } catch (error) {
    console.log("Mongodb connection error", error);
    process.exit(1);
  }
};

module.exports = connectDB;
