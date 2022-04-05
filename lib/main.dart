import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'package:like_button/like_button.dart';
import "dart:math";

/* api exception handling! */
//check posting
//splash page later
class backendFunction {
  static Future<http.Response> httpget(link) async {
    final response = await http.get(link, headers: {"Access-Control-Allow-Origin": "*"});
    return response;
  }

  static List<Widget> appbaritems(context) {
    if (!mapEquals(userdict, {})) {
      return <Widget>[
        TextButton(
          style: TextButton.styleFrom(primary: Color(0xFF18c900)),
          onPressed: () {
            _badgesPopup(context);
          },
          child: const Text('Badges'),
        ),
        TextButton(
          style: TextButton.styleFrom(primary: Color(0xFF18c900)),
          onPressed: () {
            userdict = {};
            sp.setString("userdict", jsonEncode({}));
            html.window.location.reload();
          },
          child: const Text('Sign Out'),
        )
      ];
    } else {
      return <Widget>[
        TextButton(
          style: TextButton.styleFrom(primary: Color(0xFF18c900)),
          onPressed: () {
            _loginPopup(context);
          },
          child: const Text('Log In'),
        ),
        TextButton(
          style: TextButton.styleFrom(primary: Color(0xFF18c900)),
          onPressed: () {
            _signupPopup(context);
          },
          child: const Text('Sign Up'),
        )
      ];
    }
  }

  static Future<bool> getEventsAndPosts() async {
    var url1 =
        "https://postmanhack.pythonanywhere.com/placeholder/dfka12kflkk99j/posts/getposts";
    var response = await httpget(Uri.parse(url1));
    if (response.statusCode != 200) {
      print(response.statusCode);
      return false;
    }
    var data = jsonDecode(response.body);
    if (data["status"] == "failed") {
      return false;
    }
    posts = data;
    posts["data"] = List<Map>.from(posts["data"]);

    var url2 =
        "https://postmanhack.pythonanywhere.com/placeholder/dfka12kflkk99j/eventlist/events";
    var response1 = await httpget(Uri.parse(url2));
    if (response1.statusCode != 200) {
      print(response1.statusCode);
      return false;
    }
    var data1 = jsonDecode(response1.body);
    if (data1["status"] == "failed") {
      return false;
    }
    events = data1;
    events["data"] = List<Map>.from(events["data"]);
    return true;
  }

  static Future<bool> getEventsother() async {
    var url1 =
        "https://postmanhack.pythonanywhere.com/placeholder/dfka12kflkk99j/other/volunteerapi";
    var response = await httpget(Uri.parse(url1));
    if (response.statusCode != 200) {
      print(response.statusCode);
      return false;
    }
    eventsother = jsonDecode(response.body);
    eventsother = List<Map>.from(eventsother);
    return true;
  }

  static Future<bool> login(u) async {
    var url1 =
        "https://postmanhack.pythonanywhere.com/placeholder/dfka12kflkk99j/userinfo/login?username=" +
            u;
    var response = await httpget(Uri.parse(url1));
    if (response.statusCode != 200) {
      print(response.statusCode);
    }
    userdict = jsonDecode(response.body)["data"];
    if (jsonDecode(response.body)["status"] == "failed") {
      return false;
    }
    sp.setString("userdict", jsonEncode(userdict));
    return true;
  }

  static Future<bool> signup(u) async {
    var url1 =
        "https://postmanhack.pythonanywhere.com/placeholder/dfka12kflkk99j/userinfo/newuser";
    var response = await http.post(Uri.parse(url1), body: {"username": u}, headers: {"Access-Control-Allow-Origin": "*"});
    if (response.statusCode != 200) {
      print(response.statusCode);
    }
    return true;
  }

