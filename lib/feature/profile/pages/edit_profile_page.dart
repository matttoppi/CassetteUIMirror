import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/spotify_service.dart';
import '../../../core/styles/app_styles.dart';

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
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            ElevatedButton(
              onPressed: _saveChanges,
              style: AppStyles.saveChangesButtonStyle,
              child: const Text('Save Changes'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: const Text('Sign Out'),
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

  void _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      context.go('/');
    }
  }
}
