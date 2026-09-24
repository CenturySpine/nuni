import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../live/domain/live_team.dart';

/// A team's player names ("Alice / Bob"), each one opening that player's
/// public page (plan 26, volet C). Used wherever a ranking or a team lists
/// players.
class PlayerNamesLink extends StatelessWidget {
  const PlayerNamesLink({super.key, required this.players, this.style});

  final List<TeamPlayerName> players;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < players.length; i++) ...[
          if (i > 0) Text(' / ', style: style),
          InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => context.push('/players/${players[i].playerId}'),
            child: Text(players[i].name, style: style),
          ),
        ],
      ],
    );
  }
}
