import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'styles/app_styles.dart';
import 'constants/app_constants.dart';
import 'main.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> profileData = {};
  String currentTab = 'Playlists';

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    String jsonString = await rootBundle.loadString('lib/data/dummy_profile_data.json');
    setState(() {
      profileData = json.decode(jsonString);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (profileData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = profileData['user'];

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 383,
            color: const Color(0xFF1F2327),
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => MyHomePage(title: '')),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text(
                        'Cassette',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Teko',
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user['username'],
                            style: const TextStyle(
                              color: Color(0xCCB4B4B4),
                              fontSize: 14,
                              fontFamily: 'Teko',
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.26,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 23,
                  top: 182,
                  child: SizedBox(
                    width: 323,
                    height: 64,
                    child: Text(
                      user['bio'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 22,
                  right: 22,
                  bottom: 66,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: _buildActionButton('Share Profile')),
                      const SizedBox(width: 24),
                      Expanded(child: _buildActionButton('Add Music')),
                    ],
                  ),
                ),
                Positioned(
                  left: 13,
                  right: 13,
                  bottom: 50,
                  child: Divider(
                    color: Colors.grey[400],
                    thickness: 1,
                  ),
                ),
                Positioned(
                  left: 13,
                  right: 13,
                  bottom: 8,
                  child: SizedBox(
                    height: 42,
                    child: Row(
                      children: [
                        _buildTab('Playlists'),
                        const SizedBox(width: 8),
                        _buildTab('Songs'),
                        const SizedBox(width: 8),
                        _buildTab('Artists'),
                        const SizedBox(width: 8),
                        _buildTab('Albums'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildTabContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFED2748),
        minimumSize: const Size(0, 40), // Maintained original height
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Teko',
          fontWeight: FontWeight.w600,
          letterSpacing: 1.12,
        ),
      ),
    );
  }

  Widget _buildTab(String text) {
    bool isSelected = currentTab == text;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => currentTab = text),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5), 
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFFC4C4C4),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center( // Added to ensure vertical centering
            child: Text(
              text,
              style: isSelected ? AppStyles.selectedTabLabelStyle : AppStyles.tabLabelStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentList() {
    return Padding(
      padding: const EdgeInsets.only(top: 8), // Add 8 pixels of top padding
      child: Column(
        children: [
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (currentTab) {
      case 'Playlists':
        return Column(
          children: (profileData['playlists'] as List<dynamic>?)?.map<Widget>((playlist) => 
            _buildListItem(
              title: playlist['title'] ?? 'Untitled Playlist',
              subtitle: '${playlist['songCount'] ?? 0} songs | ${playlist['duration'] ?? 'Unknown'}',
              description: playlist['description'] ?? 'No description available',
              trailing: 'Playlist'
            )
          ).toList() ?? [const Text('No playlists available')],
        );
      case 'Songs':
        return Column(
          children: (profileData['songs'] as List<dynamic>?)?.map<Widget>((song) => 
            _buildListItem(
              title: song['title'] ?? 'Untitled Song',
              subtitle: '${song['artist'] ?? 'Unknown Artist'} - ${song['album'] ?? 'Unknown Album'}',
              trailing: song['duration'] ?? '--:--'
            )
          ).toList() ?? [const Text('No songs available')],
        );
      case 'Artists':
        return Column(
          children: (profileData['artists'] as List<dynamic>?)?.map<Widget>((artist) => 
            _buildListItem(
              title: artist['name'] ?? 'Unknown Artist',
              subtitle: '${artist['followers'] ?? '0'} followers',
              description: 'Top song: ${artist['topSong'] ?? 'Unknown'}',
              trailing: 'Artist'
            )
          ).toList() ?? [const Text('No artists available')],
        );
      case 'Albums':
        return Column(
          children: (profileData['albums'] as List<dynamic>?)?.map<Widget>((album) => 
            _buildListItem(
              title: album['title'] ?? 'Untitled Album',
              subtitle: album['artist'] ?? 'Unknown Artist',
              description: '${album['year'] ?? 'Unknown'} • ${album['tracks'] ?? '0'} tracks',
              trailing: 'Album'
            )
          ).toList() ?? [const Text('No albums available')],
        );
      default:
        return Container();
    }
  }

  Widget _buildListItem({
    required String title,
    required String subtitle,
    String? description,
    required String trailing
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10), // space between items in post lists
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                trailing,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
