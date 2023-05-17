import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/main.dart';
import 'dart:developer' as devtools show log;

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notes'),
          actions: [
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                devtools.log(value.toString());
                switch (value) {
                  case MenuAction.logout:
                    bool logout = await showLogoutDialog(context);
                    if (logout) {
                      await FirebaseAuth.instance.signOut().then((value) {
                        navigateToLoginView(context);
                      });
                    }
                }
              },
              itemBuilder: (context) => <PopupMenuEntry<MenuAction>>[
                const PopupMenuItem<MenuAction>(
                    value: MenuAction.logout, child: Text("Logout"))
              ],
              child: const Icon(Icons.menu),
            )
          ],
        ),
        body: Center(
          child: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.currentUser?.delete().then((value) {
                  navigateToRegisterView(context);
                });
              },
              child: const Text('Delete Account')),
        ),
      ),
    );
  }
}

//Popup dialog when logout button on menu is pressed
Future<bool> showLogoutDialog(BuildContext context) {
  //show dialog might return null when the user doesn't interact
  //with any of our text buttons. e.g by clicking the android arrow key
  // so, return false if dialog is null
  return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text("Sign Out"),
            content: const Text("Are you sure you want to sign out"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Logout")),
            ],
          )).then((value) => value ?? false);
}
