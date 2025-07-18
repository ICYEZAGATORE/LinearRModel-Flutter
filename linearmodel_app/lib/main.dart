import 'package:flutter/material.dart';

void main() {
  runApp(PredictionApp());
}

class PredictionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prediction App',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF6B9071),
        fontFamily: 'Arial',
      ),
      home: PredictionPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PredictionPage extends StatefulWidget {
  @override
  _PredictionPageState createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  String _result = '';

  void _predict() {
    if (_formKey.currentState!.validate()) {
      // Mock result
      setState(() {
        _result = 'Predicted Value: 42.3';
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color darkGreen = Color(0xFF0F2A1D);
    final Color mediumGreen = Color(0xFF375534);
    final Color softGreen = Color(0xFFAEC3B0);
    final Color lightGreen = Color(0xFFE3EED4);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkGreen,
        title: Text('Predictor', style: TextStyle(color: lightGreen)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < 4; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _controllers[i],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: lightGreen,
                      labelText: 'Input ${i + 1}',
                      labelStyle: TextStyle(color: darkGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter value';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _predict,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Predict',
                  style: TextStyle(color: lightGreen, fontSize: 18),
                ),
              ),
              SizedBox(height: 30),
              if (_result.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _result,
                    style: TextStyle(
                      fontSize: 20,
                      color: darkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
