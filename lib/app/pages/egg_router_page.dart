import 'package:flutter/material.dart';

import '../app_profile.dart';
import 'dppt_egg_page.dart';
import 'egg_page.dart';

class EggRouterPage extends StatelessWidget {
  const EggRouterPage({
    super.key,
    required this.profile,
    required this.onProfileChanged,
  });

  final AppProfile profile;
  final ValueChanged<AppProfile> onProfileChanged;

  @override
  Widget build(BuildContext context) {
    if (profile.game.isDppt) {
      return DpptEggPage(profile: profile, onProfileChanged: onProfileChanged);
    }
    return EggPage(profile: profile, onProfileChanged: onProfileChanged);
  }
}
