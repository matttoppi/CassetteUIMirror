import 'package:cassettefrontend/services/spotify_service.dart';
import 'package:flutter/material.dart';
import 'styles/app_styles.dart';
import 'constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool isSpotifyConnected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 383,
              color: AppColors.profileBackground,
              child: Stack(
                children: [
                  const Positioned(
                    top: 18,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Teko',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 23,
                    top: 87,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 24),
                        ElevatedButton(
                          onPressed: () {
                            // Add functionality to change profile picture
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: AppColors.primary,
                          ),
                          child: const Text('Change Picture'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Name', 'Enter your name'),
                  const SizedBox(height: 16),
                  _buildTextField('Username', 'Enter your username'),
                  const SizedBox(height: 16),
                  _buildTextField('Bio', 'Tell us about yourself', maxLines: 3),
                  const SizedBox(height: 16),
                  _buildTextField('Link', 'Add a link'),
                  const SizedBox(height: 32),
                  _buildConnectStreamingService(),
                  const SizedBox(height: 16),
                  _buildConnectedServices(),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Add save functionality
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: AppColors.primary,
                        minimumSize: const Size(200, 50),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {int maxLines = 1}) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildConnectStreamingService() {
    return ElevatedButton(
      onPressed: _connectSpotify,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text('Connect Streaming Service'),
    );
  }

  Widget _buildConnectedServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connected Streaming Services',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (isSpotifyConnected)
          ListTile(
            leading: Image.asset('assets/spotify_logo.png', width: 24, height: 24),
            title: const Text('Spotify'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _disconnectSpotify,
            ),
          )
        else
          const Text('No streaming services connected'),
      ],
    );
  }

  void _connectSpotify() {
    SpotifyService.initiateSpotifyAuth(context);
  }

  void _disconnectSpotify() {
    // Here you would typically call an API to revoke the Spotify tokens
    setState(() {
      isSpotifyConnected = false;
    });
  }
}
