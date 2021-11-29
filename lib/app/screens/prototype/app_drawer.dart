// import 'package:avme_wallet/app/screens/widgets/theme.dart';
// import 'package:flutter/material.dart';
//
// class AppDrawer extends StatefulWidget {
//   final Widget header;
//   final Widget footer;
//   final Map<dynamic,Widget> routes;
//   final String side;
//   const AppDrawer(
//     this.header,
//     this.routes,
//     this.footer,
//     {this.side = "RIGHT"});
//
//   @override
//   _AppDrawerState createState() => _AppDrawerState();
// }
//
// class _AppDrawerState extends State<AppDrawer> {
//   @override
//   Widget build(BuildContext context) {
//
//     List<Widget> drawerElements = [];
//
//     widget.routes.forEach((key, value) {
//       if(key.runtimeType == int)
//       {
//         drawerElements.add(value);
//       }
//       else
//       {
//         drawerElements.add(
//             ListTile(
//               title: Text(key),
//               onTap: () {
//                 // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => value));
//                 Navigator.push(context, MaterialPageRoute(builder: (context) => value));
//             }
//           )
//         );
//       }
//     });
//
//     return ClipRRect(
//       borderRadius: widget.side.toUpperCase() == "RIGHT"
//         ? BorderRadius.only(
//           topLeft: labelRadius.topLeft * 2,
//           bottomLeft: labelRadius.bottomLeft * 2
//         )
//         : BorderRadius.only(
//           topRight: labelRadius.topRight * 2,
//           bottomRight: labelRadius.bottomRight * 2
//         )
//       ,
//       child: SizedBox(
//         width: MediaQuery.of(context).size.width / 8 * 7,
//         child: Padding(
//           padding: const EdgeInsets.only(top: 16, bottom: 16),
//           child: Drawer(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 24.0),
//               child: Column(
//                 children: [
//                   widget.header,
//                   ConstrainedBox(
//                     constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 1.5),
//                     child: ListView(
//                       shrinkWrap: true,
//                       padding: EdgeInsets.zero,
//                       children: drawerElements,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(
//                       top: 28.0
//                     ),
//                     child: widget.footer,
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }