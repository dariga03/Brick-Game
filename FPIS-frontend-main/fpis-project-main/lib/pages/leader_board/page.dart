import 'package:flutter/material.dart';

class LeaderBoardPage extends StatelessWidget {
  const LeaderBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("LEADERBOARD"),
        Text("123214"),
        // TODO: Icon,
        Text("Best 5"),

        Table(
          children: [
            TableRow(children: [
              Text(""),
              Text("Score"),
              Text("Stage"),
              Text("Name"),
            ]),
            TableRow(children: [
              Text("1st"),
              Text("123214"),
              Text("S"),
              Text("NAM"),
            ]),
            TableRow(children: [
              Text("1st"),
              Text("123214"),
              Text("S"),
              Text("NAM"),
            ]),
            TableRow(children: [
              Text("1st"),
              Text("123214"),
              Text("S"),
              Text("NAM"),
            ]),
            TableRow(children: [
              Text("1st"),
              Text("123214"),
              Text("S"),
              Text("NAM"),
            ]),
          ],
        ),
      ],
    );
  }
}
