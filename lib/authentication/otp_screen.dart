import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? otpCode; 

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // get the arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String verificationId = args[Constants.verificationId] as String;
    final String phoneNumber = args[Constants.phoneNumber] as String;

    final authProvider = context.watch<AuthenticationProvider>();


    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'OTP Verification',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please enter the OTP sent to your phone number.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  phoneNumber,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50, 
                  child: Pinput(
                    length: 6,
                    controller: controller,
                    focusNode: focusNode,
                    defaultPinTheme: defaultPinTheme,
                    onCompleted: (pin) {
                      setState(() {
                        otpCode = pin;
                      });
                      // verify otp code
                      verifyOTPCode(
                        verificationId: verificationId,
                        otpCode: otpCode,
                      );
                    },
                    focusedPinTheme: defaultPinTheme.copyWith(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple,
                      ),
                    ) ,
                    errorPinTheme: defaultPinTheme.copyWith(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height:20 ),
                authProvider.isLoading
                ? const CircularProgressIndicator()
                : const SizedBox.shrink(),

                authProvider.isSuccessful ? Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 30,
                  ),
                ): const SizedBox.shrink(),
                authProvider.isLoading ?  const SizedBox.shrink():
                Text('Didn\'t receive the code?',style:GoogleFonts.openSans(fontSize: 16) ,),
                const SizedBox(height: 10), 
                authProvider.isLoading ?  const SizedBox.shrink():
                TextButton(
                  onPressed: () {
                    // todo resend otp code
                  },
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void verifyOTPCode({
    required String verificationId, 
    required otpCode}) async {
      final authProvider = context.read<AuthenticationProvider>();
      authProvider.verifyOtpCode(
        verificationId: verificationId,
        otpCode: otpCode,
        context: context,
        onSuccess: () async {
          // 1. check if user exists in firestore
          bool userExists = await authProvider.checkUserExists();

          if(userExists){
            // 2. if user exists

          // * get user informatio  from firestore
          await authProvider.getUserDataFromFireStore();


          // * save user information to provider / shared preferences
          await authProvider.saveUserDataToSharedPreferences();
          // * navigate to home screen
            
          navigate(userExists:true);
          }
          else{
          // 3. if user does not exist, navigate to user information screen
            navigate(userExists: false);
          }

         
          
      },
    );
  }
  
  void navigate({required bool userExists}) {
    if(userExists){
      Navigator.pushNamedAndRemoveUntil(
        context,
        Constants.homeScreen,
        (route) => false,
      );
    }
    else{
      Navigator.pushNamed(
        context,
        Constants.userInformationScreen,
      );
    }
  }
}