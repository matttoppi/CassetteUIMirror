import 'package:cassettefrontend/services/spotify_service.dart';
import 'package:flutter/material.dart';
import 'styles/app_styles.dart';
import 'constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

// EditProfilePage state management
// Tracks whether Spotify is connected (will be used for other streaming services later)
// This affects the display and functionality of streaming service connection
class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();
  bool isSpotifyConnected = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('user_profiles')
            .select()
            .eq('id', user.id)
            .single();
        
        setState(() {
          _nameController.text = response['name'] ?? '';
          _usernameController.text = response['username'] ?? '';
          _bioController.text = response['bio'] ?? '';
          _websiteController.text = response['website'] ?? '';
          isSpotifyConnected = response['spotify_refresh_token'] != null;
          isLoading = false;
        });
      } catch (e) {
        print('Error loading profile data: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await Supabase.instance.client.from('user_profiles').upsert({
        'id': user.id,
        'name': _nameController.text,
        'username': _usernameController.text,
        'bio': _bioController.text,
        'website': _websiteController.text,
        'updated_at': DateTime.now().toIso8601String(),
      });
      context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
                        style: AppStyles.editProfileTitleStyle,
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
                          backgroundImage: _nameController.text.isNotEmpty
                              ? NetworkImage('https://example.com/${_nameController.text}.jpg')
                              : null,
                          child: _nameController.text.isNotEmpty
                              ? null
                              : Icon(Icons.person, size: 40, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 24),
                        ElevatedButton(
                          onPressed: () {
                            // Add functionality to change profile picture
                          },
                          style: AppStyles.changePictureButtonStyle,
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
                  TextField(
                    controller: _nameController,
                    decoration: AppStyles.editProfileTextFieldDecoration('Name', 'Enter your name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _usernameController,
                    decoration: AppStyles.editProfileTextFieldDecoration('Username', 'Enter your username'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bioController,
                    decoration: AppStyles.editProfileTextFieldDecoration('Bio', 'Tell us about yourself'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _websiteController,
                    decoration: AppStyles.editProfileTextFieldDecoration('Website', 'Add a link'),
                  ),
                  const SizedBox(height: 32),
                  _buildConnectStreamingService(),
                  const SizedBox(height: 16),
                  _buildConnectedServices(),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: AppStyles.saveChangesButtonStyle,
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
      style: AppStyles.connectStreamingButtonStyle,
      child: const Text('Connect Streaming Service'),
    );
  }

  Widget _buildConnectedServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connected Streaming Services',
          style: AppStyles.connectedServicesHeaderStyle,
        ),
        const SizedBox(height: 8),
        _buildSpotifyLogo(),
      ],
    );
  }

  Widget _buildSpotifyLogo() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isSpotifyConnected
          ? Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Image.asset(
                    'lib/assets/images/spotify_logo.png',
                    width: 24,
                    height: 24,
                    key: const ValueKey('spotify_logo'),
                  ),
                  const SizedBox(width: 8),
                  const Text('Spotify'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _disconnectSpotify,
                  ),
                ],
              ),
            )
          : const SizedBox(height: 32, key: ValueKey('empty_space')),
    );
  }

  void _connectSpotify() async {
    await SpotifyService.initiateSpotifyAuth(context);
    loadProfileData(); // Reload profile data after connecting
  }

  void _disconnectSpotify() async {
    // Here you would typically call an API to revoke the Spotify tokens
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await Supabase.instance.client.from('user_profiles').update({
        'spotify_refresh_token': null,
      }).eq('id', user.id);
      
      setState(() {
        isSpotifyConnected = false;
      });
    }
  }
}