  static Future<bool> volunteer(index) async {
    var url1 =
        "https://postmanhack.pythonanywhere.com/placeholder/dfka12kflkk99j/interestedvolunteer/interest";
    var response = await http.post(Uri.parse(url1), headers: {"Access-Control-Allow-Origin": "*"}, body: {
      "userid": userdict["userid"].toString(),
      "eid": events["data"][index]["eid"].toString()
    });
    if (response.statusCode != 200) {
      print(response.statusCode);
    }
    return true;
  }

  static Future<bool> post(index, content) async {
    var url1 =
        "https://postmanhack.pythonanywhere.com/placeholder/dfka12kflkk99j/posts/post";
    var response = await http.post(Uri.parse(url1), headers: {"Access-Control-Allow-Origin": "*"}, body: {
      "posteruserid": userdict["userid"].toString(),
      "eid_ref": events["data"][index]["eid"].toString(),
      "content": content
    });
    if (response.statusCode != 200) {
      print(response.statusCode);
    }
    return true;
  }

  static Future<List<Map>> getComments(index) async {
    var url1 =
        "https://postmanhack.pythonanywhere.com/placeholder/dfka12kflkk99j/comments/getcomments?pid=" +
            posts["data"][index]["pid"].toString();
    var response = await httpget(Uri.parse(url1));
    if (response.statusCode != 200) {
      print(response.statusCode);
    }
    var data = jsonDecode(response.body);
    data = List<Map>.from(data["data"]);
    return data;
  }

  static Future<List<Map>> getBadges() async {
    var url1 =
        "https://postmanhack.pythonanywhere.com/placeholder/dfka12kflkk99j/interestedvolunteer/events?userid=" +
            userdict["userid"].toString();
    var response = await httpget(Uri.parse(url1));
    if (response.statusCode != 200) {
      print(response.statusCode);
    }
    var data = jsonDecode(response.body);
    data = List<Map>.from(data["data"]);
    return data;
  }

  static Future getNews() async {
    var url1 =
        "https://postmanhack.pythonanywhere.com/placeholder/dfka12kflkk99j/other/newsapi";
    var response = await httpget(Uri.parse(url1));
    if (response.statusCode != 200) {
      print(response.statusCode);
    }
    news = jsonDecode(response.body);
    news = List<Map>.from(news["articles"]);
    return news;
  }

  static Future<bool> sendComment(index, comment) async {
    var url1 =
        "https://postmanhack.pythonanywhere.com/placeholder/dfka12kflkk99j/comments/comment";
    var response = await http.post(Uri.parse(url1), headers: {"Access-Control-Allow-Origin": "*"}, body: {
      "pid": posts["data"][index]["pid"].toString(),
      "commentuserid": userdict["userid"].toString(),
      "comment": comment
    });
    if (response.statusCode != 200) {
      print(response.statusCode);
    }
    return true;
  }

  static findIndex(eid) {
    for (int i = 0; i < events["data"].length; i++) {
      if (eid == events["data"][i]["eid"]) {
        return i;
      }
    }
  }
}

var sp;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sp = await SharedPreferences.getInstance();
  runApp(new MyApp());
}

