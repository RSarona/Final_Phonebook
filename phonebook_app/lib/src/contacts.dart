import 'package:flutter/material.dart';
import 'package:phonebook/routes/add_new.dart';
import 'contacts_listing.dart';
import 'package:phonebook/api/api.dart';

class contactsScreen extends StatefulWidget {
  contactsScreen({Key? key,}) : super(key: key);

  @override
  contactsScreen_State createState() => contactsScreen_State();
}

class contactsScreen_State extends State<contactsScreen> {
  contactAPI api = contactAPI();
  List contacts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }
  
  loadData() async {
    try {
      await api.getContacts().then((data) {
        setState(() {
          contacts = data;
          if (contacts.isNotEmpty) {
            loading = false;
          }
        });
      });
    } on Exception catch (e) {
      print(e);
    }

  }

  Future<void> refreshData() async {
    setState(() {
      loading = true;
      loadData();
    });
    await Future.delayed(Duration(milliseconds: 3000));
    setState(() {
      loading = false;
    });   
  }

  deleteContact(String id) {
    setState(() {
      contacts.removeWhere((contact) => contact['_id'] == id);
      api.deleteContact(id).then((value) {
        contacts.remove(value);
      });
    });
  }

  showData() {
    if (loading == true) {
      return Center(child: CircularProgressIndicator());
    } else if (loading == false) {
      return contactsListing(contacts: contacts, toDelete: deleteContact);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phonebook'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                  title: new Text('Do you want to logout?', textAlign: TextAlign.center),
                  actions: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TextButton(
                            onPressed: () {
                              Navigator.restorablePushNamedAndRemoveUntil(context, '/', (route) => false);
                            },
                            child: Text('Logout',
                              style: TextStyle(color: Colors.red,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {Navigator.of(context).pop();},
                          child: Text('Cancel',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                );
              }
            ),
            splashRadius: 18,
            icon: Icon(Icons.logout)
          ),
              
        ],
      ),
      body: showData(),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              refreshData();
            },
            heroTag: 'refreshbtn',
            backgroundColor: Colors.pink[400],
            tooltip: 'Refresh',
            child: Icon(Icons.refresh),
          ),
          SizedBox(width: 5),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => addNew())
              ).then((value) {
                refreshData();
              });
            },
            heroTag: 'addbtn',
            tooltip: 'Add person',
            child: Icon(Icons.person_add),
          ),
          SizedBox(height: 70)
        ],
      ),
    );
  }
}