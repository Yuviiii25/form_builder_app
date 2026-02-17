import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormFillScreen extends StatefulWidget {

  final String formId;

  const FormFillScreen({super.key, required this.formId});

  @override
  State<FormFillScreen> createState() => _FormFillScreenState();
}

class _FormFillScreenState extends State<FormFillScreen> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? formData;
  Map<String, dynamic> answers = {};
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    loadForm();
  }

  Future<void> loadForm() async {
    try {
      final doc = await _firestore.collection("forms").doc(widget.formId).get();

      if (doc.exists) {
        setState(() {
          formData = doc.data();
        });
      } else {
        setState(() {
          formData = {};
        });
      }
    } catch (e) {
      setState(() {
        formData = {};
      });
    }
  }



  // Build answer field depending on question type
  Widget buildAnswerField(Map<String, dynamic> q, int index) {

    final key = index.toString();

    switch (q["type"]) {

      case "short":
        return TextField(
          onChanged: (val) => answers[key] = val,
        );

      case "long":
        return TextField(
          maxLines: 3,
          onChanged: (val) => answers[key] = val,
        );

      case "number":
        return TextField(
          keyboardType: TextInputType.number,
          onChanged: (val) =>
              answers[key] = int.tryParse(val) ?? val,
        );

      case "single":
        return Column(
          children: (q["options"] as List).map<Widget>((o) {
            return RadioListTile(
              value: o,
              groupValue: answers[key],
              onChanged: (val) {
                setState(() {
                  answers[key] = val;
                });
              },
              title: Text(o),
            );
          }).toList(),
        );

      case "multiple":
        answers.putIfAbsent(key, () => []);
        return Column(
          children: (q["options"] as List).map<Widget>((o) {
            return CheckboxListTile(
              value: (answers[key] as List).contains(o),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    (answers[key] as List).add(o);
                  } else {
                    (answers[key] as List).remove(o);
                  }
                });
              },
              title: Text(o),
            );
          }).toList(),
        );

      default:
        return const SizedBox();
    }
  }



  // Submit form
  Future<void> submitForm() async {

    if (isSubmitting) return;

    try {

      setState(() {
        isSubmitting = true;
      });

      await _firestore
          .collection("forms")
          .doc(widget.formId)
          .collection("responses")
          .add({
        "answers": answers,
        "submittedAt": FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Thank You"),
          content: Text("Your response has been submitted successfully."),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );

    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {

    if (formData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (formData!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Form not found")),
      );
    }

    final List questions = formData!["questions"] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(formData!["title"] ?? ""),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          if (formData!["description"] != null)
            Text(formData!["description"]),

          const SizedBox(height: 20),

          ...questions.asMap().entries.map((entry) {

            int index = entry.key;
            var q = entry.value;

            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(q["text"] ?? ""),

                    const SizedBox(height: 10),

                    buildAnswerField(q, index),

                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: isSubmitting ? null : submitForm,
            child: isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Submit"),
          )

        ],
      ),
    );
  }
}
