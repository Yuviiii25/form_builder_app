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
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text("Create Form"),
      ),

      body: Center(
        child: SizedBox(
          width: 700,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [

              // Form Title
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: "Form Title",
                ),
              ),

              const SizedBox(height: 10),

              // Description
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  hintText: "Description",
                ),
              ),

              const SizedBox(height: 20),

              // Questions
              ...questions.asMap().entries.map((entry) {
                int index = entry.key;
                var q = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [

                        // Question text
                        TextField(
                          decoration: const InputDecoration(
                            hintText: "Question",
                          ),
                          onChanged: (val) {
                            q["text"] = val;
                          },
                        ),

                        const SizedBox(height: 10),

                        // Question type
                        DropdownButton<String>(
                          value: q["type"],
                          isExpanded: true,
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
                              if (value == "single" || value == "multiple") {
                                if (q["options"].isEmpty) {
                                  q["options"].add("Option 1");
                                }
                              }
                            });
                          },
                        ),

                        const SizedBox(height: 10),

                        // Option editor
                        if (q["type"] == "single" || q["type"] == "multiple")
                          Column(
                            children: [

                              ...q["options"].asMap().entries.map<Widget>((opt) {
                                int optIndex = opt.key;
                                String optionText = opt.value;

                                return Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: TextEditingController(text: optionText),
                                        onChanged: (val) {
                                          q["options"][optIndex] = val;
                                        },
                                        decoration: const InputDecoration(
                                          hintText: "Option",
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          q["options"].removeAt(optIndex);
                                        });
                                      },
                                    )
                                  ],
                                );
                              }),

                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      q["options"].add("New Option");
                                    });
                                  },
                                  child: const Text("+ Add Option"),
                                ),
                              )
                            ],
                          ),

                        const SizedBox(height: 10),

                        // Preview
                        buildPreview(q),

                        const SizedBox(height: 10),

                        // Delete button
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                questions.removeAt(index);
                              });
                            },
                          ),
                        )

                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 10),

              // Add Question
              ElevatedButton(
                onPressed: addQuestion,
                child: const Text("+ Add Question"),
              ),

              const SizedBox(height: 20),

              // Save
              ElevatedButton(
                onPressed: () {
                  saveForm();
                },
                child: const Text("Save Form"),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
