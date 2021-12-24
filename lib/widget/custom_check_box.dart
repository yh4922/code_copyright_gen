import 'package:flutter/material.dart';

class CustomCheckBox extends StatefulWidget {
  final bool value;
  final String label;
  final Function(bool)? onChanged;
  const CustomCheckBox({
    Key? key,
    required this.value,
    required this.label,
    this.onChanged,
  }) : super(key: key);

  @override
  _CustomCheckBoxState createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  late bool value;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            value = !value;
          });
          widget.onChanged?.call(value);
        },
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (val) {
                setState(() {
                  value = val!;
                });
                widget.onChanged?.call(value);
              },
            ),
            Text('${widget.label}'),
          ],
        ),
      ),
    );
  }
}