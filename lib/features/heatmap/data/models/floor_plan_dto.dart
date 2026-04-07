import '../../domain/entities/floor_plan.dart';
import 'wall_segment_dto.dart';

class FloorPlanDto {
  const FloorPlanDto({
    required this.walls,
    required this.widthMeters,
    required this.heightMeters,
    required this.pixelsPerMeter,
  });

  final List<WallSegmentDto> walls;
  final double widthMeters;
  final double heightMeters;
  final double pixelsPerMeter;

  factory FloorPlanDto.fromJson(Map<String, dynamic> json) => FloorPlanDto(
        walls: (json['walls'] as List<dynamic>)
            .map((e) => WallSegmentDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        widthMeters: (json['widthMeters'] as num).toDouble(),
        heightMeters: (json['heightMeters'] as num).toDouble(),
        pixelsPerMeter: (json['pixelsPerMeter'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'walls': walls.map((e) => e.toJson()).toList(),
        'widthMeters': widthMeters,
        'heightMeters': heightMeters,
        'pixelsPerMeter': pixelsPerMeter,
      };

  FloorPlan toEntity() => FloorPlan(
        walls: walls.map((e) => e.toEntity()).toList(),
        widthMeters: widthMeters,
        heightMeters: heightMeters,
        pixelsPerMeter: pixelsPerMeter,
      );

  factory FloorPlanDto.fromEntity(FloorPlan entity) => FloorPlanDto(
        walls: entity.walls.map((e) => WallSegmentDto.fromEntity(e)).toList(),
        widthMeters: entity.widthMeters,
        heightMeters: entity.heightMeters,
        pixelsPerMeter: entity.pixelsPerMeter,
      );
}
