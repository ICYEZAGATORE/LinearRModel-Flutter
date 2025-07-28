import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const PredictionApp());
}

class PredictionApp extends StatelessWidget {
  const PredictionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Malaria Prediction App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF6B9071),
        fontFamily: 'Arial',
      ),
      home: const PredictionPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  PredictionPageState createState() => PredictionPageState();
}

class PredictionPageState extends State<PredictionPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each specific input
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _bedNetsController = TextEditingController();
  final TextEditingController _antimalarialController = TextEditingController();
  final TextEditingController _iptController = TextEditingController();
  final TextEditingController _drinkingWaterController =
      TextEditingController();

  String _result = '';
  bool _isLoading = false;

  // API endpoint for web
  final String apiUrl = 'http://localhost:8000/predict';

  // Input field configurations
  final List<Map<String, dynamic>> inputFields = [
    {
      'label': 'Year',
      'hint': 'Enter year (2000-2025)',
      'key': 'year',
      'min': 2000.0,
      'max': 2025.0,
    },
    {
      'label': 'Bed Nets Usage (%)',
      'hint': 'Insecticide-treated bed nets usage',
      'key': 'bed_nets_usage',
      'min': 0.0,
      'max': 100.0,
    },
    {
      'label': 'Antimalarial Drugs (%)',
      'hint': 'Children receiving antimalarial drugs',
      'key': 'antimalarial_drugs',
      'min': 0.0,
      'max': 100.0,
    },
    {
      'label': 'IPT Pregnancy (%)',
      'hint': 'Intermittent preventive treatment',
      'key': 'ipt_pregnancy',
      'min': 0.0,
      'max': 100.0,
    },
    {
      'label': 'Safe Drinking Water (%)',
      'hint': 'Access to safely managed water',
      'key': 'drinking_water',
      'min': 0.0,
      'max': 100.0,
    },
  ];

  List<TextEditingController> get _controllers => [
    _yearController,
    _bedNetsController,
    _antimalarialController,
    _iptController,
    _drinkingWaterController,
  ];

  Future<void> _predict() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _result = '';
      });

      try {
        print('Making API call to: $apiUrl');

        // Prepare the data with correct field names
        final Map<String, dynamic> requestData = {
          'year': int.parse(_yearController.text),
          'bed_nets_usage': double.parse(_bedNetsController.text),
          'antimalarial_drugs': double.parse(_antimalarialController.text),
          'ipt_pregnancy': double.parse(_iptController.text),
          'drinking_water': double.parse(_drinkingWaterController.text),
        };

        print('Request data: ${json.encode(requestData)}');

        final response = await http
            .post(
              Uri.parse(apiUrl),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(requestData),
            )
            .timeout(const Duration(seconds: 10));

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          setState(() {
            final prediction = responseData['prediction'];
            final unit = responseData['unit'] ?? 'cases per 1,000 population';
            _result = 'Predicted Malaria Incidence:\n$prediction $unit';
          });
        } else {
          setState(() {
            _result = 'Error: ${response.statusCode} - ${response.body}';
          });
        }
      } catch (e) {
        print('Detailed error: $e');
        setState(() {
          _result = 'Error connecting to API: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateInput(String? value, double min, double max) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    final numValue = double.tryParse(value);
    if (numValue == null) {
      return 'Enter a valid number';
    }
    if (numValue < min || numValue > max) {
      return 'Value must be between $min and $max';
    }
    return null;
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
    const Color darkGreen = Color(0xFF0F2A1D);
    const Color lightGreen = Color(0xFFE3EED4);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkGreen,
        title: const Text(
          'Malaria Prediction',
          style: TextStyle(color: lightGreen),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter the following data to predict malaria incidence:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0F2A1D),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                for (int i = 0; i < inputFields.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _controllers[i],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: lightGreen,
                        labelText: inputFields[i]['label'],
                        hintText: inputFields[i]['hint'],
                        labelStyle: const TextStyle(color: darkGreen),
                        hintStyle: TextStyle(
                          color: darkGreen.withOpacity(0.6),
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) => _validateInput(
                        value,
                        inputFields[i]['min'],
                        inputFields[i]['max'],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _predict,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: lightGreen)
                      : const Text(
                          'Predict Malaria Incidence',
                          style: TextStyle(color: lightGreen, fontSize: 18),
                        ),
                ),
                const SizedBox(height: 30),
                if (_result.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _result,
                      style: const TextStyle(
                        fontSize: 18,
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
      ),
    );
  }
}
