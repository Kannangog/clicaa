import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/utilities/assets_manager.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  Country selectedCountry = Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: 'India',
    displayName: 'India',
    displayNameNoCountryCode: 'IN',
    e164Key: '',
  );

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 50),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Lottie.asset(AssetsManager.chatBubble),
                ),
                Text(
                  'Clica',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add your phone number to get started',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneNumberController,
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: 'Phone Number',
                    prefixIcon: Container(
                      padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: true,
                            countryListTheme: CountryListThemeData(
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              textStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              bottomSheetHeight: 500,
                            ),
                            onSelect: (Country country) {
                              setState(() {
                                selectedCountry = country;
                              });
                            },
                          );
                        },
                        child: Text(
                          ' ${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    suffixIcon: _phoneNumberController.text.length > 9
                        ? authProvider.isLoading
                            ? const Padding(
                              padding:  EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            )
                            : InkWell(
                                onTap: () {
                                  authProvider.signInWithPhoneNumber(
                                    '+${selectedCountry.phoneCode}${_phoneNumberController.text}',
                                    context,
                                  );
                                },
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  margin: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                  child: const Icon(
                                    Icons.done,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}