import 'dart:io';

import 'package:flutter/material.dart';
import 'package:app_notas/src/core/models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  const NoteCard(this.note, {required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final hasImage = note.image != null && note.image!.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.all(6),
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
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                note.description ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
