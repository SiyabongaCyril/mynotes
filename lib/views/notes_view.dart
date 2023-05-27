// APP'S MAIN USER INTERFACE

import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/navigators.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import '../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  // Use an alert dialog when logout is pressed from the menu
  @override
  Widget build(BuildContext context) {
    AuthService service = AuthService.firebase();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 45,
          title: const Text('Notes',
              style: TextStyle(
                fontWeight: FontWeight.w400,
              )),
          actions: [
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                devtools.log(value.toString().toUpperCase());
                switch (value) {
                  case MenuAction.logout:
                    bool logout = await showLogoutDialog(context);
                    if (logout) {
                      await service.logOut().then((value) {
                        navigateToViewAndRemoveOtherViews(context, loginRoute);
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
            title: const Text("Log Out"),
            content: const Text("Are you sure you want to log out?"),
            actions: [
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel")),
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Logout")),
            ],
          )).then((value) => value ?? false);
}
