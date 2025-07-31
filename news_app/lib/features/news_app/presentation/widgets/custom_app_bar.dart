import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final int notificationCount;
  final VoidCallback onDrawerTap;
  final VoidCallback onSettingsTap;

  const CustomAppBar({
    super.key,
    required this.username,
    required this.notificationCount,
    required this.onDrawerTap,
    required this.onSettingsTap,
  });

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 90,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Profile Picture
              const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('assets/images/user.png'),
              ),
              const SizedBox(width: 12),

              // Greeting
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${getGreeting()},',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                    Text(
                      username,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Action Icons
              Row(
                children: [
                  // Notifications with badge
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        onPressed: () {}, // Handle tap
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$notificationCount',
                              style: const TextStyle(fontSize: 10, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Drawer/Menu icon
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: onDrawerTap,
                  ),

                  // Replaced search with settings icon
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: onSettingsTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}
