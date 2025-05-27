// ignore_for_file: deprecated_member_use

import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/utilities/assets_manager.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  static const _defaultCountryCode = 'IN';
  static const _defaultPhoneCode = '91';
  
  Country _selectedCountry = Country(
    phoneCode: _defaultPhoneCode,
    countryCode: _defaultCountryCode,
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

  void _handleCountrySelection(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.circular(10),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() => _selectedCountry = country);
      },
    );
  }

  void _handleSignIn(AuthenticationProvider authProvider) {
    if (_phoneNumberController.text.length < 10) return;
    
    authProvider.signInWithPhoneNumber(
      phoneNumber: '+${_selectedCountry.phoneCode}${_phoneNumberController.text}',
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildAppLogo(),
              const SizedBox(height: 20),
              _buildAppTitle(textTheme),
              const SizedBox(height: 20),
              _buildDescriptionText(textTheme),
              const SizedBox(height: 30),
              _buildPhoneInputField(authProvider, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return SizedBox(
      height: 200,
      width: 200,
      child: Lottie.asset(
        AssetsMenager.chatBubble,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildAppTitle(TextTheme textTheme) {
    return Text(
      'Flutter Chat Pro',
      style: GoogleFonts.openSans(
        fontSize: 28,
        fontWeight: FontWeight.w500,
      ).merge(textTheme.headlineSmall),
    );
  }

  Widget _buildDescriptionText(TextTheme textTheme) {
    return Text(
      'Add your phone number. We will send you a verification code',
      textAlign: TextAlign.center,
      style: GoogleFonts.openSans(
        fontSize: 16,
      ).merge(textTheme.bodyMedium),
    );
  }

  Widget _buildPhoneInputField(
    AuthenticationProvider authProvider,
    ThemeData theme,
  ) {
    final isValid = _phoneNumberController.text.length >= 10;
    
    return TextFormField(
      controller: _phoneNumberController,
      maxLength: 10,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      onChanged: (value) => setState(() {}),
      decoration: InputDecoration(
        counterText: '',
        hintText: 'Phone Number',
        hintStyle: GoogleFonts.openSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: _buildCountryCodePicker(theme),
        suffixIcon: isValid ? _buildSubmitButton(authProvider) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildCountryCodePicker(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
      child: InkWell(
        onTap: () => _handleCountrySelection(context),
        child: Text(
          '${_selectedCountry.flagEmoji} +${_selectedCountry.phoneCode}',
          style: GoogleFonts.openSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ).merge(theme.textTheme.bodyMedium),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AuthenticationProvider authProvider) {
    return authProvider.isLoading
        ? const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : IconButton(
            onPressed: () => _handleSignIn(authProvider),
            icon: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.done,
                color: Colors.white,
                size: 20,
              ),
            ),
          );
  }
}