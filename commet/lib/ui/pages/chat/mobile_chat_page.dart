import 'package:commet/ui/atoms/popup_dialog.dart';
import 'package:commet/ui/molecules/timeline_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';

import '../../../client/client_manager.dart';
import '../../../client/room.dart';
import '../../../client/space.dart';
import '../../atoms/background.dart';
import '../../atoms/room_header.dart';
import '../../atoms/side_panel_button.dart';
import '../../atoms/space_header.dart';
import '../../molecules/message_input.dart';
import '../../molecules/overlapping_panels.dart';
import '../../molecules/space_selector.dart';
import '../../molecules/space_viewer.dart';
import '../../molecules/user_list.dart';
import '../../organisms/add_space_dialog.dart';

class MobileChatPage extends StatefulWidget {
  const MobileChatPage({super.key});

  @override
  State<MobileChatPage> createState() => _MobileChatPageState();
}

class _MobileChatPageState extends State<MobileChatPage> {
  late ClientManager _clientManager;
  late Space? selectedSpace;
  late Room? selectedRoom;
  late GlobalKey<OverlappingPanelsState> panelsKey;
  late GlobalKey<TimelineViewerState> timelineKey = GlobalKey<TimelineViewerState>();
  late Map<String, GlobalKey<TimelineViewerState>> timelines = Map();

  @override
  void initState() {
    _clientManager = Provider.of<ClientManager>(context, listen: false);
    selectedRoom = null;
    selectedSpace = null;
    panelsKey = GlobalKey<OverlappingPanelsState>();
    super.initState();
  }

  @override
  Widget build(BuildContext newContext) {
    return SafeArea(
        child: OverlappingPanels(
            key: panelsKey,
            left: navigation(newContext),
            main: timelineView(),
            right: selectedRoom != null ? userList() : null));
  }

  Widget navigation(BuildContext newContext) {
    return Row(
      children: [spaceSelector(), if (selectedSpace != null) spaceRoomSelector(newContext)],
    );
  }

  Widget spaceSelector() {
    return SizedBox(
        width: 70,
        child: SpaceSelector(
          _clientManager.spaces,
          onSpaceInsert: _clientManager.onSpaceAdded.stream,
          header: SidePanelButton(
            tooltip: "Home",
          ),
          footer: SidePanelButton(
            tooltip: "Add a Space",
            onTap: () {
              PopupDialog.Show(context, AddSpaceDialog(), title: "Add Space");
            },
          ),
          showSpaceOwnerAvatar: true,
          onSelected: (index) {
            setState(() {
              selectedSpace = _clientManager.spaces[index];
            });
            print("Selected Space: " + selectedSpace!.displayName);
          },
        ));
  }

  Widget userList() {
    if (selectedRoom != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(50, 20, 0, 0),
        child: PeerList(
          selectedRoom!.members,
          key: selectedRoom!.key,
        ),
      );
    }
    return Placeholder();
  }

  Widget timelineView() {
    if (selectedRoom != null) {
      return roomChatView();
    }

    return Container(
      color: Colors.red,
      child: Placeholder(),
    );
  }

  Widget spaceRoomSelector(BuildContext newContext) {
    return Flexible(
      child: Background.low1(
        context,
        child: Column(
          children: [
            Container(child: SizedBox(height: 50, child: Container(child: SpaceHeader(selectedSpace!)))),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
              child: SpaceViewer(
                selectedSpace!,
                key: selectedSpace!.key,
                onRoomInsert: selectedSpace!.onRoomAdded.stream,
                onRoomSelected: (index) async {
                  roomSelected(index);
                },
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget roomChatView() {
    return Column(
      children: [
        SizedBox(height: 50, child: RoomHeader(selectedRoom!)),
        Flexible(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                    child: TimelineViewer(
                  key: timelines[selectedRoom!.identifier],
                  timeline: selectedRoom!.timeline!,
                )),
                MessageInput()
              ],
            ),
          ),
        ),
      ],
    );
  }

  void roomSelected(index) {
    var room = selectedSpace!.rooms[index];
    if (room == selectedRoom) return;

    if (!timelines.containsKey(room.identifier)) {
      timelines[room.identifier] = GlobalKey<TimelineViewerState>();
    }

    if (kDebugMode) {
      // Weird hacky work around mentioned in #2
      timelines[selectedRoom?.identifier]?.currentState!.prepareForDisposal();
      WidgetsBinding.instance.addPostFrameCallback((_) => _setSelectedRoom(room));
    } else {
      _setSelectedRoom(room);
    }
  }

  void _setSelectedRoom(Room room) async {
    setState(() {
      selectedRoom = room;
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          timelines[selectedRoom?.identifier]?.currentState!.forceToBottom();
        },
      );
    });

    // Putting this here so we can see a bit of the animation when the room button is clicked
    // feels better ^-^
    await Future.delayed(Duration(milliseconds: 125));
    panelsKey.currentState!.reveal(RevealSide.main);
  }
}