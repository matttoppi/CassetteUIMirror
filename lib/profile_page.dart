import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'styles/app_styles.dart';
import 'constants/app_constants.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Cassette', style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Teko', fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 383,
              color: const Color(0xFF1F2327),
              child: Stack(
                children: [
                  Positioned(
                    left: 127,
                    top: 87,
                    child: Column(
                      children: [
                        Text(
                          user['name'],
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Roboto', fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user['username'],
                          style: const TextStyle(color: Color(0xCCB4B4B4), fontSize: 14, fontFamily: 'Teko', fontWeight: FontWeight.w400, letterSpacing: 1.26),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 23,
                    top: 182,
                    child: SizedBox(
                      width: 323,
                      height: 64, // Increased from 32 to 64 to accommodate two lines
                      child: Text(
                        user['bio'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 1.4, // Added line height for better readability
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3, // Allow up to 3 lines for the bio
                      ),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    right: 22,
                    bottom: 66, // Maintained position
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
                    bottom: 50, // Maintained position
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
                      height: 42, // Increased height to 42 (50 - 8 = 42)
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
            _buildContentList(),
          ],
        ),
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
    switch (currentTab) {
      case 'Playlists':
        return Column(
          children: profileData['playlists'].map<Widget>((playlist) => 
            _buildPlaylistItem(playlist['title'], playlist['details'], playlist['description'])
          ).toList(),
        );
      case 'Songs':
        return Column(
          children: profileData['songs'].map<Widget>((song) => 
            _buildSongItem(song['title'], song['artist'], song['album'], song['duration'])
          ).toList(),
        );
      case 'Artists':
        return Column(
          children: profileData['artists'].map<Widget>((artist) => 
            _buildArtistItem(artist['name'], artist['followers'], artist['topSong'])
          ).toList(),
        );
      case 'Albums':
        return Column(
          children: profileData['albums'].map<Widget>((album) => 
            _buildAlbumItem(album['title'], album['artist'], album['year'], album['tracks'])
          ).toList(),
        );
      default:
        return Container();
    }
  }

  Widget _buildPlaylistItem(String title, String details, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
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
              Text(title, style: AppStyles.playlistTitleStyle),
              const Text('Playlist', style: AppStyles.playlistLabelStyle),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: details.split(' | ')[0], style: AppStyles.songCountStyle),
                    const TextSpan(text: ' songs', style: AppStyles.songCountTextStyle),
                  ],
                ),
              ),
              Text(' | ${details.split(' | ')[1]}', style: AppStyles.durationStyle),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: AppStyles.playlistDescriptionStyle),
        ],
      ),
    );
  }

  Widget _buildSongItem(String title, String artist, String album, String duration) {
    return ListTile(
      title: Text(title),
      subtitle: Text('$artist - $album'),
      trailing: Text(duration),
    );
  }

  Widget _buildArtistItem(String name, String followers, String topSong) {
    return ListTile(
      title: Text(name),
      subtitle: Text('Top song: $topSong'),
      trailing: Text('$followers followers'),
    );
  }

  Widget _buildAlbumItem(String title, String artist, String year, String tracks) {
    return ListTile(
      title: Text(title),
      subtitle: Text(artist),
      trailing: Text('$year • $tracks tracks'),
    );
  }
}
