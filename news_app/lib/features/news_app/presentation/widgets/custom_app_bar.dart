import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final VoidCallback onDrawerTap;
  final VoidCallback onSettingsTap;

  const CustomAppBar({
    super.key,
    required this.username,
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
              // Wrap avatar and username column with InkWell for ripple effect & onTap
              InkWell(
                borderRadius: BorderRadius.circular(30), // circular ripple
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage('assets/images/user.png'),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${getGreeting()},',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                        Text(
                          username,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Drawer and Settings icons only
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: onDrawerTap,
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: onSettingsTap,
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
