import 'dart:math';
import 'package:flame/components.dart';

class CameraShaker extends Component {
  final CameraComponent camera;
  final double amplitude;
  final double decay;
  final double frequency;

  double _time = 0.0;
  late Vector2 _originalAnchor;

  CameraShaker(
    this.camera, {
    this.amplitude = 10.0,
    this.decay = 5.0,
    this.frequency = 20.0,
  });

  @override
  Future<void> onLoad() async {
    _originalAnchor = camera.viewfinder.position.clone();
  }

  @override
  void update(double dt) {
    _time += dt;

    final offset = amplitude * exp(-decay * _time) * sin(frequency * _time);

    final offsetX = offset * cos(_time * 10);
    final offsetY = offset * sin(_time * 10);

    camera.viewfinder.position = _originalAnchor + Vector2(offsetX, offsetY);

    if (offset.abs() < 0.1) {
      camera.viewfinder.position = _originalAnchor;
      removeFromParent();
    }
  }
}
