import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'form_fill_screen.dart';


class FormBuilderScreen extends StatefulWidget {
  const FormBuilderScreen({super.key});

  @override
  State<FormBuilderScreen> createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends State<FormBuilderScreen> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final titleController = TextEditingController();
  final descController = TextEditingController();

  Future<void> saveForm() async {

    final docRef = await _firestore.collection("forms").add({
      "title": titleController.text.trim(),
      "description": descController.text.trim(),
      "createdAt": FieldValue.serverTimestamp(),
      "questions": questions,
    });

    final formId = docRef.id;

    final link = "${Uri.base.origin}/#/form/$formId";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Form Created"),
        content: SelectableText(link),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormFillScreen(formId: formId),
                ),
              );
            },
            child: const Text("Open Form"),
          ),
        ],
      ),
    );
  }


  List<Map<String, dynamic>> questions = [];

  void addQuestion() {
    setState(() {
      questions.add({
        "text": "",
        "type": "short",
        "options": [],
      });
    });
  }



  // Preview builder based on type
  Widget buildPreview(Map<String, dynamic> q) {
    switch (q["type"]) {
      case "short":
        return const TextField(
          decoration: InputDecoration(hintText: "Short answer"),
        );

      case "long":
        return const TextField(
          maxLines: 3,
          decoration: InputDecoration(hintText: "Long answer"),
        );

      case "number":
        return const TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: "Numeric answer"),
        );

      case "single":
        return Column(
          children: q["options"].map<Widget>((o) {
            return RadioListTile(
              value: o,
              groupValue: null,
              onChanged: null,
              title: Text(o),
            );
          }).toList(),
        );

      case "multiple":
        return Column(
          children: q["options"].map<Widget>((o) {
            return CheckboxListTile(
              value: false,
              onChanged: null,
              title: Text(o),
            );
          }).toList(),
        );

      default:
        return const SizedBox();
    }
  }



 @override
Widget build(BuildContext context) {
  // Logic to determine width based on device
  double screenWidth = MediaQuery.of(context).size.width;
  double containerWidth = screenWidth > 750 ? 700 : screenWidth * 0.92;

  return Scaffold(
    backgroundColor: Colors.grey[200],
    appBar: AppBar(
      title: const Text("Create Form"),
      centerTitle: true, // Looks better across all devices
    ),
    body: Align( // Using Align + SizedBox for better centering than Center widget in ListViews
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: containerWidth,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            // Form Header Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      style: Theme.of(context).textTheme.headlineSmall,
                      decoration: const InputDecoration(
                        hintText: "Form Title",
                        border: InputBorder.none,
                      ),
                    ),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        hintText: "Description",
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Questions List
            ...questions.asMap().entries.map((entry) {
              int index = entry.key;
              var q = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question text
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Question",
                          filled: true,
                        ),
                        onChanged: (val) => q["text"] = val,
                      ),
                      
                      const SizedBox(height: 15),

                      // Responsive row for Type Selector
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "Response Type"),
                        value: q["type"],
                        items: const [
                          DropdownMenuItem(value: "short", child: Text("Short Answer")),
                          DropdownMenuItem(value: "long", child: Text("Long Answer")),
                          DropdownMenuItem(value: "number", child: Text("Numeric")),
                          DropdownMenuItem(value: "single", child: Text("Single Choice")),
                          DropdownMenuItem(value: "multiple", child: Text("Multiple Choice")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            q["type"] = value;
                            if ((value == "single" || value == "multiple") && q["options"].isEmpty) {
                              q["options"].add("Option 1");
                            }
                          });
                        },
                      ),

                      // Option editor
                      if (q["type"] == "single" || q["type"] == "multiple") ...[
                        const Divider(height: 30),
                        ...q["options"].asMap().entries.map<Widget>((opt) {
                          int optIndex = opt.key;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Icon(q["type"] == "single" ? Icons.circle_outlined : Icons.check_box_outline_blank, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    // Using initialValue to prevent cursor jumping
                                    initialValue: q["options"][optIndex], 
                                    onChanged: (val) => q["options"][optIndex] = val,
                                    decoration: const InputDecoration(hintText: "Option"),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.redAccent),
                                  onPressed: () => setState(() => q["options"].removeAt(optIndex)),
                                )
                              ],
                            ),
                          );
                        }),
                        TextButton.icon(
                          onPressed: () => setState(() => q["options"].add("New Option")),
                          icon: const Icon(Icons.add),
                          label: const Text("Add Option"),
                        ),
                      ],

                      const Divider(height: 30),
                      
                      // Preview area
                      const Text("Preview:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 10),
                      buildPreview(q),

                      const Align(
                        alignment: Alignment.centerRight,
                        child: Divider(),
                      ),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => setState(() => questions.removeAt(index)),
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            label: const Text("Delete", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 10),

            // Action Buttons
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              onPressed: addQuestion,
              icon: const Icon(Icons.add),
              label: const Text("Add Question"),
            ),

            const SizedBox(height: 12),

            FilledButton(
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              onPressed: saveForm,
              child: const Text("Save and Publish Form"),
            ),
            
            const SizedBox(height: 50), // Bottom padding for scrolling
          ],
        ),
      ),
    ),
  );
}
}