// const mongoose = require("mongoose");


// const connection = mongoose.createConnection('mongodb://localhost:27017/login').on('open',()=>{
//     console.log("MongoDb connected");
// }).on('error',()=>{
//     console.log("MongoDb connection Error");
// });

// module.exports = connection;


const mongoose = require('mongoose');

const connection = mongoose.createConnection(`mongodb://127.0.0.1:27017/ToDoDB`).on('open',()=>{console.log("MongoDB Connected");}).on('error',()=>{
    console.log("MongoDB Connection error");
});

module.exports = connection;