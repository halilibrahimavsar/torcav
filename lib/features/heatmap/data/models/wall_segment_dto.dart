import 'package:torcav/features/heatmap/domain/entities/wall_segment.dart';

class WallSegmentDto {
  const WallSegmentDto({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  final double x1;
  final double y1;
  final double x2;
  final double y2;

  factory WallSegmentDto.fromJson(Map<String, dynamic> json) => WallSegmentDto(
        x1: (json['x1'] as num).toDouble(),
        y1: (json['y1'] as num).toDouble(),
        x2: (json['x2'] as num).toDouble(),
        y2: (json['y2'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'x1': x1,
        'y1': y1,
        'x2': x2,
        'y2': y2,
      };

  WallSegment toEntity() => WallSegment(
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
      );

  factory WallSegmentDto.fromEntity(WallSegment entity) => WallSegmentDto(
        x1: entity.x1,
        y1: entity.y1,
        x2: entity.x2,
        y2: entity.y2,
      );
}
