import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import '../config.dart';

class ParticleHelper {
  static ParticleSystemComponent createEatEffect(Vector2 position) {
    final random = Random();
    // Implosion/Spark effect
    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: 30,
        lifespan: 0.8,
        generator: (i) {
          final angle = random.nextDouble() * 2 * pi;
          final speed = random.nextDouble() * 100 + 50;
          return AcceleratedParticle(
            speed: Vector2(cos(angle), sin(angle)) * speed,
            acceleration:
                Vector2(cos(angle), sin(angle)) * -100, // Drag/Decelerate
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final paint = Paint()
                  ..color = const Color(GameConfig.colorFood).withValues(
                    alpha: particle.progress > 1 ? 0 : 1 - particle.progress,
                  )
                  ..style = PaintingStyle.fill;
                canvas.drawCircle(
                  Offset.zero,
                  2 * (1 - particle.progress),
                  paint,
                );
              },
            ),
          );
        },
      ),
    );
  }

  static ParticleSystemComponent createEnemyTrail(Vector2 position) {
    final random = Random();
    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: 1, // Low count, frequent spawn
        lifespan: 0.4,
        generator: (i) => AcceleratedParticle(
          speed:
              Vector2(random.nextDouble() - 0.5, random.nextDouble() - 0.5) *
              20,
          child: ComputedParticle(
            renderer: (canvas, particle) {
              final paint = Paint()
                ..color = Colors.red.withValues(alpha: 1 - particle.progress)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1;
              // Draw a tiny "glitch" line
              canvas.drawLine(
                Offset.zero,
                Offset(
                  random.nextDouble() * 4 - 2,
                  random.nextDouble() * 4 - 2,
                ),
                paint,
              );
            },
          ),
        ),
      ),
    );
  }
}
