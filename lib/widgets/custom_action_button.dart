// import 'package:flutter/material.dart';
// import 'dart:math';

// class ClusterButton extends StatefulWidget {
//   final List<ClusterButton> childButtons;
//   final Widget child;
//   final Color? backgroundColor;
//   final Color? foregroundColor;
//   final String? tooltip;
//   final Object? heroTag;
//   final Duration animationDuration;
//   final double spacing;
//   final VoidCallback? onPressed; // Only used when childButtons is empty

//   const ClusterButton({
//     super.key,
//     required this.childButtons,
//     required this.child,
//     this.backgroundColor,
//     this.foregroundColor,
//     this.tooltip,
//     this.heroTag,
//     this.animationDuration = const Duration(milliseconds: 100),
//     this.spacing = 67.88,
//     this.onPressed, // Optional onPressed for leaf buttons
//   });

//   @override
//   State<ClusterButton> createState() => _ClusterButtonState();
// }

// class _ClusterButtonState extends State<ClusterButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _expandAnimation;
//   bool _isExpanded = false;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: widget.animationDuration,
//       vsync: this,
//     );
//     _expandAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _toggle() {
//     debugPrint("Toggle called on ${widget.heroTag ?? 'unknown'}");
//     if (widget.childButtons.isEmpty) {
//       debugPrint("Executing onPressed for leaf button");
//       widget.onPressed?.call();
//     } else {
//       debugPrint("Toggling expansion: $_isExpanded -> ${!_isExpanded}");
//       setState(() {
//         _isExpanded = !_isExpanded;
//         if (_isExpanded) {
//           _animationController.forward();
//         } else {
//           _animationController.reverse();
//         }
//       });
//     }
//   }

//   double getChildAngle(int index) {
//     final angle = -pi / 2 + (2 * pi * index) / widget.childButtons.length;
//     return angle;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final buttonSize = widget.childButtons.isNotEmpty ? 56.0 : 40.0;
//     final highlightColor = widget.backgroundColor ?? Colors.blue;

//     return Stack(
//       alignment: Alignment.center,
//       clipBehavior: Clip.none,
//       children: [
//         // Only show child buttons if they exist and we're expanded
//         if (widget.childButtons.isNotEmpty) ...[
//           ...widget.childButtons.asMap().entries.map((entry) {
//             final index = entry.key;
//             final childButton = entry.value;

//             return AnimatedBuilder(
//               animation: _expandAnimation,
//               builder: (context, child) {
//                 // Calculate angle for equal spacing in a circle
//                 final angle = getChildAngle(index);

//                 // Radius spacing based on the expand animation value
//                 final spacingRadius = widget.spacing * _expandAnimation.value;
//                 final xSpacingOffset = spacingRadius * cos(angle);
//                 final ySpacingOffset = spacingRadius * sin(angle);

//                 // Get child button size for centering
//                 final childButtonSize = 40.0; // Child buttons are smaller

//                 return AnimatedPositioned(
//                   left: buttonSize / 2 + xSpacingOffset - (childButtonSize / 2),
//                   top: buttonSize / 2 + ySpacingOffset - (childButtonSize / 2),
//                   duration: widget.animationDuration,
//                   child: Transform.scale(
//                     scale: _expandAnimation.value,
//                     child: Opacity(
//                       opacity: _expandAnimation.value,
//                       child: ClusterButton(
//                         childButtons: childButton.childButtons,
//                         child: childButton.child,
//                         backgroundColor: childButton.backgroundColor,
//                         foregroundColor: childButton.foregroundColor,
//                         tooltip: childButton.tooltip,
//                         heroTag: childButton.heroTag ?? "cluster_child_$index",
//                         spacing: widget.spacing * 0.8,
//                         onPressed: childButton.onPressed,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           }).toList(),
//         ],

//         // Main button - Custom Container with GestureDetector
//         AnimatedRotation(
//           turns: _isExpanded ? 0.125 : 0,
//           duration: widget.animationDuration,
//           child: GestureDetector(
//             onTap: _toggle,
//             child: Container(
//               width: buttonSize,
//               height: buttonSize,
//               decoration: BoxDecoration(
//                 color: highlightColor.withAlpha(
//                   (0.1 * 255).round(),
//                 ), // Highlight gesture area
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: highlightColor.withAlpha((0.3 * 255).round()),
//                   width: 2,
//                 ),
//               ),
//               child: Container(
//                 margin: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: _isExpanded
//                       ? (widget.backgroundColor?.withOpacity(0.8) ??
//                             Colors.blue.withOpacity(0.8))
//                       : widget.backgroundColor ?? Colors.blue,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.3),
//                       blurRadius: _isExpanded ? 12.0 : 6.0,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Center(
//                   child: AnimatedSwitcher(
//                     duration: widget.animationDuration,
//                     child: _isExpanded && widget.childButtons.isNotEmpty
//                         ? Icon(
//                             Icons.close,
//                             key: const ValueKey('close'),
//                             color: widget.foregroundColor ?? Colors.white,
//                           )
//                         : IconTheme(
//                             data: IconThemeData(
//                               color: widget.foregroundColor ?? Colors.white,
//                             ),
//                             child: widget.child,
//                           ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
