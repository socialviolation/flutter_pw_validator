library flutter_pw_validator;

import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/Utilities/ConditionsHelper.dart';
import 'package:flutter_pw_validator/Utilities/Validator.dart';
import 'Components/ValidationBarWidget.dart';
import 'Components/ValidationTextWidget.dart';
import 'Resource/Strings.dart';
import 'Resource/MyColors.dart';

class FlutterPwValidator extends StatefulWidget {
  final int minLength, uppercaseCharCount, numericCharCount, specialCharCount;
  final Color defaultColor, successColor, failureColor;
  final Function onSuccess;
  final TextEditingController controller;
  final bool hideWhileInactive;
  final FocusNode? focusNode;
  final Duration? duration;

  FlutterPwValidator(
      {required this.minLength,
      required this.onSuccess,
      required this.controller,
      this.uppercaseCharCount = 0,
      this.numericCharCount = 0,
      this.specialCharCount = 0,
      this.defaultColor = MyColors.gray,
      this.successColor = MyColors.green,
      this.failureColor = MyColors.red,
      this.hideWhileInactive = false,
      this.focusNode,
      this.duration = const Duration(milliseconds: 500)});

  @override
  State<StatefulWidget> createState() => new _FlutterPwValidatorState();
}

class _FlutterPwValidatorState extends State<FlutterPwValidator> with SingleTickerProviderStateMixin {
  /// Estimate that this the first run or not
  late bool isFirstRun;

  /// Variables that hold current condition states
  dynamic hasMinLength, hasMinUppercaseChar, hasMinNumericChar, hasMinSpecialChar;

  //Initial instances of ConditionHelper and Validator class
  ConditionsHelper conditionsHelper = new ConditionsHelper();
  late AnimationController expandController;
  late Animation<double> yAnimation;

  /// Get called each time that user entered a character in EditText
  void validate() {
    /// For each condition we called validators and get their new state
    hasMinLength = conditionsHelper.checkCondition(
        widget.minLength, Validator.hasMinLength, widget.controller, Strings.min(widget.minLength), hasMinLength);

    hasMinUppercaseChar = conditionsHelper.checkCondition(widget.uppercaseCharCount, Validator.hasMinUppercase,
        widget.controller, Strings.uppercase(widget.uppercaseCharCount), hasMinUppercaseChar);

    hasMinNumericChar = conditionsHelper.checkCondition(widget.numericCharCount, Validator.hasMinNumericChar,
        widget.controller, Strings.numeric(widget.numericCharCount), hasMinNumericChar);

    hasMinSpecialChar = conditionsHelper.checkCondition(widget.specialCharCount, Validator.hasMinSpecialChar,
        widget.controller, Strings.special(widget.specialCharCount), hasMinSpecialChar);

    /// Checks if all condition are true then call the user callback
    int conditionsCount = conditionsHelper.getter()!.length;
    int trueCondition = 0;
    for (bool value in conditionsHelper.getter()!.values) {
      if (value == true) trueCondition += 1;
    }
    if (conditionsCount == trueCondition) widget.onSuccess();

    //Rebuild the UI
    setState(() => null);
    trueCondition = 0;
  }

  @override
  void initState() {
    super.initState();
    isFirstRun = true;

    /// Sets user entered value for each condition
    conditionsHelper.setSelectedCondition(
        widget.minLength, widget.uppercaseCharCount, widget.numericCharCount, widget.specialCharCount);

    /// Adds a listener callback on TextField to run after input get changed
    widget.controller.addListener(() {
      isFirstRun = false;
      validate();
    });

    if (widget.focusNode != null) {
      expandController = AnimationController(vsync: this, duration: widget.duration);
      yAnimation = CurvedAnimation(parent: expandController, curve: Curves.fastOutSlowIn);

      widget.focusNode!.addListener(() {
        if (widget.focusNode!.hasFocus) {
          expandController.forward();
        } else {
          expandController.reverse();
        }
      });
    }
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Iterate through the conditions map values to check if there is any true values then create green ValidationBarComponent.
            for (bool value in conditionsHelper.getter()!.values)
              if (value == true) ValidationBarComponent(color: widget.successColor),

            // Iterate through the conditions map values to check if there is any false values then create red ValidationBarComponent.
            for (bool value in conditionsHelper.getter()!.values)
              if (value == false) ValidationBarComponent(color: widget.defaultColor)
          ],
        ),
        SizedBox(height: 4),
        if (widget.hideWhileInactive && widget.focusNode != null)
          SizeTransition(axisAlignment: 1.0, sizeFactor: yAnimation, child: _validation(context))
        else
          _validation(context)
      ],
    );
  }

  Widget _validation(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //Iterate through the condition map entries and generate new ValidationTextWidget for each item in Green or Red Color
        children: conditionsHelper.getter()!.entries.map((entry) {
          int? value;
          if (entry.key.contains(Strings.AT_LEAST)) value = widget.minLength;
          if (entry.key.contains(Strings.UPPERCASE_LETTER)) value = widget.uppercaseCharCount;
          if (entry.key.contains(Strings.NUMERIC_CHARACTER)) value = widget.numericCharCount;
          if (entry.key.contains(Strings.SPECIAL_CHARACTER)) value = widget.specialCharCount;
          return ValidationTextWidget(
            color: isFirstRun
                ? widget.defaultColor
                : entry.value
                    ? widget.successColor
                    : widget.failureColor,
            text: entry.key,
            value: value,
          );
        }).toList());
  }
}

typedef PwValidator<T> = String? Function(T? value);
class PwValidators {
  static PwValidator<T> validate<T>(
      BuildContext context,
      String? errorText, {
        int minLength = 0,
        int upper = 0,
        int numeric = 0,
        int special = 0,
      }) => (T? valueCandidate) {
      if (valueCandidate == null || (valueCandidate is String && valueCandidate.trim().isEmpty)) {
        return errorText ?? "Invalid";
      }
      var vcStr = valueCandidate.toString();
      var isValid = Validator.hasMinLength(vcStr, minLength) &&
          Validator.hasMinUppercase(vcStr, upper) &&
          Validator.hasMinNumericChar(vcStr, numeric) &&
          Validator.hasMinSpecialChar(vcStr, special);

      return !isValid ? errorText ?? "Invalid" : null;
    };
}

