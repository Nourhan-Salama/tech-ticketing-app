
// import 'package:flutter/material.dart';
// import 'package:tech_app/screens/create-new.dart';
// import 'package:tech_app/util/colors.dart';


// class CustomDropDownCreateButton extends StatefulWidget {
//   const CustomDropDownCreateButton({super.key});

//   @override
//   _CustomDropDownCreateButtonState createState() => _CustomDropDownCreateButtonState();
// }

// class _CustomDropDownCreateButtonState extends State<CustomDropDownCreateButton> {

//   List<String> items = ['None', '5', '10'];
//   String selectedItem = 'None';

//   @override
//   Widget build(BuildContext context) {
   
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
         
//             SizedBox(
//               width:100, 
//               child: DropdownButtonFormField<String>(
//                 value: selectedItem,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                 ),
//                 items: items.map((item) {
//                   return DropdownMenuItem<String>(
//                     value: item,
//                     child: Text(item),
//                   );
//                 }).toList(),
//                 onChanged: (item) {
//                   setState(() {
//                     selectedItem = item!;
//                   });
//                 },
//               ),
//             ),
//             const SizedBox(width: 10),
          
//             Expanded(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: ColorsHelper.CreateNewButtonColor,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                 ),
//                 onPressed: (){
//                   // Navigator.pop(context); 
//                   // Navigator.pushNamed(context, CreateNewScreen.routeName);
//                 Navigator.pushNamed(context, CreateNewScreen.routeName);


//                 },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center, 
//                   children:  [
//                     Container(
//                     decoration: BoxDecoration(
//                      color: Colors.white,
//                       borderRadius: BorderRadius.circular(14)
//                     ),
//                       child: Icon(Icons.add,
                       
//                       color: ColorsHelper.darkBlue),
//                     ),
//                     SizedBox(width: 5,
//                     ),
//                     Text(
//                       'Create New',
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }



