import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      appId: "1:273851780558:android:9a1467b655abe5b64daf9f",
      projectId: "task-management-darsh",
      apiKey: 'AIzaSyCpIUyBbuueYDxem_pkU_ZwhFqC0vdxAcU',
      messagingSenderId: 'task-management-darsh',
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthenticationScreen(),
    );
  }
}

class AuthenticationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentication'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegisterEmailSection()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.orangeAccent,
                ),
                child: Text('Register', style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EmailPasswordForm()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.orangeAccent,
                ),
                child: Text('Sign In', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return user?.email;
    } catch (e) {
      return null;
    }
  }

  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return user?.email;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}

class RegisterEmailSection extends StatefulWidget {
  RegisterEmailSection({Key? key}) : super(key: key);

  @override
  _RegisterEmailSectionState createState() => _RegisterEmailSectionState();
}

class _RegisterEmailSectionState extends State<RegisterEmailSection> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _success = false;
  bool _initialState = true;
  String? _userEmail;

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter an email';
    } else if (!email.endsWith('@gsu.com')) {
      return 'Email must end with @gsu.com';
    }
    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter a password';
    } else if (password.length < 6) {
      return 'Password should be at least 6 characters long';
    }
    return null;
  }

  void _register() async {
    String? email = await _authService.registerWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
    );
    setState(() {
      _success = email != null;
      _userEmail = email;
      _initialState = false;
    });

    if (_success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => TaskManagementScreen(email: _userEmail!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.orangeAccent),
                  border: OutlineInputBorder(),
                ),
                validator: _validateEmail,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.orangeAccent),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: _validatePassword,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _register();
                    }
                  },
                  child: Text('Register', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  _initialState
                      ? 'Please Register'
                      : _success
                          ? 'Successfully registered $_userEmail'
                          : 'Registration failed',
                  style: TextStyle(color: _success ? Colors.green : Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailPasswordForm extends StatefulWidget {
  EmailPasswordForm({Key? key}) : super(key: key);

  @override
  _EmailPasswordFormState createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<EmailPasswordForm> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _success = false;
  bool _initialState = true;
  String _userEmail = '';

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter an email';
    } else if (!email.endsWith('@gsu.com')) {
      return 'Email must end with @gsu.com';
    }
    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter a password';
    } else if (password.length < 6) {
      return 'Password should be at least 6 characters long';
    }
    return null;
  }

  void _signInWithEmailAndPassword() async {
    String? email = await _authService.signInWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
    );
    setState(() {
      _success = email != null;
      _userEmail = email ?? '';
      _initialState = false;
    });

    if (_success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => TaskManagementScreen(email: _userEmail)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.orangeAccent),
                  border: OutlineInputBorder(),
                ),
                validator: _validateEmail,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.orangeAccent),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: _validatePassword,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _signInWithEmailAndPassword();
                    }
                  },
                  child: Text('Sign In', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  _initialState
                      ? 'Please Sign In'
                      : _success
                          ? 'Successfully signed in $_userEmail'
                          : 'Sign In failed',
                  style: TextStyle(color: _success ? Colors.green : Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskManagementScreen extends StatefulWidget {
  final String email;

  TaskManagementScreen({Key? key, required this.email}) : super(key: key);

  @override
  _TaskManagementScreenState createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  TextEditingController _taskController = TextEditingController();
  TextEditingController _dayController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addTask() async {
    if (_taskController.text.isEmpty ||
        _dayController.text.isEmpty ||
        _timeController.text.isEmpty) {
      return;
    }

    await _firestore.collection('tasks').add({
      'task': _taskController.text,
      'user': widget.email,
      'completed': false,
      'day': _dayController.text,
      'time': _timeController.text,
    });

    _taskController.clear();
    _dayController.clear();
    _timeController.clear();
  }

  void _deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  void _toggleCompletion(String taskId, bool currentStatus) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'completed': !currentStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _taskController,
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  labelStyle: TextStyle(color: Colors.orangeAccent),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _dayController,
                decoration: InputDecoration(
                  labelText: 'Day (e.g. Monday)',
                  labelStyle: TextStyle(color: Colors.orangeAccent),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _timeController,
                decoration: InputDecoration(
                  labelText: 'Time (e.g. 9 am - 10 am)',
                  labelStyle: TextStyle(color: Colors.orangeAccent),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: _addTask,
              child: Text('Add Task'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.orangeAccent,
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('tasks')
                    .where('user', isEqualTo: widget.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No tasks available.'));
                  }

                  var tasks = snapshot.data!.docs;
                  Map<String, Map<String, List<DocumentSnapshot>>>
                      groupedTasks = {};

                  for (var task in tasks) {
                    String day = task['day'];
                    String time = task['time'];

                    if (!groupedTasks.containsKey(day)) {
                      groupedTasks[day] = {};
                    }
                    if (!groupedTasks[day]!.containsKey(time)) {
                      groupedTasks[day]![time] = [];
                    }
                    groupedTasks[day]![time]!.add(task);
                  }

                  return ListView.builder(
                    itemCount: groupedTasks.keys.length,
                    itemBuilder: (context, index) {
                      String day = groupedTasks.keys.elementAt(index);
                      var timeFrames = groupedTasks[day]!;

                      return ExpansionTile(
                        title: Text(
                          day,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        children: timeFrames.keys.map((time) {
                          var timeTasks = timeFrames[time]!;
                          return ExpansionTile(
                            title: Text(
                              time,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            children: timeTasks.map((task) {
                              bool isCompleted = task['completed'] ?? false;
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                elevation: 4,
                                color: isCompleted ? Colors.green[100] : null,
                                child: ListTile(
                                  title: Text(task['task'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: isCompleted,
                                        onChanged: (value) {
                                          _toggleCompletion(
                                              task.id, isCompleted);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () => _deleteTask(task.id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
