import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'theme_provider.dart'; // Import ThemeProvider

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false; // Default notifications to off

  @override
  Widget build(BuildContext context) {
    final themeProvider =
        Provider.of<ThemeProvider>(context); // Get ThemeProvider

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
            style: TextStyle(
                color: Theme.of(context).appBarTheme.titleTextStyle?.color ??
                    Colors.white)),
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ?? Colors.teal[800],
        iconTheme: IconThemeData(
            color:
                Theme.of(context).appBarTheme.iconTheme?.color ?? Colors.white),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // Use theme's background color
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // General Settings Section
            Text(
              'General',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color, // Use theme's text color
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: Theme.of(context).cardColor, // Use theme's card color
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    title: Text('Dark Mode',
                        style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color)), // Use theme's text color
                    value: themeProvider
                        .isDarkMode, // Get isDarkMode from ThemeProvider
                    secondary: Icon(Icons.brightness_2,
                        color: Theme.of(context)
                            .iconTheme
                            .color), // Use theme's icon color
                    onChanged: (bool value) {
                      themeProvider
                          .toggleTheme(); // Toggle theme using ThemeProvider
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Notifications Settings Section
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: Theme.of(context).cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    title: Text('Enable Notifications',
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color)),
                    value: _notificationsEnabled,
                    secondary: Icon(Icons.notifications_active,
                        color: Theme.of(context).iconTheme.color),
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                        // TODO: Implement actual notification enabling/disabling logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Notifications ${value ? 'Enabled' : 'Disabled'} (Functionality not fully implemented)')),
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // About Section
            Text(
              'About',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: Theme.of(context).cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.info_outline,
                          color: Theme.of(context).iconTheme.color),
                      title: Text('App Version',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color)),
                      trailing: Text('1.0.1',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color)), // Replace with actual app version
                    ),
                    const Divider(color: Colors.grey),
                    ListTile(
                      leading: Icon(Icons.copyright,
                          color: Theme.of(context).iconTheme.color),
                      title: Text('Developed by',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color)),
                      trailing: Text('Isamusa3538@gmail.com',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color)), // Replace with your info
                    ),
                    const Divider(color: Colors.grey),
                    ListTile(
                      leading: Icon(Icons.email_outlined,
                          color: Theme.of(context).iconTheme.color),
                      title: Text('Contact Support',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color)),
                      onTap: () {
                        // TODO: Implement contact support action (e.g., open email client)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Contact Us at: Mahafiyyahfoundation@gmail.com')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20.0, bottom: 10.0), // Add some padding
              child: Center(
                child: Text(
                  'App by Mahadiyyah Foundation Jos',
                  style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color, // Using bodySmall for less prominent text
                      fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
