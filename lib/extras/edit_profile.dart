import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gulf_app/screens/login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gulf_app/components/custom_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/components/custom_bottom_nav_bar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class MyEditPage extends StatefulWidget {
  final String myEdId;
  const MyEditPage({super.key, required this.myEdId});

  @override
  State<StatefulWidget> createState() => MyEditPageState();
}

class MyEditPageState extends State<MyEditPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final TextEditingController _dateController = TextEditingController();
  bool isLoading = false;
  bool isDateFieldFocused = false; // Rename from isLoading for clarity
  String? dobError;
  DateTime? _selectedDate;
  bool _isExpanded = true;
  bool _isLoginInfo = true;
  final customerIdText = TextEditingController();
  final fullNmText = TextEditingController();
  final lastNmText = TextEditingController();
  final emailIdText = TextEditingController();
  final phoneNoText = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipController = TextEditingController();
  final passText = TextEditingController();
  bool _isPassVisible = false;
  String? passError;
  String? emailError;
  String? phoneError;
  String? firstNameError;
  String? lastNameError;
  String? customerIdError;
  String? addressError;
  String? cityError;
  String? stateError;
  String? zipError;
  @override
  void dispose() {
    phoneNoText.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _dateController.text = DateFormat("MMM dd, yyyy").format(now);
  }
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
  void _showDatePicker(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, -1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Align(
          alignment: const FractionalOffset(0.5, 0.42),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Container(
              height: 400,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20), bottom: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SfDateRangePicker(
                    initialSelectedDate: _selectedDate,
                    selectionMode: DateRangePickerSelectionMode.single,
                    backgroundColor: Colors.white,
                    selectionColor: const Color(0xFF9ECF9A),
                    todayHighlightColor: const Color(0xFF9ECF9A),
                    headerStyle: DateRangePickerHeaderStyle(
                      backgroundColor: Colors.transparent,
                      textStyle: GoogleFonts.poppins(
                        color:  Color(0xFF3F4B4B),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onSelectionChanged:
                        (DateRangePickerSelectionChangedArgs args) {
                      setState(() {
                        _selectedDate = args.value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() => isDateFieldFocused = false); // Reset border
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                                width: 1.5, color: Color(0xFF9ECF9A)),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF244065),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          if (_selectedDate != null) {
                            final formattedDate =
                            DateFormat("MMM dd, yyyy").format(_selectedDate!);
                            setState(() {
                              _dateController.text = formattedDate;
                              isDateFieldFocused = false; // Reset border
                            });
                          }
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF9ECF9A),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                                width: 1.5, color: Color(0xFF9ECF9A)),
                          ),
                        ),
                        child: Text(
                          "OK",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.myEdId, // ✅ Pass the correct userId
        showLeading: true, // ✅ Set to true to show the back button
        onBackPressed: () {
          Navigator.pop(context); // Optional: customize back behavior if needed
        },
      ),
      drawer: CustomDrawer(
        activeTile: 'Home',
        onTileTap: (selectedTile) {
          //print("Navigating to $selectedTile");
          // Handle navigation logic
        },
      ),
      body: Container(
        color: Color(0xFFFAFCFA),
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 15,
              ),
              Container(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 1,
                          color: Color(0xFFB2C1C0),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Edit Profile",
                          style: GoogleFonts.poppins(
                              color: Color(0xFF244065),
                              fontSize: 22,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: 40,
                          height: 1,
                          color: Color(0xFFB2C1C0),
                        ),
                      ],
                    )),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 10,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        clipBehavior: Clip.none, // allow overflow
                        width: 162,
                        height: 162, // slightly larger to allow overflow
                        child: Stack(
                          clipBehavior: Clip
                              .none, // important for visibility outside the stack
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.asset(
                                  "assets/images/profile_prsn.jpg",
                                  width: 162,
                                  height: 162,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -10,
                              left: 65,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(0xFF9ECF9A),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100)),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.edit,
                                    size: 17,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header Row with Toggle Arrow
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFB2C1C0),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Account information",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF244065),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Icon(
                              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 22,
                              color: const Color(0xFF669933),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Expandable Fields
                    if (_isExpanded) ...[
                      _buildLabel("Customer ID"),
                      SizedBox(height: 10),
                      _buildTextField(customerIdText),
                      if (customerIdError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, top: 5),
                          child: Text(
                            customerIdError!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHalfField("First Name", fullNmText),
                                if (firstNameError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0, top: 5),
                                    child: Text(
                                      firstNameError!,
                                      style: const TextStyle(color: Colors.red, fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHalfField("Last Name", lastNmText),
                                if (lastNameError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0, top: 5),
                                    child: Text(
                                      lastNameError!,
                                      style: const TextStyle(color: Colors.red, fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildLabel("Email"),
                      SizedBox(height: 10),
                      _buildTextField(emailIdText, isEmail: true),
                      if (emailError!= null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, top: 5),
                          child: Text(
                            emailError!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 15),
                      _buildLabel("Phone Number"),
                      SizedBox(height: 10),
                      _buildTextField(phoneNoText, isPhone: true),
                      if (phoneError!= null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, top: 5),
                          child: Text(
                            phoneError!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 15),
                      _buildLabel("Date of brith"),
                      SizedBox(height: 10),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color: isDateFieldFocused ? Color(0xFF9ECF9A) : const Color(0xFFB2C1C0),
                            width: 1,
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isDateFieldFocused = true;
                              });
                              _showDatePicker(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12.8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _dateController.text.isNotEmpty
                                        ? _dateController.text
                                        : "Select Date",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF244065),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: Color(0xFF648683),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (dobError!= null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, top: 5),
                          child: Text(
                            dobError!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 15),
                      _buildLabel("Address"),
                      SizedBox(height: 10),
                      _buildTextField(addressController, maxLines: 1),
                      if (addressError!= null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, top: 5),
                          child: Text(
                            addressError!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 15),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 15,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.44,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHalfField("City", cityController),
                                if (cityError!= null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0, top: 5),
                                    child: Text(
                                      cityError!,
                                      style: const TextStyle(color: Colors.red, fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.44,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHalfField("State", stateController),
                                if (stateError!= null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0, top: 5),
                                    child: Text(
                                      stateError!,
                                      style: const TextStyle(color: Colors.red, fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.44,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHalfField("Zip", zipController),
                                if (zipError!= null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0, top: 5),
                                    child: Text(
                                      zipError!,
                                      style: const TextStyle(color: Colors.red, fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                    ],
                  ],
                ),
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLoginInfo = !_isLoginInfo;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFB2C1C0),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Login information",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF244065),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Icon(
                              _isLoginInfo ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 22,
                              color: const Color(0xFF669933),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    if(_isLoginInfo) ...[
                      _buildLabel("Email"),
                      SizedBox(height: 10),
                      _buildTextField(emailIdText, isEmail: true),
                      if (emailError!= null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, top: 5),
                          child: Text(
                            emailError!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 15),
                      _buildLabel("Password"),
                      const SizedBox(height: 10),
                      _buildTextField(
                        passText,
                        isPassword: true,
                        obscureText: !_isPassVisible,
                        onToggleVisibility: () {
                          setState(() {
                            _isPassVisible = !_isPassVisible;
                          });
                        },

                      ),
                      if (passError!= null && passText.text.length < 6)
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, top: 5),
                          child: Text(
                            passError!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 15),
                    ],
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () {
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context)=> SignupPage()));
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  minimumSize: MaterialStateProperty.all(Size.zero),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                ),
                child: Text(
                  "Update your password",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF669933),
                    height: 1.0,
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF669933), // underline color same as text
                  ),
                ),
              ),
              SizedBox(height: 15,),
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 7,
                  children: [
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          // Your onTap action here
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                                color: Color(0xFF9ECF9A), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 3,
                                spreadRadius: 1,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 7),
                          child: Center(
                            child: Text(
                              "Clear",
                              style: GoogleFonts.poppins(
                                color: Color(0xFF244065),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            // Reset errors
                            emailError = null;
                            phoneError = null;
                            passError = null;
                            dobError = null;
                            firstNameError = null;
                            lastNameError = null;
                            customerIdError = null;
                            addressError = null;
                            cityError = null;
                            stateError = null;
                            zipError = null;

                            // Validate
                            if (customerIdText.text.isEmpty) {
                              customerIdError = "Customer ID is required";
                            }
                            if (fullNmText.text.isEmpty) {
                              firstNameError = "First Name is required";
                            }
                            if (cityController.text.isEmpty) {
                              cityError = "City Name is required";
                            }
                            if (stateController.text.isEmpty) {
                              stateError = "State Name is required";
                            }
                            if (addressController.text.isEmpty) {
                              addressError = "Address is required";
                            }
                            if (zipController.text.isEmpty) {
                              zipError = "Zip code is required";
                            }
                            if (lastNmText.text.isEmpty) {
                              lastNameError = "Last Name is required";
                            }
                            if (emailIdText.text.isEmpty || !emailIdText.text.contains("@")) {
                              emailError = "Enter a valid email";
                            }
                            if (phoneNoText.text.isEmpty || phoneNoText.text.length != 10) {
                              phoneError = "Enter a valid phone number";
                            }
                            if (_dateController.text.isEmpty) {
                              dobError = "Date of birth is required";
                            }
                            if (passText.text.isEmpty) {
                              passError = "Password is required";
                            }
                            if (passText.text.length < 6) {
                              passError = "Password must be at least 6 characters";
                            }

                            // If no errors, proceed
                            if (emailError == null &&
                                phoneError == null &&
                                passError == null &&
                                dobError == null &&
                                firstNameError == null &&
                                lastNameError == null &&
                                customerIdError == null &&
                            cityError == null &&
                            stateError == null &&
                            zipError == null &&
                            addressError == null) {
                              // All fields valid — proceed to save or navigate
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => MyCartPage(myCartId: '')));
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF9ECF9A),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                                color: Color(0xFF9ECF9A), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 3,
                                spreadRadius: 1,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 7),
                          child: Center(
                            child: Text(
                              "Save",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),
            ],
          )),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: 0),
    );
  }
  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(
          color: Color(0xFF9ECF9A),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(
          color: Colors.white,
          width: 1,
        ),
      ),
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        color: const Color(0xFF6E7373),
        fontSize: 14,
      ),
    );
  }
  Widget _buildLabel(String label) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 15),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: const Color(0xFF6E7373),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
  Widget _buildTextField(
      TextEditingController controller, {
        bool isEmail = false,
        bool isPhone = false,
        bool isPassword = false,
        bool obscureText = false,
        VoidCallback? onToggleVisibility,
        int maxLines = 1,
        String? errorText,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: errorText != null ? Colors.red : const Color(0xFFB2C1C0),
                width: 1,
              ),
            ),
            child: TextField(
              controller: controller,
              obscureText: isPassword ? obscureText : false,
              keyboardType: isEmail
                  ? TextInputType.emailAddress
                  : isPhone
                  ? TextInputType.phone
                  : TextInputType.multiline,
              textInputAction: TextInputAction.done,
              inputFormatters:
              isPhone ? [FilteringTextInputFormatter.digitsOnly] : null,
              maxLines: maxLines,
              decoration: _inputDecoration(isPassword ? '**********' : '').copyWith(
                suffixIcon: isPassword
                    ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF648683),
                  ),
                  onPressed: onToggleVisibility,
                )
                    : const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.edit,
                    color: Color(0xFF6B7280),
                    size: 18,
                  ),
                ),
              ),
              style: GoogleFonts.poppins(
                color: const Color(0xFF244065),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              autofillHints: isPassword ? [AutofillHints.password] : null,
            ),
          ),
          if (errorText != null)
            const SizedBox(height: 5),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                errorText,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHalfField(String label, TextEditingController controller) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const SizedBox(height: 10),
          _buildTextField(controller),
        ],
      ),
    );
  }
}
