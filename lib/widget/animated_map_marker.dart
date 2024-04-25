/*
Created by Axmadjon Isaqov on 14:54:37 25.04.2024
*© 2024 @axiydev 
*/
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class AppAnimatedIcon extends StatefulWidget {
  final bool isHovering;
  const AppAnimatedIcon({
    super.key,
    this.isHovering = true,
  });

  @override
  State<AppAnimatedIcon> createState() => _AppAnimatedIconState();
}

class _AppAnimatedIconState extends State<AppAnimatedIcon> {
  Artboard? riveArtboard;
  SMIBool? isHover;

  @override
  void didUpdateWidget(AppAnimatedIcon oldWidget) {
    if (oldWidget.isHovering != widget.isHovering) {
      if (isHover != null) {
        isHover!.value = widget.isHovering;
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    Future.microtask(() async {
      await rootBundle.load('assets/rive/marker.riv').then(
        (data) async {
          try {
            final file = RiveFile.import(data);
            final artboard = file.mainArtboard;
            var controller =
                StateMachineController.fromArtboard(artboard, 'Motion');
            if (controller != null) {
              artboard.addController(controller);
              isHover = controller.findSMI('isHover');
            }

            riveArtboard = artboard;
            isHover!.value = widget.isHovering;
            setState(() {});
          } catch (e) {
            debugPrint(e.toString());
          }
        },
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return riveArtboard == null
        ? const SizedBox()
        : SizedBox.square(
            dimension: 100,
            child: Rive(
              artboard: riveArtboard!,
            ),
          );
  }
}
