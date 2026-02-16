import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/wifi_scan/domain/entities/wifi_network.dart';
import '../../domain/entities/channel_rating.dart';
import '../bloc/monitoring_bloc.dart';

class ChannelRatingPage extends StatelessWidget {
  final List<WifiNetwork> networks;

  const ChannelRatingPage({super.key, required this.networks});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<MonitoringBloc>()..add(AnalyzeChannels(networks)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CHANNEL RATING ENGINE'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<MonitoringBloc, MonitoringState>(
          builder: (context, state) {
            if (state is MonitoringLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChannelAnalysisReady) {
              return _buildRatingList(state.ratings);
            } else if (state is MonitoringFailure) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('Analyzing...'));
          },
        ),
      ),
    );
  }

  Widget _buildRatingList(List<ChannelRating> ratings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ratings.length,
      itemBuilder: (context, index) {
        final rating = ratings[index];
        return Card(
          color: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: _getColorForRating(rating.rating),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getColorForRating(
                rating.rating,
              ).withOpacity(0.2),
              child: Text(
                '${rating.channel}',
                style: GoogleFonts.rajdhani(
                  color: _getColorForRating(rating.rating),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'Rating: ${rating.rating.toStringAsFixed(1)}/10',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${rating.networkCount} networks overlaying\nStatus: ${rating.recommendation}',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Icon(
              rating.rating >= 7 ? Icons.check_circle : Icons.warning,
              color: _getColorForRating(rating.rating),
            ),
          ),
        );
      },
    );
  }

  Color _getColorForRating(double rating) {
    if (rating >= 8) return AppTheme.primaryColor;
    if (rating >= 5) return Colors.orange;
    return Colors.red;
  }
}
