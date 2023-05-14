import 'dart:async';

import 'package:commet/client/client_manager.dart';
import 'package:commet/ui/pages/add_space_or_room/add_space_or_room.dart';
import 'package:commet/ui/pages/settings/app_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';
import 'package:tiamat/config/style/theme_extensions.dart';
import 'package:tiamat/tiamat.dart';
import 'package:tiamat/tiamat.dart' as tiamat;
import '../../generated/l10n.dart';
import '../molecules/space_selector.dart';
import '../molecules/split_timeline_viewer.dart';
import '../navigation/navigation_utils.dart';

class SideNavigationBar extends StatefulWidget {
  const SideNavigationBar(
      {super.key,
      this.onSpaceSelected,
      this.onHomeSelected,
      this.onSettingsSelected,
      this.clearSpaceSelection});

  static ValueKey settingsKey =
      const ValueKey("SIDE_NAVIGATION_SETTINGS_BUTTON");

  final void Function(int index)? onSpaceSelected;
  final void Function()? clearSpaceSelection;
  final void Function()? onHomeSelected;
  final void Function()? onSettingsSelected;

  @override
  State<SideNavigationBar> createState() => _SideNavigationBarState();

  static Widget tooltip(String text, Widget child, BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: JustTheTooltip(
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: tiamat.Text(text),
          ),
          preferredDirection: AxisDirection.right,
          offset: 5,
          tailLength: 5,
          tailBaseWidth: 5,
          backgroundColor:
              Theme.of(context).extension<ExtraColors>()!.surfaceLow4,
          child: child),
    );
  }
}

class _SideNavigationBarState extends State<SideNavigationBar> {
  late ClientManager _clientManager;
  late GlobalKey<SplitTimelineViewerState> timelineKey =
      GlobalKey<SplitTimelineViewerState>();
  late Map<String, GlobalKey<SplitTimelineViewerState>> timelines = {};
  StreamSubscription? onSpaceUpdated;
  StreamSubscription? onSpaceChildUpdated;
  @override
  void initState() {
    _clientManager = Provider.of<ClientManager>(context, listen: false);
    onSpaceChildUpdated = _clientManager.onSpaceChildUpdated.stream
        .listen((_) => onSpaceUpdate());

    onSpaceUpdated =
        _clientManager.onSpaceUpdated.stream.listen((_) => onSpaceUpdate());

    super.initState();
  }

  void onSpaceUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 70.0,
        child: SpaceSelector(
          _clientManager.spaces,
          width: 70,
          onSpaceInsert: _clientManager.onSpaceAdded.stream,
          onSpaceRemoved: _clientManager.onSpaceRemoved.stream,
          clearSelection: widget.clearSpaceSelection,
          header: Column(
            children: [
              SideNavigationBar.tooltip(
                  T.of(context).home,
                  ImageButton(
                    size: 70,
                    icon: Icons.home,
                    onTap: () {
                      widget.onHomeSelected?.call();
                    },
                  ),
                  context)
            ],
          ),
          footer: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                child: SideNavigationBar.tooltip(
                    T.of(context).addSpace,
                    ImageButton(
                      // tooltip: "Add a Space",
                      size: 70,
                      icon: Icons.add,
                      onTap: () {
                        PopupDialog.show(context,
                            content: AddSpaceOrRoom(
                              clients: _clientManager.clients,
                            ),
                            title: T.of(context).addSpace);
                      },
                    ),
                    context),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                child: SideNavigationBar.tooltip(
                  T.of(context).settings,
                  ImageButton(
                    // tooltip: "Settings",
                    key: SideNavigationBar.settingsKey,
                    size: 70,
                    icon: Icons.settings,
                    onTap: () {
                      NavigationUtils.navigateTo(
                          context, const AppSettingsPage());
                    },
                  ),
                  context,
                ),
              ),
            ],
          ),
          showSpaceOwnerAvatar: false,
          onSelected: (index) {
            widget.onSpaceSelected?.call(index);
          },
        ));
  }
}
