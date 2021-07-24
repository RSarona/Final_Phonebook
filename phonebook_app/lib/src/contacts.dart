import 'package:flutter/material.dart';
import 'package:phonebook/routes/add_new.dart';
import 'contacts_listing.dart';
import 'package:phonebook/api/api.dart';

class contactsScreen extends StatefulWidget {
  contactsScreen({Key? key, required this.title}) : super(key: key);
  final String title;

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
  
  loadData() {
    api.getContacts().then((data) {
      setState(() {
        contacts = data;
        if (contacts.isNotEmpty) {
          loading = false;
        }
      });
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
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: showData(),
      // loading ? Center(child: CircularProgressIndicator()) :
      // contactsListing(contacts: contacts, toDelete: deleteContact),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                loading = true;
              });
              loadData();
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
                setState(() {
                  loading = true;
                });
                loadData();
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

