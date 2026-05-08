import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/ping_stabilizer_cubit.dart';
import '../bloc/ping_stabilizer_state.dart';

class DnsPickerSection extends StatelessWidget {
  const DnsPickerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PingStabilizerCubit, PingStabilizerState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'DNS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Switch(
                  value: state.autoSwitchDns,
                  onChanged: (v) =>
                      context.read<PingStabilizerCubit>().setAutoSwitchDns(v),
                ),
                const Text('Auto'),
              ],
            ),
            const SizedBox(height: 8),
            ...state.dnsCandidates.map((c) {
              final isActive = state.activeDns?.ip == c.ip;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isActive ? Icons.check_circle : Icons.circle_outlined,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                title: Text('${c.label} · ${c.ip}'),
                subtitle: c.lastRttMs != null
                    ? Text('${c.lastRttMs!.toStringAsFixed(1)} ms')
                    : const Text('—'),
                onTap: () =>
                    context.read<PingStabilizerCubit>().selectDns(c),
              );
            }),
          ],
        );
      },
    );
  }
}
