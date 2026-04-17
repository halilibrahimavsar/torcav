import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap/heatmap_page_models.dart';

class NewSessionDialog extends StatefulWidget {
  const NewSessionDialog({
    super.key,
    required this.bloc,
    required this.copy,
  });

  final HeatmapBloc bloc;
  final HeatmapCopy copy;

  @override
  State<NewSessionDialog> createState() => _NewSessionDialogState();
}

class _NewSessionDialogState extends State<NewSessionDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.copy.defaultSessionName(DateTime.now()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.copy.newSurveyDialogTitle,
        style: GoogleFonts.orbitron(fontSize: 14, letterSpacing: 1.6),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: false,
            decoration: InputDecoration(
              labelText: widget.copy.sessionNameField,
              prefixIcon: const Icon(Icons.label_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.copy.newSurveyHint,
            style: GoogleFonts.outfit(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).brightness == Brightness.light 
                ? AppColors.inkRed 
                : AppColors.neonRed,
          ),
          child: Text(widget.copy.cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = _controller.text.trim();
            if (name.isNotEmpty) {
              await [
                Permission.sensors,
                Permission.activityRecognition,
                Permission.location,
                Permission.camera,
              ].request();

              if (mounted) {
                widget.bloc.startSession(name);
              }
            }
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).brightness == Brightness.light 
                ? AppColors.inkBlue.withValues(alpha: 0.1) 
                : AppColors.neonBlue.withValues(alpha: 0.1),
            foregroundColor: Theme.of(context).brightness == Brightness.light 
                ? AppColors.inkBlue 
                : AppColors.neonBlue,
            side: BorderSide(
              color: Theme.of(context).brightness == Brightness.light 
                  ? AppColors.inkBlue.withValues(alpha: 0.4) 
                  : AppColors.neonBlue.withValues(alpha: 0.4),
            ),
          ),
          child: Text(widget.copy.startNow),
        ),
      ],
    );
  }
}
