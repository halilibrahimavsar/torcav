import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/ping_stabilizer_cubit.dart';
import '../bloc/ping_stabilizer_state.dart';

class ProfilePickerSection extends StatelessWidget {
  const ProfilePickerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PingStabilizerCubit, PingStabilizerState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Game profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.profiles.map((p) {
                final isSelected = state.profile?.id == p.id;
                return ChoiceChip(
                  label: Text(p.displayName),
                  selected: isSelected,
                  onSelected: (_) =>
                      context.read<PingStabilizerCubit>().selectProfile(p),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
