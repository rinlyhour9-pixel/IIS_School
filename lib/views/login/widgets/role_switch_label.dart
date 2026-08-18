// import 'package:flutter/material.dart';

// class RoleSwitchLabel extends StatelessWidget {
//   const RoleSwitchLabel({
//     super.key,
//     required this.label,
//     required this.icon,
//     required this.isSelected,
//     required this.onTap,
//   });

//   final String label;
//   final IconData icon;
//   final bool isSelected;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(999),
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 20,
//               color: isSelected ? Colors.white : const Color(0xFF8B90A0),
//             ),
//             const SizedBox(width: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//                 color: isSelected ? Colors.white : const Color(0xFF8B90A0),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
