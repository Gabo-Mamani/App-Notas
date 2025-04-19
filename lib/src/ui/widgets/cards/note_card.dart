import 'dart:io';

import 'package:flutter/material.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  const NoteCard(this.note, {required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeController.instance;
    final hasImage = note.image != null && note.image!.isNotEmpty;
    final textColor = theme.brightnessValue ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: theme.brightnessValue ? Colors.white : Colors.grey[850],
        elevation: 2,
        margin: EdgeInsets.all(6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.file(
                  File(note.image!),
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                note.title ?? "Sin título",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: theme.primary(),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                note.description ?? "",
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: textColor.withOpacity(0.85)),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
