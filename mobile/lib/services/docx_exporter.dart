import 'dart:io';
import 'dart:ui';

import 'package:docx_template_fork/docx_template_fork.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:bookread/models/book_note.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/helper.dart';
import 'package:bookread/utilities/task_response.dart';
import 'package:permission_handler/permission_handler.dart';

mixin DocxExporter {
  static Future<TaskResponse> exportBookDocx({
    required String title,
    required String subtitle,
    required List<String> authors,
    required int numPages,
    required List<BookNote> notes,
    String? coverUrl,
    Locale locale = const Locale('en'),
  }) async {
    try {
      // Load DOCX template from assets
      final templateData = await rootBundle.load(
        'assets/templates/template_${locale.languageCode}.docx',
      );
      final templateBytes = templateData.buffer.asUint8List();
      final docx = await DocxTemplate.fromBytes(templateBytes);
      // Sort notes by updatedAt from newest to oldest
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      // Create document content
      final cont =
          Content()
            ..add(TextContent('title', title))
            ..add(TextContent('subtitle', subtitle))
            ..add(TextContent('authors', authors.join(', ')))
            ..add(TextContent('numPages', numPages.toString()))
            ..add(
              ListContent(
                'notes',
                notes.map((note) {
                  return Content()
                    ..add(
                      TextContent(
                        'date',
                        Helper.getLocalDateTimeString(note.updatedAt),
                      ),
                    )
                    ..add(TextContent('page', note.page.toString()))
                    ..add(TextContent('text', note.content));
                }).toList(),
              ),
            );

      // Fetch cover image from URL if provided
      if (coverUrl != null && coverUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(coverUrl));
        if (response.statusCode == 200 &&
            response.contentLength == response.bodyBytes.length) {
          final Uint8List coverBytes = response.bodyBytes;
          cont.add(ImageContent('cover', coverBytes));
        } else {
          return TaskBadResponse(
            errorCode: ErrorCode.unknown,
            message:
                'Failed to load full image from URL: ${response.statusCode}',
          );
        }
      }

      // Generate document
      final generated = await docx.generate(cont);

      if (generated == null) {
        return TaskBadResponse(
          errorCode: ErrorCode.unknown,
          message: 'Failed to export',
        );
      }

      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        return TaskBadResponse(
          errorCode: ErrorCode.permissionDenied,
          message: 'Storage permission denied.',
        );
      }

      // Get device's document directory and save file
      await saveFileWithUniqueName(
        '/storage/emulated/0/Download',
        [title, locale.languageCode, 'exported.docx'].join('_'),
        generated,
      );

      return TaskOkResponse(message: 'Exported successfully to Downloads');
    } catch (e) {
      return TaskBadResponse(
        errorCode: ErrorCode.unknown,
        message: e.toString(),
      );
    }
  }

  static Future<File> saveFileWithUniqueName(
    String directoryPath,
    String baseFileName,
    List<int> bytes,
  ) async {
    final directory = Directory(directoryPath);

    // Ensure directory exists
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    String filePath = '$directoryPath/$baseFileName';
    File file = File(filePath);

    // Check if file exists; if yes, add suffix to filename
    if (await file.exists()) {
      final dotIndex = baseFileName.lastIndexOf('.');
      final namePart =
          (dotIndex == -1) ? baseFileName : baseFileName.substring(0, dotIndex);
      final extensionPart =
          (dotIndex == -1) ? '' : baseFileName.substring(dotIndex);

      int counter = 1;
      while (await file.exists()) {
        filePath = '$directoryPath/${namePart}_$counter$extensionPart';
        file = File(filePath);
        counter++;
      }
    }

    // Write bytes to file
    await file.writeAsBytes(bytes, flush: true);

    return file;
  }
}
