import 'package:flutter/cupertino.dart';
import 'package:openim_common/openim_common.dart';

class ChatDelayedStatusView extends StatefulWidget {
  const ChatDelayedStatusView({
    super.key,
    required this.isSending,
    this.delay = true,
  });
  final bool isSending;
  final bool delay;

  @override
  State<ChatDelayedStatusView> createState() => _ChatDelayedStatusViewState();
}

class _ChatDelayedStatusViewState extends State<ChatDelayedStatusView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(
        Duration(seconds: widget.isSending && widget.delay ? 1 : 0),
        () => widget.isSending,
      ),
      builder: (_, AsyncSnapshot<bool> hot) => Visibility(
        visible: hot.hasData && hot.data == true,
        child: CupertinoActivityIndicator(
          color: Styles.c_0089FF,
        ),
      ),
    );
  }
}

// class ChatDelayedStatusView extends StatelessWidget {
//   const ChatDelayedStatusView({
//     super.key,
//     required this.isSending,
//     this.delay = true,
//   });
//   final bool isSending;
//   final bool delay;
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: Future.delayed(
//         Duration(seconds: isSending && delay ? 1 : 0),
//         () => isSending,
//       ),
//       builder: (_, AsyncSnapshot<bool> hot) => Visibility(
//         visible: hot.hasData && hot.data == true,
//         child: CupertinoActivityIndicator(
//           color: Styles.c_0089FF,
//         ),
//       ),
//     );
//   }
// }
