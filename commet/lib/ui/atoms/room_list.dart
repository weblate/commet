import 'dart:async';

import 'package:commet/ui/atoms/room_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../../client/client.dart';

class RoomList extends StatefulWidget {
  RoomList(this.rooms,
      {super.key,
      this.onInsertStream,
      this.onUpdateStream,
      this.onRoomSelected,
      this.expandable = false,
      this.expanderText});
  bool expandable;
  List<Room> rooms;
  Stream<void>? onUpdateStream;
  Stream<int>? onInsertStream;
  String? expanderText;
  void Function(int)? onRoomSelected;
  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> with SingleTickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  int _count = 0;
  StreamSubscription<int>? onInsertListener;
  StreamSubscription<void>? onUpdateListener;
  AnimationController? controller;
  bool expanded = false;

  @override
  void initState() {
    onUpdateListener = widget.onUpdateStream?.listen((event) {
      setState(() {});
    });

    onInsertListener = widget.onInsertStream?.listen((index) {
      _listKey.currentState?.insertItem(index);
      _count++;
    });

    _count = widget.rooms.length;
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 100));

    super.initState();
  }

  @override
  void dispose() {
    onInsertListener?.cancel();
    onUpdateListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Building");
    return SingleChildScrollView(
      child: Column(
        children: [
          if (widget.expandable)
            RoomButton(
              widget.expanderText!,
              onTap: toggleExpansion,
              icon: Icons.expand_circle_down,
            ),
          if (!widget.expandable) listRooms(),
          if (widget.expandable)
            SizeTransition(
              sizeFactor: controller!,
              axisAlignment: -1.0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: listRooms(),
              ),
            ),
        ],
      ),
    );
  }

  AnimatedList listRooms() {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _count,
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, i, animation) => ScaleTransition(
        scale: animation,
        child: RoomButton(
          widget.rooms[i].displayName,
          onTap: () => {widget.onRoomSelected?.call(i)},
        ),
      ),
    );
  }

  void toggleExpansion() {
    setState(() {
      expanded = !expanded;
      print(expanded);

      if (expanded) controller?.forward(from: controller!.value);
      if (!expanded) controller?.reverse(from: controller!.value);
    });
  }
}
