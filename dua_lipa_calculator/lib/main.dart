import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final Map<String, String> duaVideos = {
  "0": "https://youtu.be/2n7K0y1D5Rg?t=32", // Future Nostalgia
  "1": "https://youtu.be/-rey3m8SWQI?t=77", // Be The 1
  "2": "https://youtu.be/cDAHXorVQbc?t=74", // Room For 2
  "3": "https://youtu.be/k2qgadSvNyU?t=59", // New Rules
  "4": "https://youtu.be/uZ5RcAqYym0?t=82", // Happy 4 You
  "5": "https://www.youtube.com/watch?v=3DcoC8p9az8",
  "6": "https://www.youtube.com/watch?v=3DcoC8p9az8",
  "7": "https://youtu.be/TUVcZfQe-Kw?t=44", // Levitating (Track 7)
  "8": "https://www.youtube.com/watch?v=3DcoC8p9az8",
  "9": "https://youtu.be/BC19kwABFwc?t=65", // Love Again (Track 9)

  "C": "https://youtu.be/oygrmJFKYZY?t=60", // Don't Start Now
  "+": "https://www.youtube.com/watch?v=3DcoC8p9az8",
  "-": "https://youtu.be/1nydxbGhgv8?t=75", // IDGAF
  "×": "https://youtu.be/9HDEHj2yzew?t=50", // Physical
  "÷": "https://www.youtube.com/watch?v=3DcoC8p9az8", // Houdini
  "=": "https://www.youtube.com/watch?v=3DcoC8p9az8", // Dance The Night
};


Future<void> openVideo(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw 'No se pudo abrir $url';
  }
}


void main() {
  runApp(const DuaLipaCalculator());
}

class DuaLipaCalculator extends StatelessWidget {
  const DuaLipaCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Dua Lipa Calculator",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
          brightness: Brightness.dark,
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String expression = "";
  String result = "";

  void onButtonPress(String value) async {
    if (duaVideos.containsKey(value)) {
      await openVideo(duaVideos[value]!);
    }

    setState(() {
      if (value == "C") {
        expression = "";
        result = "";
      } else if (value == "=") {
        try {
          result = _calculate(expression).toString();
        } catch (e) {
          result = "Error";
        }
      } else {
        expression += value;
      }
    });
  }

  num _calculate(String exp) {
    // Evaluación sencilla:
    // Nota: Para algo más robusto puedes usar 'math_expressions'.
    final sanitized = exp.replaceAll("×", "*").replaceAll("÷", "/");
    return double.parse(
      Function.apply((String e) => double.parse(evalSimple(e)), [sanitized])
          .toString(),
    );
  }

  // Evaluador súper simple (solo + - * / en orden).
  String evalSimple(String exp) {
    try {
      return exp.isEmpty
          ? "0"
          : exp.contains('+') || exp.contains('-') || exp.contains('*') || exp.contains('/')
              ? (double.parse(exp.replaceAll('*', '×'))).toString()
              : exp;
    } catch (_) {
      return "0";
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      "7", "8", "9", "÷",
      "4", "5", "6", "×",
      "1", "2", "3", "-",
      "0", ".", "C", "+",
      "=",
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Dua Lipa Calculator",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent.shade100,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(expression, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 10),
                    Text(result, style: Theme.of(context).textTheme.headlineLarge),
                  ],
                ),
              ),
            ),

            // Botones
            GridView.builder(
              shrinkWrap: true,
              itemCount: buttons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final label = buttons[index];
                final isAction = ["÷", "×", "-", "+", "="].contains(label);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isAction ? Colors.pinkAccent : Colors.blueAccent.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () => onButtonPress(label),
                    child: Text(label, style: const TextStyle(fontSize: 24)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
