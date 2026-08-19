import 'package:bookread/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:language_picker/language_picker_dropdown.dart';
import 'package:language_picker/language_picker_dropdown_controller.dart';
import 'package:language_picker/languages.dart';
import 'package:bookread/models/book.dart';
import 'package:bookread/providers/language_provider.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/helper.dart';
import 'package:bookread/utilities/task_response.dart';
import 'package:provider/provider.dart';

class CreateBookScreen extends StatefulWidget {
  const CreateBookScreen({super.key});

  @override
  State<CreateBookScreen> createState() => _CreateBookScreenState();
}

class _CreateBookScreenState extends State<CreateBookScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _authorsController = TextEditingController();
  final TextEditingController _categoriesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  final TextEditingController _publishedDateController =
      TextEditingController();
  final TextEditingController _pageController = TextEditingController();
  late LanguagePickerDropdownController _languageController;

  DateTime? publishedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final Locale appLocale =
        Provider.of<AppLanguageProvider>(context, listen: false).appLocale;
    _languageController = LanguagePickerDropdownController(
      Language.fromIsoCode(appLocale.languageCode),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _authorsController.dispose();
    _categoriesController.dispose();
    _descriptionController.dispose();
    _publisherController.dispose();
    _publishedDateController.dispose();
    _pageController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: publishedDate,
      firstDate: DateTime(1100),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != publishedDate) {
      publishedDate = picked;
      _publishedDateController.text = Helper.getLocalDateString(publishedDate);
    }
  }

  Future<void> submit() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final t = AppLocalizations.of(context)!;
    // Validate the form fields
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.translate('fillAllFields'))));
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String title = _titleController.text.trim();
    String subtitle = _subtitleController.text.trim();
    String authors = _authorsController.text.trim();
    String categories = _categoriesController.text.trim();
    String description = _descriptionController.text.trim();
    String publisher = _publisherController.text.trim();
    int pageCount = int.parse(_pageController.text);
    String language = _languageController.value.isoCode;

    final Book newBook = Book(
      title: title,
      subtitle: subtitle,
      authors: authors.split(',').map((a) => a.trim()).toList(),
      categories: categories.split(',').map((c) => c.trim()).toList(),
      description: description.isEmpty ? null : description,
      publisher: publisher.isEmpty ? null : publisher,
      publishedDate: publishedDate,
      pageCount: pageCount,
      language: language,
    );

    final TaskResponse response = await BookApi.createBook(newBook);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (response.isFailure) return;

    Navigator.pop(context, true);
  }

  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      final t = AppLocalizations.of(context)!;
      return t.translate('fillTitle');
    }
    return null;
  }

  String? validateSubtitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      final t = AppLocalizations.of(context)!;
      return t.translate('fillSubtitle');
    }
    return null;
  }

  String? validateAuthors(String? value) {
    if (value == null || value.trim().isEmpty) {
      final t = AppLocalizations.of(context)!;
      return t.translate('fillAuthors');
    }
    return null;
  }

  String? validateCategories(String? value) {
    if (value == null || value.trim().isEmpty) {
      final t = AppLocalizations.of(context)!;
      return t.translate('fillCategories');
    }
    return null;
  }

  String? validatePageCount(String? value) {
    final t = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return t.translate('fillPagesAmount');
    }
    if (int.tryParse(value) == null) {
      return t.translate('fillValidPagesAmount');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Create a personal book')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(kPadding),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(t.translate('createNewBookNote')),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      label: Text(t.translate('title')),
                      hintText: t.translate('title'),
                    ),
                    validator: validateTitle,
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  TextFormField(
                    controller: _subtitleController,
                    decoration: InputDecoration(
                      label: Text(t.translate('subtitle')),
                      hintText: t.translate('subtitle'),
                    ),
                    validator: validateSubtitle,
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  TextFormField(
                    controller: _authorsController,
                    decoration: InputDecoration(
                      label: Text(t.translate('authors')),
                      hintText: t.translate('authors'),
                    ),
                    validator: validateAuthors,
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  TextFormField(
                    controller: _categoriesController,
                    decoration: InputDecoration(
                      label: Text(t.translate('categories')),
                      hintText: t.translate('categories'),
                    ),
                    validator: validateCategories,
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      label: Text(t.translate('description')),
                      hintText: t.translate('description'),
                    ),
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  TextFormField(
                    controller: _publisherController,
                    decoration: InputDecoration(
                      label: Text(t.translate('publisher')),
                      hintText: t.translate('publisher'),
                    ),
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  TextFormField(
                    controller: _publishedDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      label: Text(t.translate('publicationDate')),
                      hintText: t.translate('publicationDate'),
                    ),
                    onTap: _selectDate,
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  TextFormField(
                    controller: _pageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      label: Text(t.translate('numberOfPages')),
                      hintText: t.translate('numberOfPages'),
                    ),
                    validator: validatePageCount,
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  LanguagePickerDropdown(controller: _languageController),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  ElevatedButton(
                    onPressed: _isLoading ? null : submit,
                    child: Text(t.translate('create')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
