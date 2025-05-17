// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter/material.dart';

// class RichTextCubit extends Cubit<bool> {
//   RichTextCubit() : super(false);

//   final TextEditingController textController = TextEditingController();

//   bool isBold = false;
//   bool isItalic = false;
//   bool isUnderlined = false;
//   bool isBulleted = false;


//   void checkFields() {
//     if (!isClosed) {
//       final isFilled = textController.text.trim().isNotEmpty;
//       emit(isFilled); 
//     }
//   }
//   void toggleBold() {
//     isBold = !isBold;
//     emit(state);
//   }

//   void toggleItalic() {
//     isItalic = !isItalic;
//     emit(state);
//   }

//   void toggleUnderline() {
//     isUnderlined = !isUnderlined;
//     emit(state);
//   }

//   void toggleBulleted() {
//     isBulleted = !isBulleted;
//     List<String> lines = textController.text.split("\n");

//     if (isBulleted) {
//       for (int i = 0; i < lines.length; i++) {
//         if (!lines[i].trim().startsWith("• ")) {
//           lines[i] = "• " + lines[i];
//         }
//       }
//     } else {
//       for (int i = 0; i < lines.length; i++) {
//         lines[i] = lines[i].replaceFirst("• ", "");
//       }
//     }

//     textController.text = lines.join("\n");
//     checkFields();
//   }

//   void insertLink(String link) {
//     if (link.trim().isNotEmpty) {
//       textController.text += " [$link] ";
//       checkFields();   
//     }
//   }

//   void dispose() {
//     textController.dispose();
//     super.close();
//   }
// }

