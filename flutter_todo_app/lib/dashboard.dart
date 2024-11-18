import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import 'config.dart'; // Add this if you haven't already
import 'package:flutter_slidable/flutter_slidable.dart';

class Dashboard extends StatefulWidget {
  final String token;

  const Dashboard({required this.token, Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String userId;
  TextEditingController _todoTitle = TextEditingController();
  TextEditingController _todoDesc = TextEditingController();
  List<dynamic>? items;

  @override
  void initState() {
    super.initState();
    // Decode the JWT token to extract the user ID
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    getTodoList(userId);
  }

  // Function to add a new to-do item
  void addTodo() async {
    if (_todoTitle.text.isNotEmpty && _todoDesc.text.isNotEmpty) {
      var regBody = {
        "userId": userId,
        "title": _todoTitle.text,
        "desc": _todoDesc.text,
      };

      var response = await http.post(Uri.parse(addtodo),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status']) {
        _todoDesc.clear();
        _todoTitle.clear();
        Navigator.pop(context);
        getTodoList(userId); // Refresh the list
      } else {
        print("Something went wrong");
      }
    }
  }

  // Function to get the list of to-do items for the user
  void getTodoList(String userId) async {
    var regBody = {"userId": userId};

    var response = await http.post(Uri.parse(getToDoList),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody));

    var jsonResponse = jsonDecode(response.body);
    setState(() {
      items = jsonResponse['success'];
    });
  }

  // Function to delete a to-do item
  void deleteItem(String id) async {
    var regBody = {"id": id};

    var response = await http.post(Uri.parse(deleteTodo),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody));

    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      getTodoList(userId); // Refresh the list after deletion
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.only(
                top: 60.0, left: 30.0, right: 30.0, bottom: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  child: Icon(
                    Icons.list,
                    size: 30.0,
                  ),
                  backgroundColor: Colors.white,
                  radius: 30.0,
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'HELLO YOUR ORDER',
                  style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8.0),
                Text(
                  '${items?.length ?? 0} Task(s)',
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          // To-Do List section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: items == null
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: items!.length,
                  itemBuilder: (context, int index) {
                    return Slidable(
                      key: ValueKey(items![index]['_id']),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        dismissible: DismissiblePane(onDismissed: () {}),
                        children: [
                          SlidableAction(
                            backgroundColor: const Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                            onPressed: (BuildContext context) {
                              deleteItem(items![index]['_id']);
                            },
                          ),
                        ],
                      ),
                      child: Card(
                        borderOnForeground: false,
                        child: ListTile(
                          leading: const Icon(Icons.task),
                          title: Text('${items![index]['title']}'),
                          subtitle: Text('${items![index]['desc']}'),
                          trailing: const Icon(Icons.arrow_back),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      // Floating button to add a new to-do item
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayTextInputDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Add To-Do',
      ),
    );
  }

  // Dialog to add a new to-do item
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add To-Do'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _todoTitle,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Title",
                      border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10.0)))),
                ).p4().px8(),
                TextField(
                  controller: _todoDesc,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Description",
                      border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10.0)))),
                ).p4().px8(),
                ElevatedButton(
                  onPressed: addTodo,
                  child: const Text("Add"),
                ),
              ],
            ),
          );
        });
  }
}
