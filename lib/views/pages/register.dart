import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_validation_flutter/core/utils/enum/education.dart';
import 'package:form_validation_flutter/core/utils/enum/input.dart';
import 'package:form_validation_flutter/core/utils/input_validator.dart';
import 'package:form_validation_flutter/core/utils/string.dart';
import 'package:form_validation_flutter/core/utils/utils.dart';
import 'package:form_validation_flutter/models/personal_info.dart';
import 'package:form_validation_flutter/view_model/provider/register.dart';
import 'package:form_validation_flutter/views/pages/address.dart';
import 'package:form_validation_flutter/views/widgets/dropdown.dart';
import 'package:form_validation_flutter/views/widgets/register_header.dart';
import 'package:form_validation_flutter/views/widgets/social_button.dart';
import 'package:form_validation_flutter/views/widgets/textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with InputValidator {
  final aadharNumberController = TextEditingController();
  final fullNameController = TextEditingController();
  final bankAccController = TextEditingController();
  final dobController = TextEditingController();
  final formGlobalKey = GlobalKey<FormState>();
  late RegisterNotifier registerNotifier;
  DateTime? selectedDateTime;

  updateDOBTF() {
    if (selectedDateTime == null) {
      Utiliy.showErrorSnackbar(context,
          message: "Please select your Date of Birth");
    } else {
      dobController.text =
          "${selectedDateTime?.day.toString().padLeft(2, '0')}-${selectedDateTime?.month.toString().padLeft(2, '0')}-${selectedDateTime?.year.toString().padLeft(4, '0')}";
    }
    setState(() {});
  }

  void showDate() async {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
          context: context,
          builder: (_) => Container(
                height: 190,
                color: const Color.fromARGB(255, 255, 255, 255),
                child: Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: DateTime.now(),
                          onDateTimeChanged: (val) {
                            selectedDateTime = val;
                            updateDOBTF();
                            setState(() {});
                          }),
                    ),
                  ],
                ),
              ));
    } else {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1980),
        lastDate: DateTime.now(),
      );
      selectedDateTime = date;
      updateDOBTF();
    }
  }

  void onRegisterTap() {
    if (formGlobalKey.currentState?.validate() ?? false) {
      formGlobalKey.currentState!.save();
      if (registerNotifier.education == null) {
        Utiliy.showErrorSnackbar(context, message: "Please Select Education");
      } else if (dobController.text == "") {
        Utiliy.showErrorSnackbar(context, message: "Please Select DOB");
      } else {
        try {
          registerNotifier.personalInfo = PersonalInfo(
            aadharNumber: int.parse(aadharNumberController.text),
            bankAccount: int.parse(bankAccController.text),
            dob: dobController.text,
            education: registerNotifier.education!,
            fullName: fullNameController.text,
          );
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: ((context) => const AddressInfoScreen())));
        } catch (e) {
          Utiliy.showErrorSnackbar(context, message: "$e");
        }
      }
    } else {
      Utiliy.showErrorSnackbar(context, message: "Please enter all details");
    }
  }

  @override
  void initState() {
    registerNotifier = Provider.of<RegisterNotifier>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: personalForm(context),
            ),
          ),
        ),
      ),
    );
  }

  Form personalForm(BuildContext context) {
    return Form(
      key: formGlobalKey,
      child: personalUserInputFields(context),
    );
  }

  Column personalUserInputFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RegisterHeader(
          header: "Personal Info",
        ),
        RegisterTextField(
          labelText: "Enter Aadhar ID",
          hintText: "4232 **** **** **23",
          leadingIcon: Icons.account_balance_wallet_rounded,
          controller: aadharNumberController,
          textInputType: TextInputType.number,
          validator: validateAadharID,
          inputType: InputType.aadhar,
        ),
        const SizedBox(
          height: 20,
        ),
        RegisterTextField(
          labelText: "Enter Fullname",
          hintText: "Raj ",
          leadingIcon: Icons.account_circle_rounded,
          controller: fullNameController,
          textInputType: TextInputType.name,
          validator: validateFullName,
          inputType: InputType.fullName,
        ),
        const SizedBox(
          height: 20,
        ),
        RegisterTextField(
          labelText: "Back Account",
          hintText: "",
          controller: bankAccController,
          leadingIcon: Icons.account_balance,
          inputType: InputType.bankAccount,
          validator: validateBankAccNumber,
          textInputType: TextInputType.number,
        ),
        const SizedBox(
          height: 20,
        ),
        educationDropdown(),
        const SizedBox(
          height: 20,
        ),
        InkWell(
          onTap: () {
            showDate();
          },
          child: RegisterTextField(
            labelText: "DOB",
            hintText: "",
            enabled: false,
            controller: dobController,
            leadingIcon: Icons.calendar_today,
            inputType: InputType.dob,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        RegisterButton(
          onPressed: onRegisterTap,
          text: "Proceed",
        ),
        const SizedBox(
          height: 20,
        ),
        Center(
          child: Text(
            "OR",
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SocialLoginButton(
              iconData: Icons.facebook,
            ),
            SizedBox(
              width: 20,
            ),
            SocialLoginButton(iconData: Icons.web),
          ],
        ),
      ],
    );
  }

  Consumer<RegisterNotifier> educationDropdown() {
    return Consumer<RegisterNotifier>(builder: (_, a, child) {
      return RegisterDropdown<Education?>(
          hintText: "Select your Education",
          value: a.education,
          items: Education.values
              .map((e) => DropdownMenuItem<Education>(
                  value: e, child: Text(e.name.capitalize())))
              .toList(),
          onChanged: (val) => a.education = val);
    });
  }
}

class RegisterButton extends StatelessWidget {
  const RegisterButton(
      {Key? key,
      this.onPressed,
      required this.text,
      this.btnColor,
      this.childColor})
      : super(key: key);

  final VoidCallback? onPressed;
  final String text;
  final Color? btnColor;
  final Color? childColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 0.4,
          blurRadius: 4,
          offset: const Offset(1, 1),
        ),
      ]),
      width: double.infinity,
      height: 50,
      child: TextButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              btnColor ?? Colors.white,
            ),
            foregroundColor: MaterialStateProperty.all(
              childColor ?? Colors.grey[600],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
              )
            ],
          )),
    );
  }
}

typedef StringCallback = Function(String? params);
typedef ValidatorCallback = String? Function(String? params);
