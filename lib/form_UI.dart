import 'package:flutter/material.dart';

class FormBuilderScreen extends StatefulWidget {
  const FormBuilderScreen({super.key});

  @override
  State<FormBuilderScreen> createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends State<FormBuilderScreen> {

  final titleController = TextEditingController();
  final descController = TextEditingController();

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
                            });
                          },
                        ),

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
                  print(questions);
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
