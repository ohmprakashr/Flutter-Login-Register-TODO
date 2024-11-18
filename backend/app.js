// const express = require("express");
// const body_parser = require("body-parser");
// const userRouter = require("./routers/user.routers");

// const app = express();

// app.use(body_parser.json());

// app.use('/',userRouter);

// module.exports = app;

const express = require("express");
const bodyParser = require("body-parser");
const UserRoute = require("./routers/user.routs");
const ToDoRoute = require('./routers/todo.routers');
const app = express();

app.use(bodyParser.json());

app.use("/",UserRoute);
app.use("/",ToDoRoute);

module.exports = app;