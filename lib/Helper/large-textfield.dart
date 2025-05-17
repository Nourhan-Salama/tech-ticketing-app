
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tech_app/Helper/custom-toolbar.dart';
// import 'package:tech_app/cubits/rich-text-cubit.dart';
// import 'package:tech_app/util/colors.dart';


// class RichTextEditor extends StatefulWidget {
//   final TextEditingController controller;
//   final bool isEnabled;
//   final void Function(String)? onChanged;

//   RichTextEditor({
//     required this.controller,       
//     this.isEnabled = true, 
//      this.onChanged,
//     Key? key, String? successText, required String label, String? errorText,
//   }) : super(key: key);

//   @override
//   _RichTextEditorState createState() => _RichTextEditorState();
// }

// class _RichTextEditorState extends State<RichTextEditor> {
//   @override
//   Widget build(BuildContext context) {
//     final cubit = context.watch<RichTextCubit>();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Description ',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),

//         Container(
//           height: 250,
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             border: Border.all(color: ColorsHelper.LightGrey),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             children: [
//               CustomToolbar(
//                 onLinkPressed: () => _handleInsertLink(context),
//                 isBold: cubit.isBold,
//                 isItalic: cubit.isItalic,
//                 isUnderlined: cubit.isUnderlined,
//                 isBulleted: cubit.isBulleted,
//                 onBoldToggle: cubit.toggleBold,
//                 onItalicToggle: cubit.toggleItalic,
//                 onUnderlineToggle: cubit.toggleUnderline,
//                 onBulletedToggle: cubit.toggleBulleted,
//               ),

//               Expanded(
//                 child: TextField(
//                   controller: widget.controller, 
//                   maxLines: null,
//                   enabled: widget.isEnabled,
//                   style: TextStyle(
//                     fontWeight: cubit.isBold ? FontWeight.bold : FontWeight.normal,
//                     fontStyle: cubit.isItalic ? FontStyle.italic : FontStyle.normal,
//                     decoration: cubit.isUnderlined ? TextDecoration.underline : TextDecoration.none,
//                   ),
//                   decoration: const InputDecoration(
//                     border: InputBorder.none,
//                     hintText: "Type your description",
//                     hintStyle: TextStyle(fontSize: 15.0, color: Color(0xFFB3B3B3)),
//                   ),
//                   onChanged: widget.onChanged,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//       ],
//     );
//   }

//   void _handleInsertLink(BuildContext context) {
//     TextEditingController linkController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Insert Link"),
//           content: TextField(
//             controller: linkController,
//             decoration: const InputDecoration(hintText: "Enter URL"),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () {
//                 context.read<RichTextCubit>().insertLink(linkController.text);
//                 Navigator.pop(context);
//               },
//               child: const Text("Insert"),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }






