//Im/2021/028
import 'package:flutter/material.dart';
import 'package:flutter_application_1/button_values.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String equation = ""; // The input string
  String output = "0"; // The calculated result
  List<String> history = []; // History list
  bool lastActionWasCalculation = false; // Track if the last action was a calculation


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // History display (take up half the screen)
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.black12,
                child: Column(
                  children: [
                    // Toolbar with icons for history
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Clear History Icon
                          IconButton(
                            icon: const Icon(Icons.delete_forever),
                            onPressed: () {
                              setState(() {
                                history.clear(); // Clear history
                              });
                            },
                            tooltip: 'Clear History',
                            color: Colors.redAccent,
                            iconSize: 30.0,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        reverse: true,
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                equation = history[index].split(' = ')[0];
                              });
                              calculate(finalize: false); // Recalculate
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Text(
                                history[index],
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Result display (take up the remaining half)
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                reverse: true,
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Equation line
                      Text(
                        equation.isEmpty ? "0" : equation,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),

                      // Result line
                      Text(
                        "= $output",
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Divider line
            Container(
              width: double.infinity,
              height: 0.5,
              color: Colors.white54,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            ),

            // Buttons
            Wrap(
              children: Btn.buttonValues
                  .map(
                    (value) => SizedBox(
                      width: value == Btn.calculate
                          ? screenSize.width / 2 // Make the equals button span two spaces
                          : screenSize.width / 4, // Default width for other buttons
                      height: screenSize.width / 6,
                      child: buildButton(value),
                    ),
                  )
                  .toList(),
            )
          ],
        ),
      ),
    );
  }

  void onBtnTap(String value) {
    // Reset the equation if the last action was a calculation
    if (lastActionWasCalculation && RegExp(r'\d').hasMatch(value)) {
      setState(() {
        equation = value; // Start a new equation with the pressed number
        lastActionWasCalculation = false; // Reset the flag
      });
      calculate(finalize: false);
      return;
    }

    if (value == Btn.del) {
      delete();
      return;
    }

    if (value == Btn.clr) {
      clearAll();
      return;
    }

    if (value == Btn.calculate) {
      calculate(finalize: true);
      return;
    }

    if (value == Btn.per) {
      convertToPercentage();
      return;
    }

    if (value == Btn.squareroot) {
      handleSquareRoot(); // Call the updated handleSquareRoot method
      return;
    }

    if (value == Btn.plusOrminus) {
      toggleSign(); // Call toggleSign method directly
      return;
    }

    // Handle dot logic
    if (value == Btn.dot) {
      setState(() {
        final lastNumber = equation.split(RegExp(r'[+\-×÷]')).last;
        if (!lastNumber.contains('.')) {
          equation += equation.isEmpty ? "0." : ".";
        }
      });
      calculate(finalize: false);
      return;
    }

    // Handle operator logic
    if (RegExp(r'[+\-×÷]').hasMatch(value)) {
      setState(() {
        if (equation.isEmpty) {
          equation = "0$value"; // Starting with 0 if empty
        } else if (RegExp(r'[+\-×÷]$').hasMatch(equation)) {
          equation = equation.substring(0, equation.length - 1) +
              value; // Replace last operator
        } else {
          if (lastActionWasCalculation) {
            // If last action was a calculation, append the operator to the result
            equation = "$output$value";
          } else {
            equation += value;
          }
        }
      });
      calculate(finalize: false);
      return;
    }

    // Append number or operator to the equation
    setState(() {
      equation += value;
    });

    // Dynamically calculate result
    calculate(finalize: false);
  }

  void calculate({bool finalize = false}) {
    try {
      // Handle trailing operators (ignore last operator if present)
      String expression = equation;
      if (RegExp(r'[+\-×÷%]$').hasMatch(expression)) {
        expression = expression.substring(0, expression.length - 1);
      }

      // Replace custom operators with standard ones for evaluation
      expression = expression.replaceAll(Btn.multiply, '*');
      expression = expression.replaceAll(Btn.divide, '/');
      expression = expression.replaceAll('√', 'sqrt'); // Handle square root

      // Add explicit multiplication for adjacent parentheses or number-parentheses
      expression = expression.replaceAllMapped(RegExp(r'(\d)(\()'),
          (match) => '${match[1]}*${match[2]}'); // Number before '('
      expression = expression.replaceAllMapped(RegExp(r'\)(\d)'),
          (match) => '${match[1]}*${match[2]}'); // ')' before number
      expression = expression.replaceAllMapped(
          RegExp(r'\)\('), (match) => ')*('); // ')' before '('

      // Check for division by zero
      if (expression.contains('/0')) {
        setState(() {
          output = "Can't divide by zero"; // Custom error message
        });
        return;
      }

      // Check for mismatched brackets
      if (_countOccurrences(expression, '(') !=
          _countOccurrences(expression, ')')) {
        setState(() {
          output = "Error"; // Mismatched brackets
        });
        return;
      }

      // Handle square root cases explicitly
      if (finalize && RegExp(r'sqrt\(([^()]+)\)').hasMatch(expression)) {
        final matches = RegExp(r'sqrt\(([^()]+)\)').allMatches(expression);

        for (var match in matches) {
          String innerExpression = match.group(1)!;
          double? value = double.tryParse(innerExpression);

          if (value == null || value < 0) {
            setState(() {
              output = "Invalid Input"; // Handle invalid or negative inputs
            });
            return;
          }

          // Replace square root with its calculated value
          double sqrtValue = sqrt(value);
          expression = expression.replaceFirst(
            match.group(0)!,
            sqrtValue % 1 == 0
                ? sqrtValue.toInt().toString()
                : sqrtValue
                    .toStringAsFixed(10)
                    .replaceFirst(RegExp(r'0+$'), ' ')
                    .replaceFirst(RegExp(r'\.$'), ''),
          );
        }
      }

      // Parse and evaluate the final expression
      final parser = Parser();
      final exp = parser.parse(expression);
      final result = exp.evaluate(EvaluationType.REAL, ContextModel());

      setState(() {
        if (result % 1 == 0) {
          output = result.toInt().toString(); // Display as an integer
        } else {
          output = result
              .toStringAsFixed(10)
              .replaceFirst(RegExp(r'0+$'), ' ')
              .replaceFirst(RegExp(r'\.$'), '');
        }

        if (finalize) {
          lastActionWasCalculation = true; // Mark the action as a calculation
          if (history.isNotEmpty && history[0].endsWith(" = $output")) {
            return;
          }
          history.insert(0, "$equation = $output");
          equation = output;
        }
      });
    } catch (e) {
      setState(() {
        output = "Error"; // Handle invalid expressions
      });
    }
  }

  void delete() {
    setState(() {
      if (equation.isNotEmpty) {
        equation = equation.substring(0, equation.length - 1);
      }
      if (equation.isEmpty) {
        output = "0"; // Reset output if equation is empty
      } else {
        calculate(finalize: false);
      }
    });
  }

  void clearAll() {
    setState(() {
      equation = "";
      output = "0";
    });
  }

  void toggleSign() {
    setState(() {
      if (equation.isEmpty) {
        equation = "-"; // If the equation is empty, start with a negative sign
      } else {
        // Check if the last character is an operator
        if (RegExp(r'[+\-×÷]$').hasMatch(equation)) {
          equation += "(-"; // Append "(-" after an operator
        } else {
          // Split the equation by operators
          final parts = equation.split(RegExp(r'([+\-×÷])'));
          final lastPart = parts.last;

          if (lastPart.startsWith("-")) {
            // If the last number is negative, remove the "-" sign
            equation =
                equation.substring(0, equation.length - lastPart.length) +
                    lastPart.substring(1);
          } else {
            // If the last number is positive, add the "-" sign
            equation =
                "${equation.substring(0, equation.length - lastPart.length)}-$lastPart";
          }
        }
      }
      calculate(finalize: false); // Recalculate dynamically
    });
  }


  void convertToPercentage() {
    try {
      final parser = Parser();
      final exp = parser.parse(equation);
      final result = exp.evaluate(EvaluationType.REAL, ContextModel()) / 100;

      setState(() {
        output = result.toStringAsFixed(2).replaceFirst(RegExp(r'\.00$'), '');
        equation = output;
      });
    } catch (e) {
      setState(() {
        output = "Error";
      });
    }
  }

  void handleSquareRoot() {
    setState(() {
      // If the equation is empty, start with "√("
      if (equation.isEmpty) {
        equation = "√(";
        return;
      }

      // Check if the last character is an operator
      if (RegExp(r'[+\-×÷]$').hasMatch(equation)) {
        equation += "√("; // Append "√(" after the operator
        return;
      }

      // Get the last segment of the equation
      final parts = equation.split(RegExp(r'([+\-×÷])'));
      final lastPart = parts.last;

      // If the last part is a number, calculate the square root
      double? number = double.tryParse(lastPart);

      if (number != null) {
        if (number < 0) {
          // Square root of a negative number is invalid in real numbers
          output = "Invalid Input";
          return;
        }

        double sqrtValue = sqrt(number);
        String sqrtResult = sqrtValue % 1 == 0
            ? sqrtValue.toInt().toString() // Remove decimal for whole numbers
            : sqrtValue
                .toStringAsFixed(10)
                .replaceFirst(RegExp(r'0+$'), '')
                .replaceFirst(RegExp(r'\.$'), '');

        // Replace the last number with its square root
        equation = equation.substring(0, equation.length - lastPart.length) +
            sqrtResult;
      } else {
        // If the last part is not a number, append "√("
        equation += "√(";
      }

      // Recalculate dynamically
      calculate(finalize: false);
    });
  }



  Widget buildButton(String value) {
    final textColor = [
      Btn.clr,
      Btn.del,
      Btn.per,
      Btn.multiply,
      Btn.add,
      Btn.subtract,
      Btn.divide,
      Btn.calculate,
      Btn.squareroot,
      Btn.openbracket,
      Btn.closebracket,
      Btn.plusOrminus
    ].contains(value)
        ? Colors.black
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: getBtnColor(value),
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        elevation: 8,
        shadowColor: Colors.black54,
        child: InkWell(
          splashColor: getBtnColor(value).withOpacity(0.2),
          onTap: () => onBtnTap(value),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Text(
                value,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color getBtnColor(String value) {
    return [
      Btn.del,
      Btn.clr,
    ].contains(value)
        ? Colors.white
        : [
            Btn.per,
            Btn.multiply,
            Btn.divide,
            Btn.add,
            Btn.subtract,
            Btn.calculate,
            Btn.squareroot,
            Btn.openbracket,
            Btn.closebracket,
            Btn.plusOrminus
          ].contains(value)
            ? Colors.orange
            : const Color.fromARGB(255, 68, 71, 90);
  }
  
  int _countOccurrences(String input, String char) {
    return input.split(char).length - 1;
  }
}
