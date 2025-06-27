// body: isLoading
//           ? const Center(
//               child: CircularProgressIndicator(
//                 color: Color(0xFF9ECF9A),
//               ),
//             )
//           : Container(
//               color: const Color(0xFFFAFCFA),
//               width: double.infinity,
//               height: double.infinity,
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const SizedBox(
//                       height: 30,
//                     ),
//                     SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               width: 40,
//                               height: 1,
//                               color: const Color(0xFFB2C1C0),
//                             ),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             Text(
//                               "Select a Tee sheet",
//                               style: GoogleFonts.poppins(
//                                   color: const Color(0xFF244065),
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.w600),
//                             ),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             Container(
//                               width: 40,
//                               height: 1,
//                               color: const Color(0xFFB2C1C0),
//                             ),
//                           ],
//                         )),
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           top: 15, left: 20, right: 20, bottom: 20),
//                       child: Text(
//                         "Select a tee sheet to book a tee time or enjoy other activities.",
//                         textAlign: TextAlign.center,
//                         style: GoogleFonts.poppins(
//                           color: const Color(0xFF6E7373),
//                           fontWeight: FontWeight.w400,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ),
//                     FutureBuilder<String?>(
//                       future: secureStorage.read(key: 'golfCourseLogo'),
//                       builder: (context, snapshot) {
//                         final url = snapshot.data ?? '';
//                         if (url.isNotEmpty) {
//                           return Image.network(
//                             url,
//                             fit: BoxFit.cover,
//                             width: 100,
//                             height: 100,
//                           );
//                         } else {
//                           return Image.asset(
//                             'assets/images/golf_ground.png',
//                             fit: BoxFit.cover,
//                             width: 100,
//                             height: 100,
//                           );
//                         }
//                       },
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Column(
//                           children: [
//                             Text(
//                               'Select Facility',
//                               style: GoogleFonts.poppins(
//                                 color: const Color(0xFF6E7373),
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             const SizedBox(height: 20),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 38.0),
//                               child: CompositedTransformTarget(
//                                 link: _layerLink,
//                                 child: Column(
//                                   children: [
//                                     GestureDetector(
//                                       onTap: toggleDropdown,
//                                       child: Container(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 15, vertical: 8),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(
//                                             color: isDropdownOpen
//                                                 ? const Color(
//                                                     0xFF9ECF9A) // Focused/Open border color
//                                                 : const Color(
//                                                     0xFFB2C1C0), // Enabled border color
//                                             width: 1.0,
//                                           ),
//                                           borderRadius:
//                                               BorderRadius.circular(50),
//                                         ),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text(
//                                               selectedItem,
//                                               style: GoogleFonts.poppins(
//                                                 fontSize: 14,
//                                                 color: const Color(0xFF244065),
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                             ),
//                                             Icon(isDropdownOpen
//                                                 ? Icons.arrow_drop_up
//                                                 : Icons.arrow_drop_down),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             // ✅ Show error below the field — NOT inside Stack
//                             if (holdingNtrError != null)
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 12.0, top: 6),
//                                 child: Text(
//                                   holdingNtrError!,
//                                   style: const TextStyle(
//                                     color: Colors.red,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                         const SizedBox(
//                           height: 15,
//                         ),
//                         Column(
//                           children: _reservationGroups.map((group) {
//                             final String label =
//                                 group['name']?.toString() ?? 'Unnamed';
//                             return Padding(
//                               padding: const EdgeInsets.only(
//                                   left: 38, right: 38, bottom: 15),
//                               child: Stack(
//                                 children: [
//                                   SizedBox(
//                                     width: double.infinity,
//                                     child: ElevatedButton(
//                                       onPressed: () {
//                                         if (_selectedTeesheet == null) return;

//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (_) => TeesheetPage(
//                                               id: _selectedTeesheet!['_id']
//                                                       ?.toString() ??
//                                                   '',
//                                               name: _selectedTeesheet!['name']
//                                                       ?.toString() ??
//                                                   '',
//                                               logoUrl: _selectedTeesheet![
//                                                           'golfCourseLogo']
//                                                       ?.toString() ??
//                                                   '',
//                                               userId: widget.userId,
//                                               teesheetPageId:
//                                                   _selectedTeesheet?['_id']
//                                                           ?.toString() ??
//                                                       '',
//                                               reservationGroupId:
//                                                   group['_id']?.toString() ??
//                                                       '',
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor:
//                                             const Color(0xFF9ECF9A),
//                                       ),
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 15.0, vertical: 10.0),
//                                         child: Center(
//                                           child: Text(
//                                             label,
//                                             style: GoogleFonts.poppins(
//                                               color: Colors.white,
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   const Positioned(
//                                     top: 16.5,
//                                     right: 15,
//                                     child: Icon(Icons.arrow_forward,
//                                         color: Colors.white, size: 18),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }).toList(),
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ), // temporary body
