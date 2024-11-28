import 'package:flutter/material.dart';
import 'package:flutter_application_1/button_values.dart';
import 'package:google_fonts/google_fonts.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

// State class for the Calculator Screen
class _CalculatorScreenState extends State<CalculatorScreen> {
  String number1 = ""; // . 0-9
  String number2 = ""; // . 0-9
  String operand = ""; // + - * /

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          //ouput
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(16),
                child:  Text(
                  "$number1$operand$number2".isEmpty
                    ? "0"
                    : "$number1$operand$number2",
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          ),

          // divider Line
          Container(
            width: double.infinity,
            height: 0.5, // Line thickness
            color: Colors.white54, // Line color (subtle white)
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 10), // Side margins
          ),

          //buttons
          Wrap(
            children: Btn.buttonValues
                .map(
                  (value) => SizedBox(
                      width: (screenSize.width / 4),
                      height: screenSize.width / 5,
                      child: buildButton(value)),
                )
                .toList(),
          )
        ]),
      ),
    );
  }

//build button method
  Widget buildButton(value) {
  final textColor = [
    Btn.clr, 
    Btn.del,
    Btn.per,
    Btn.multiply,
    Btn.add,
    Btn.subtract,
    Btn.divide,
    Btn.calculate,
  ].contains(value)
      ? Colors.black
      : Colors.white;

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Material(
      color: getBtnColor(value),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      elevation: 8, // Adds a slight lift to the button
      shadowColor: Colors.black54, // Shadow effect
      child: InkWell(
        splashColor: getBtnColor(value).withOpacity(0.2), // Subtle highlight effect
        onTap: () => onBtnTap(value),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38, // Shadow color
                blurRadius: 8, // Soft edges
                offset: Offset(2, 4), // Position of shadow
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.roboto( // Using Google Fonts here
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

  // ##########
  void onBtnTap(String value){
    if(value==Btn.del){
      delete();
      return;
    }

    if (value == Btn.clr) {
      clearAll();
      return;
    }

    if (value == Btn.per){
      convertToPercentage();
      return;
    }

    if (value == Btn.plusOrminus) {
    toggleSign();
    return;
    }

    if(value == Btn.calculate) {
      calculate();
      return;
    }

    appendValue(value);
  }

  void calculate(){
    if (number1.isEmpty) return;
    if (operand.isEmpty) return;
    if (number2.isEmpty) return;

    double num1 = double.parse(number1);
    double num2 = double.parse(number2);

    var result = 0.0;
    switch(operand) {
      case Btn.add:
        result = num1 + num2;
        break;
      case Btn.subtract:
        result = num1 - num2;
        break;
      case Btn.multiply:
        result = num1 * num2;
        break;
      case Btn.divide:
        result = num1 / num2;
        break;
      default:
    }

    setState(() {
      number1 = "$result";

      if(number1.endsWith(".0")){
        number1 = number1.substring(0, number1.length - 2);
      }

      operand = "";
      number2 = "";
    });
  }

  void delete(){
    if(number2.isNotEmpty){
      number2=number2.substring(0, number2.length - 1);
    }else if (operand.isNotEmpty){
      operand ="";
    }else if(number1.isNotEmpty){
      number1 = number1.substring(0, number1.length - 1);
    }


    setState(() {});
  }

  void clearAll(){
    setState(() {
      number1 = "";
      operand = "";
      number2 = "";
     
    });
  }

  void convertToPercentage(){

    if(number1.isNotEmpty&&operand.isNotEmpty&&number2.isNotEmpty){

    }

    if(operand.isNotEmpty){
      return;
    }

    final number = double.parse(number1);
    setState(() {
      number1 = "${(number/100)}";
      operand = "";
      number2 = "";
    });
  }

  void toggleSign() {
    // If operand is empty, toggle sign for number1
    if (operand.isEmpty) {
      setState(() {
        if (number1.isEmpty) {
          // Initially add a "-" to an empty number
          number1 = "-";
        } else if (number1 == "-") {
          // If number1 is only "-", remove it
          number1 = "";
        } else if (number1.startsWith("-")) {
          // If number1 starts with "-", remove it
          number1 = number1.substring(1);
        } else {
          // Otherwise, add a "-" at the start
          number1 = "-$number1";
        }
      });
      return;
    }

    // If operand exists, toggle sign for number2
    if (number2.isEmpty) {
      setState(() {
        if (number2.isEmpty) {
          // Initially add a "-" to an empty number
          number2 = "-";
        } else if (number2 == "-") {
          // If number2 is only "-", remove it
          number2 = "";
        } else if (number2.startsWith("-")) {
          // If number2 starts with "-", remove it
          number2 = number2.substring(1);
        } else {
          // Otherwise, add a "-" at the start
          number2 = "-$number2";
        }
      });
    }
  }

  void appendValue(String value){

    if (value != Btn.dot && int.tryParse(value) == null) {
      if (operand.isNotEmpty && number2.isNotEmpty) {
        // calculate equation before assigning new number
      }
      operand = value;
    } else if (number1.isEmpty || operand.isEmpty) {
      if (value == Btn.dot && number1.contains(Btn.dot)) return;
      if (value == Btn.dot && (number1.isEmpty || number1 == Btn.n0)) {
        value = "0.";
      }
      number1 += value;
    } else if (number2.isEmpty || operand.isNotEmpty) {
      if (value == Btn.dot && number2.contains(Btn.dot)) return;
      if (value == Btn.dot && (number2.isEmpty || number2 == Btn.n0)) {
        value = "0.";
      }
      number2 += value;
    }

    setState(() {});
  }

 // ###########
  Color getBtnColor(value) {
    return [Btn.del, Btn.clr].contains(value)
        ? Colors.grey.shade100 // Dark gray for "DEL" and "CLR"
        : [ Btn.per,
            Btn.multiply,
            Btn.add,
            Btn.subtract,
            Btn.divide,
            Btn.calculate,].contains(value)
        ? Colors.orange.shade400
        : [Btn.plusOrminus, Btn.dot].contains(value)
        ? const Color.fromARGB(255, 70, 76, 116)
        : const Color.fromARGB(255, 68, 71, 90); // Button background color
  }
}
