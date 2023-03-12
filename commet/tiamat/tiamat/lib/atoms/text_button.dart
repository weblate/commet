import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:tiamat/atoms/seperator.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../config/app_config.dart';
import '../../config/style/theme_extensions.dart';
import './text.dart' as tiamat;

@WidgetbookUseCase(name: 'Default', type: TextButton)
Widget wb_iconUseCase(BuildContext context) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        material.Padding(
          padding: const EdgeInsets.all(8.0),
          child: material.SizedBox(height: 30, child: TextButton("Height: 30", icon: Icons.tag)),
        ),
        material.Padding(
          padding: const EdgeInsets.all(8.0),
          child: material.SizedBox(height: 35, child: TextButton("Height: 35", icon: Icons.tag)),
        ),
        material.Padding(
          padding: const EdgeInsets.all(8.0),
          child: material.SizedBox(height: 40, child: TextButton("Height: 40", icon: Icons.tag)),
        ),
        material.Padding(
          padding: const EdgeInsets.all(8.0),
          child: material.SizedBox(height: 45, child: TextButton("Height: 45", icon: Icons.tag)),
        ),
        material.Padding(
          padding: const EdgeInsets.all(8.0),
          child: material.SizedBox(height: 50, child: TextButton("Height: 50", icon: Icons.tag)),
        )
      ],
    ),
  );
}

class TextButton extends StatelessWidget {
  const TextButton(this.text, {super.key, this.icon, this.onTap, this.highlighted = false});
  final String text;

  final IconData? icon;
  final bool highlighted;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return material.TextButton(
        clipBehavior: Clip.antiAlias,
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(highlighted ? Theme.of(context).highlightColor : null),
        ),
        child: Row(
          children: [
            if (icon != null)
              Padding(
                padding: EdgeInsets.all(s(1.0)),
                child: Align(
                  alignment: Alignment.center,
                  child: Icon(
                    size: s(20),
                    icon!,
                    weight: 0.5,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(s(8), 0, 0, 0),
              child: Align(alignment: Alignment.centerLeft, child: tiamat.Text.label(text)),
            ),
          ],
        ),
        onPressed: () => onTap?.call());
  }
}
