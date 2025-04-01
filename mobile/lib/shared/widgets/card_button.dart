import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function onTap;

  const CardButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 18,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          color: Colors.blueAccent,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
              splashColor: Colors.lightBlueAccent,
              onTap: () => onTap(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 60),
                child: Center(
                  child: Icon(
                    icon,
                    size: 100,
                  ),
                ),
              )),
        ),
        SizedBox(
          width: 180,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
