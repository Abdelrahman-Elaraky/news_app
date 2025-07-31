import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';  // Import your User model

class ProfileScreen extends StatefulWidget {
  final User user;  // Add User field here

  const ProfileScreen({super.key, required this.user});  // Require user in constructor

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String username;
  late String fullName;
  late String bio;
  late String avatarUrl;

  @override
  void initState() {
    super.initState();

    // Initialize variables from widget.user
    username = widget.user.email.split('@').first; // or any username field you want
    fullName = '${widget.user.firstName} ${widget.user.lastName}';
    bio = 'Welcome to your profile!'; // Or use a field from user if available
    avatarUrl = widget.user.profileImage ??
        'https://i.pravatar.cc/150?img=3'; // fallback image
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User Avatar with edit icon
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(avatarUrl),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Add edit avatar functionality
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 16),

              // Full name
              Text(
                fullName,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // Username tag
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  username,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: Colors.blue.shade800),
                ),
              ),

              const SizedBox(height: 8),

              // Bio
              Text(
                bio,
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Statistics cards (example placeholders, update as needed)
              Expanded(
                child: ListView(
                  children: [
                    _buildStatCard(
                      icon: Icons.book,
                      iconColor: Colors.red.shade300,
                      label: 'Books read',
                      value: '152',
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      icon: Icons.star,
                      iconColor: Colors.yellow.shade700,
                      label: 'Average rating',
                      value: '4.6 stars',
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      icon: Icons.category,
                      iconColor: Colors.amber.shade600,
                      label: 'Genres',
                      value: '', // label only card
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Fiction, Mystery, Thriller',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          if (value.isNotEmpty)
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0, // highlight Home for example, adjust as needed
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          label: 'Bookmarks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      onTap: (index) {
        // Handle navigation here if needed
      },
    );
  }
}