var userdict = jsonDecode(sp.getString("userdict") ?? jsonEncode({}));
var posts;
var events;
var eventsother;
var news;
var colours = [Colors.brown, Colors.red, Colors.cyan, Colors.yellow];
final _random = new Random();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const MyStatefulWidget(),
      },
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final List<String> entries = <String>['A', 'B', 'C'];
  final List<int> colorCodes = <int>[600, 500, 100];

  var _ep, _eo, _n;
  @override
  initState() {
    super.initState();
    _ep = backendFunction.getEventsAndPosts();
    _eo = backendFunction.getEventsother();
    _n = backendFunction.getNews();
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        TextButton.styleFrom(primary: Theme.of(context).colorScheme.onPrimary);
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              html.window.location.reload();
            },
            child: Icon(Icons.home)),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF18c900),
        title: const Center(
            child: Image(
                height: 32, fit: BoxFit.cover, image: NetworkImage("https://postmanhack.pythonanywhere.com/placeholder/dfka12kflkk99j/image/logo.png"))),
        actions: backendFunction.appbaritems(context),
      ),
      body: Row(children: <Widget>[
        Expanded(
            flex: 1,
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(children: <Widget>[
                  Expanded(
                      flex: 40,
                      child: Container(
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 10,
                                    offset: Offset(4, 10))
                              ],
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Text(
                              "Who Are We?\n\nSocial - A truly 'Social' social network.\n\n\nSocial is the first network that creates a public forum for people to find volunteering opportunities, raise public awareness and donate to good causes."))),
                  SizedBox(height: 25),
                  Expanded(
                      flex: 60,
                      child: Container(
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 10,
                                    offset: Offset(4, 10))
                              ],
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: FutureBuilder(
                              future: _n,
                              builder: (context, AsyncSnapshot snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else {
                                  return Container(
                                      child: ListView.builder(
                                          controller: ScrollController(),
                                          itemCount: news.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return InkWell(
                                                onTap: () {
                                                  html.window.open(
                                                      news[index]["url"],
                                                      'new tab');
                                                },
                                                child: Container(
                                                    padding: EdgeInsets.all(5),
                                                    child: Column(children: [
                                                      Row(children: [
                                                        Expanded(
                                                            flex: 20,
                                                            child: Container(
                                                                child: Image
                                                                    .network(news[
                                                                            index]
                                                                        [
                                                                        "urlToImage"]))),
                                                        SizedBox(width: 2),
                                                        Expanded(
                                                            flex: 80,
                                                            child: Text(news[
                                                                            index]
                                                                        [
                                                                        "title"]
                                                                    .substring(
                                                                        0,
                                                                        news[index]["title"].length >
                                                                                17
                                                                            ? 17
                                                                            : news[index]["title"].length) +
                                                                "..."))
                                                      ]),
                                                      Divider()
                                                    ])));
                                          }));
                                }
                              })))
                ]))),
        Expanded(
          flex: 3,
          child: FutureBuilder(
              future: _ep,
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  if (!snapshot.data) {
                    return Center(
                        child: Text(
                            "Could Not Retrieve Posts... Try again later."));
                  }
                  return Container(
                      child: ListView.builder(
                          controller: ScrollController(),
                          padding: const EdgeInsets.all(8),
                          itemCount: posts["data"].length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: EdgeInsets.all(10),
                              child: Container(
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 3,
                                            blurRadius: 10,
                                            offset: Offset(4, 10))
                                      ],
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  height:
                                      MediaQuery.of(context).size.height / 1.5,
                                  child: Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Column(children: [
                                        Row(children: [
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 7, 0),
                                            child: CircleAvatar(
                                                backgroundColor: colours[_random
                                                    .nextInt(colours.length)],
                                                child: Text(posts["data"][index]
                                                        ["username"]
                                                    .substring(0, 2)
                                                    .toUpperCase())),
                                          ),
                                          RichText(
                                              text: TextSpan(
                                                  text: posts["data"][index]
                                                      ["username"],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)))
                                        ]),
                                        Divider(color: Colors.black),
                                        Flexible(
                                            child: Text(posts["data"][index]
                                                ["content"])),
                                        Divider(color: Colors.grey),
                                        Text(posts["data"][index]["username"] +
                                            " shared an event: " +
                                            events["data"][backendFunction
                                                .findIndex(posts["data"][index]
                                                    ["eid_ref"])]["eventname"]),
                                        InkWell(
                                            onTap: () {
                                              _eventPopup(
                                                  context,
                                                  backendFunction.findIndex(
                                                      posts["data"][index]
                                                          ["eid_ref"]));
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2.5,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image:
                                                      NetworkImage("https://postmanhack.pythonanywhere.com/placeholder/dfka12kflkk99j/image/asdadas.png"),
                                                ),
                                              ),
                                            )),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 20, 0, 0),
                                            child: Row(children: [
                                              Expanded(
                                                  flex: 10,
                                                  child: LikeButton()),
                                              Expanded(
                                                  flex: 90,
                                                  child: InkWell(
                                                      onTap: () {
                                                        _commentPopup(
                                                            context, index);
                                                      },
                                                      child: Row(children: [
                                                        Icon(Icons.comment),
                                                        Text("Comment")
                                                      ])))
                                            ]))
                                      ]))),
                            );
                          }));
                }
              }),
        ),
        Expanded(
            child: Column(children: [
          Expanded(
              child: FutureBuilder(
                  future: _ep,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      if (!snapshot.data) {
                        return Center(
                            child: Text(
                                "Could Not Retrieve Events... Try again later."));
                      }
                      return Container(
                          child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: events["data"].length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                                    child: InkWell(
                                        onTap: () {
                                          _eventPopup(context, index);
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: Color(0xFF18c900))),
                                            child: Row(children: [
                                              Icon(Icons.event),
                                              Text(events["data"][index]
                                                  ["eventname"])
                                            ]))));
                              }));
                    }
                  })),
          Expanded(
              child: FutureBuilder(
                  future: _eo,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      if (!snapshot.data) {
                        return Center(
                            child: Text(
                                "Could Not Retrieve Exernal Events... Try again later."));
                      }
                      return Container(
                          child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: eventsother.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                                    child: InkWell(
                                        onTap: () {
                                          html.window.open(
                                              eventsother[index]["link"],
                                              'new tab');
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: Color(0xFF18c900))),
                                            child: Row(children: [
                                              Icon(Icons.link),
                                              Text(eventsother[index]
                                                          ["eventname"]
                                                      .substring(
                                                          0,
                                                          eventsother[index][
                                                                          "eventname"]
                                                                      .length >
                                                                  20
                                                              ? 20
                                                              : eventsother[index]
                                                                          [
                                                                          "eventname"]
                                                                      .length -
                                                                  1) +
                                                  "...")
                                            ]))));
                              }));
                    }
                  }))
        ]))
      ]),
    );
  }
}

