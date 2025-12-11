import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';

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

final Map<String, int> keySoundDelay = {
  "sounds/0.m4a": 1600,
  "sounds/1.m4a": 600,
  "sounds/2.m4a": 900,
  "sounds/3.m4a": 900,
  "sounds/4.m4a": 700,
  "sounds/5.m4a": 800,
  "sounds/6.m4a": 1100,
  "sounds/7.m4a": 1100,
  "sounds/8.m4a": 700,
  "sounds/9.m4a": 900,
  "sounds/done.m4a": 800,
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
      title: "Calcu-Lipa",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(fontSize: 24, color: Colors.white),
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
  String _firstNumber = '';
  String _operator = '';
  String _secondNumber = '';
  String _result = '';
  bool _isResultShown = false;
  // Audio config variables.
  final _player = AudioPlayer();
  final List<String> _playbackQueue = [];
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    // Set up the listener for when an audio file finishes playing.
    _player.onPlayerComplete.listen((event) {
      // When one sound finishes, try to play the next one.
      _playNextInQueue();
    });
  }

  Future<void> _playNextInQueue() async {
    // Check if the queue is empty
    if (_playbackQueue.isEmpty) {
      _isPlaying = false;
      debugPrint('Queue finished.');
      return;
    }

    // 1. Mark as playing and get the next file
    _isPlaying = true;
    final nextFileName = _playbackQueue.removeAt(0);

    debugPrint('Playing: $nextFileName');

    // 2. Determine the Source
    final source = AssetSource(nextFileName);

    // 3. Start the playback
    // Note: We don't use 'await' here because we don't want to block
    // the UI thread while the audio is playing.
    await _player.setSource(source);
    await _player.seek(Duration(milliseconds: keySoundDelay[nextFileName]!));
    await _player.resume();
  }

  void playSoundInQueue(String digit) async {
    if (digit == '+' || digit == '-') return;
    _playbackQueue.add('sounds/$digit.m4a');
    debugPrint("Added $digit.m4a to the queue");
    if (!_isPlaying) {
      _playNextInQueue();
    }
    // await _player.play(AssetSource('sounds/$digit.m4a')); // Basic play
  }

  void interruptAndPlay(String digit) async {
    // 1. Clear the queue (so nothing plays after the new sound)
    _playbackQueue.clear();

    _isPlaying = false;

    // 2. Stop any current sound (this resets the player state)
    await _player.stop();

    // Note: We don't update the queue or _isPlaying here because this is an interrupt,
    // and the onPlayerComplete listener will handle the transition back to idle
    // after the interrupt sound is done.
    debugPrint('Interrupted sequence to play: $digit.m4a');

    playSoundInQueue(digit);
  }

  void _onButtonPressed(String value) {
    setState(() {
      if (_operator.isEmpty) {
        if (!(value == '+' || value == '-')) interruptAndPlay(value);
      } else {
        playSoundInQueue(value);
      }

      if (_isResultShown) {
        _firstNumber = '';
        _operator = '';
        _secondNumber = '';
        _result = '';
        _isResultShown = false;
      }

      if (int.tryParse(value) != null) {
        if (_operator.isEmpty) {
          _firstNumber = value;
        } else {
          _secondNumber = value;
          _calculate();
        }
      } else if (value == '+' || value == '-') {
        if (_firstNumber.isNotEmpty) {
          _operator = value;
        }
      }
    });
  }

  void _calculate() {
    if (_firstNumber.isNotEmpty &&
        _operator.isNotEmpty &&
        _secondNumber.isNotEmpty) {
      final num1 = int.parse(_firstNumber);
      final num2 = int.parse(_secondNumber);
      int res;
      if (_operator == '+') {
        res = num1 + num2;
      } else {
        res = num1 - num2;
      }
      interruptAndPlay("done"); // Interrupt all sounds and play final sound.
      setState(() {
        _result = res.toString();
        _isResultShown = true;
      });
    }
  }

  String _getDisplayText() {
    if (_isResultShown) {
      return '$_firstNumber $_operator $_secondNumber = $_result';
    }
    return '$_firstNumber $_operator $_secondNumber';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Calcu-Lipa",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _getDisplayText(),
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),
            _buildCalculatorGrid(),
            _buildDuaLipaButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorGrid() {
    final buttons = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['-', '0', '+'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: buttons
          .map(
            (row) => Row(
              children: row
                  .map(
                    (label) => Expanded(child: _buildCalculatorButton(label)),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalculatorButton(String label) {
    return SizedBox(
      height: 90,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.grey.shade800,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
        onPressed: () => _onButtonPressed(label),
        child: Text(
          label,
          style: TextStyle(fontSize: 28, color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildDuaLipaButtons() {
    final duaButtons = {
      "One": "https://youtu.be/-rey3m8SWQI?t=76", // Be The 1
      "Two": "https://youtu.be/cDAHXorVQbc?t=74", // Room For 2
      "Three": "https://youtu.be/k2qgadSvNyU?t=59", // New Rules
      "Four": "https://youtu.be/uZ5RcAqYym0?t=81", // Happy 4 You
    };

    return Row(
      children: duaButtons.entries.map((entry) {
        return Expanded(
          child: SizedBox(
            height: 60,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
              ),
              onPressed: () => openVideo(entry.value),
              child: Text(
                entry.key,
                style: const TextStyle(fontSize: 14, color: Color(0xFF093244)),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
