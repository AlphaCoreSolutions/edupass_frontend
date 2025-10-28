// lib/features/parent/views/add_student_screen.dart
import 'dart:io';
import 'package:edupass/core/models/student.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/state/app_state.dart';
import '../../../core/models/domain_ids.dart'; // ✅ for Gender domain id
import '../../../l10n/app_localizations.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final gradeController = TextEditingController();
  final idController = TextEditingController();

  File? imageFile;
  int? genderId; // ✅ lookupDomainDetailId (1=Male, 2=Female from backend)

  @override
  void dispose() {
    nameController.dispose();
    gradeController.dispose();
    idController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final tr = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;
    if (genderId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr.requiredField)));
      return;
    }

    final newStudent = StudentApi(
      id: DateTime.now().millisecondsSinceEpoch, // temp local id
      name: nameController.text.trim(),
      grade: gradeController.text.trim(),
      idNumber: idController.text.trim(),
      genderId: genderId!, // ✅ lookup ID
      imagePath: imageFile?.path ?? '', // optional
    );

    try {
      await context.read<AppState>().addStudent(newStudent);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr.studentAdded)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr.errorTryAgain)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final appState = context.watch<AppState>();

    // Gender details from lookup cache
    final genderDetails = appState.detailsOfDomain(DomainIds.gender);

    final isLoadingLookups = genderDetails.isEmpty; // simple guard
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          ),
          title: Text(tr.addStudent),
          centerTitle: true,
        ),
        body: isLoadingLookups
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Image picker
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picked = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                          );
                          if (picked != null) {
                            setState(() => imageFile = File(picked.path));
                          }
                        },
                        icon: const Icon(Icons.photo),
                        label: Text(tr.selectPhoto),
                      ),
                      if (imageFile != null) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.center,
                          child: ClipOval(
                            child: Image.file(
                              imageFile!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Name
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: tr.studentName,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? tr.requiredField
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // National ID
                      TextFormField(
                        controller: idController,
                        decoration: InputDecoration(
                          labelText: tr.nationalId,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? tr.requiredField
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Grade (free text for now; you can switch to GradeLevel lookup later)
                      TextFormField(
                        controller: gradeController,
                        decoration: InputDecoration(
                          labelText: tr.grade,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? tr.requiredField
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Gender (from LookupDomainDetail)
                      DropdownButtonFormField<int>(
                        value: genderId,
                        decoration: InputDecoration(
                          labelText: tr.gender,
                          border: const OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: genderDetails
                            .map(
                              (d) => DropdownMenuItem<int>(
                                value: d.lookupDomainDetailId,
                                child: Text(
                                  appState.detailName(d.lookupDomainDetailId),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => genderId = val),
                        validator: (v) => v == null ? tr.requiredField : null,
                      ),

                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.check),
                        label: Text(tr.add),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