_postPopup(context, i, msg) {
  var postc = TextEditingController();

  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(children: [
                  Flexible(child: Text(msg)),
                  Divider(color: Colors.black),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                          maxLines: null,
                          controller: postc,
                          decoration: InputDecoration(
                            labelText: 'Post *',
                          ))),
                  ElevatedButton(
                      onPressed: () {
                        backendFunction.post(i, postc.text).then((a){
                        Navigator.of(context).pop();
                        html.window.location.reload();
                        });},
                      child: Text("Post"))
                ])));
      });
}

_eventPopup(context, i) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Flexible(child: Text(events["data"][i]["eventname"])),
              InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    if (mapEquals(userdict, {})){_signupPopup(context);}
                    else{_postPopup(context, i, "Talk about this event!");}
                  },
                  child: Icon(Icons.share)),
              Divider(color: Colors.black),
              Flexible(child: Text(events["data"][i]["description"])),
              Divider(color: Colors.black),
              Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text("Location: " + events["data"][i]["location"]),
                      Text("People needed: " +
                          events["data"][i]["people_needed"].toString())
                    ])),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text("Date: " + events["data"][i]["dates"]),
                      Text("Time: " + events["data"][i]["time"])
                    ]))
              ]),
              Padding(
                  padding: EdgeInsets.all(20),
                  child: ElevatedButton(
                      onPressed: () {
                        backendFunction.volunteer(i).then((a) {
                          Navigator.of(context).pop();
                          if (mapEquals(userdict, {})){_signupPopup(context);}
                          else{_postPopup(context, i,
                              "Congratulations! Hope you enjoyed your volunteering experience. Tell everyone about it!");}
                        });
                      },
                      child: Text("Volunteer now!"))),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: NetworkImage("https://postmanhack.pythonanywhere.com/placeholder/dfka12kflkk99j/image/asdadas.png"),
                  ),
                ),
              )
            ],
          ),
        ));
      });
}

