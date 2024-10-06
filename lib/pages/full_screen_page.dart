// ignore_for_file: deprecated_member_use

part of '../flutter_flex_player_controller.dart';

class _FullScreenView extends StatefulWidget {
  final FlutterFlexPlayerController controller;
  final FlexPlayerConfiguration configuration;
  const _FullScreenView({
    super.key,
    required this.controller,
    required this.configuration,
  });

  @override
  State<_FullScreenView> createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<_FullScreenView> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        widget.controller.isFullScreen.value = false;
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          if (widget.controller.isFullScreen.value == false) {
            return const SizedBox();
          }
          return PlayerBuilder(
            controller: widget.controller,
            configuration: widget.configuration,
          );
        }),
      ),
    );
  }
}
