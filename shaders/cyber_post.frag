#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uVelocity; // Normalized 0.0 to 1.0

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    
    // ── Atmospheric Horizon Haze ──
    float horizonY = 0.35; 
    float distToHorizon = abs(uv.y - horizonY);
    
    // Haze expands and intensifies with velocity
    float hazeRange = 0.25 + (uVelocity * 0.15);
    float hazeIntens = 0.4 + (uVelocity * 0.3);
    float haze = smoothstep(hazeRange, 0.0, distToHorizon) * hazeIntens;
    
    vec3 color = vec3(0.0);
    
    // ── Horizon Glow ──
    // Pulse speed and intensity increases with velocity
    float pulseSpeed = 3.0 + (uVelocity * 10.0);
    float pulse = 0.8 + 0.2 * sin(uTime * pulseSpeed);
    color += vec3(0.0, 0.5, 1.0) * haze * pulse;
    
    // ── Scanlines ──
    float scanline = sin(uv.y * uSize.y * 1.5) * 0.02;
    color -= scanline;
    
    // ── Noise Grain ──
    // Grain gets "sharper" when moving fast
    float noiseSpeed = uTime * (1.0 + uVelocity * 2.0);
    float noise = (fract(sin(dot(uv, vec2(12.9898, 78.233) * noiseSpeed)) * 43758.5453) - 0.5) * 0.015;
    color += noise;
    
    // ── Vignette ──
    float dist = distance(uv, vec2(0.5, 0.5));
    float vignette = smoothstep(1.0, 0.4, dist);
    
    fragColor = vec4(color, haze * 0.5 + 0.1) * vignette;
}