_loginPopup(context) {
  var msg = "";
  var usernamec = TextEditingController();
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Stack(
            children: <Widget>[
              Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: usernamec,
                        decoration: InputDecoration(
                          labelText: 'Username *',
                        ),
                      ),
                    ),
                    Text("Test version no passwords required"),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        child: Text("Log in"),
                        onPressed: () {
                          backendFunction.login(usernamec.text).then((a) {
                            if (a) {
                              Navigator.of(context).pop();
                              html.window.location.reload();
                            } else {
                              usernamec.clear();
                            }
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      });
}

_signupPopup(context) {
  var usernamec = TextEditingController();
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Stack(
            children: <Widget>[
              Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: usernamec,
                        decoration: InputDecoration(
                          labelText: 'Username *',
                        ),
                      ),
                    ),
                    Text("Test version no passwords required"),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        child: Text("Sign up"),
                        onPressed: () {
                          backendFunction.signup(usernamec.text).then((a) {
                            Navigator.of(context).pop();
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      });
}

_commentPopup(context, i) {
  var commentc = TextEditingController();
  final futurecomment = backendFunction.getComments(i);

  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: <Widget>[
                  FutureBuilder(
                      future: futurecomment,
                      builder: (context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Container(
                              child: ListView.builder(
                                  controller: ScrollController(),
                                  padding: const EdgeInsets.all(8),
                                  itemCount: snapshot.data!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        //                    <-- BoxDecoration
                                        border: Border(bottom: BorderSide()),
                                      ),
                                      child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Row(children: [
                                            Expanded(
                                                flex: 15,
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0, 7, 0),
                                                  child: CircleAvatar(
                                                      backgroundColor: colours[
                                                          _random.nextInt(
                                                              colours.length)],
                                                      child: Text(snapshot
                                                          .data![index]
                                                              ["username"]
                                                          .substring(0, 2)
                                                          .toUpperCase())),
                                                )),
                                            Expanded(
                                                flex: 85,
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      RichText(
                                                          text: TextSpan(
                                                              text: snapshot
                                                                          .data![
                                                                      index]
                                                                  ["username"],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold))),
                                                      Text(snapshot.data![index]
                                                          ["comment"])
                                                    ])),
                                          ])),
                                    );
                                  }));
                        }
                      }),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: TextFormField(
                      controller: commentc,
                      decoration: InputDecoration(
                        labelText: 'Comment *',
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                          onPressed: () {
                            backendFunction.sendComment(i, commentc.text);
                            Navigator.of(context).pop();
                          },
                          child: Text("Comment"))),
                ],
              )),
        );
      });
}

_badgesPopup(context) {
  final futurebadges = backendFunction.getBadges();

  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Container(
                width: MediaQuery.of(context).size.width,
                child: FutureBuilder(
                    future: futurebadges,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        return Container(
                            child: GridView.builder(
                                controller: ScrollController(),
                                padding: const EdgeInsets.all(8),
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 300,
                                        childAspectRatio: 1 / 1,
                                        crossAxisSpacing: 20,
                                        mainAxisSpacing: 20),
                                itemCount: snapshot.data!.length,
                                itemBuilder: (BuildContext ctx, index) {
                                  return Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 3,
                                                blurRadius: 10,
                                                offset: Offset(4, 10))
                                          ],
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      child: Column(children: [
                                        SizedBox.fromSize(
                                          size: Size.fromRadius(100),
                                          child: FittedBox(
                                            child: Icon(Icons.verified),
                                          ),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 10, 0, 10),
                                            child: Text(events["data"][
                                                    backendFunction.findIndex(
                                                        snapshot.data![index]
                                                            ["eid"])]
                                                ["eventname"])),
                                        InkWell(
                                            onTap: () {},
                                            child: Icon(Icons.ios_share))
                                      ]));
                                }));
                      }
                    })));
      });
}
