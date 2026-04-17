#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uVelocity; // Normalized 0.0 to 1.0
uniform float uIsLight; // 0.0 for Dark, 1.0 for Light

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
    bool lightMode = uIsLight > 0.5;
    
    // ── Horizon Glow ──
    // Pulse speed and intensity increases with velocity
    float pulseSpeed = 3.0 + (uVelocity * 10.0);
    float pulse = 0.8 + 0.2 * sin(uTime * pulseSpeed);
    
    if (lightMode) {
        // "Ink Bleed" effect: subtle cyan/ink glow on light background
        color = vec3(0.95, 0.97, 1.0); // Light paper base
        vec3 inkColor = vec3(0.0, 0.38, 0.4); // Ink Cyan
        color = mix(color, inkColor, haze * 0.1 * pulse);
    } else {
        color += vec3(0.0, 0.5, 1.0) * haze * pulse;
    }
    
    // ── Scanlines ──
    float scanlineVal = lightMode ? 0.01 : 0.02;
    float scanline = sin(uv.y * uSize.y * 1.5) * scanlineVal;
    
    if (lightMode) {
        color *= (1.0 - scanline * 0.5); // Subtler scanlines in light mode
    } else {
        color -= scanline;
    }
    
    // ── Noise Grain ──
    float noiseSpeed = uTime * (1.0 + uVelocity * 2.0);
    float noise = (fract(sin(dot(uv, vec2(12.9898, 78.233) * noiseSpeed)) * 43758.5453) - 0.5) * 0.015;
    color += noise;
    
    // ── Vignette ──
    float dist = distance(uv, vec2(0.5, 0.5));
    float vignette = smoothstep(1.0, 0.4, dist);
    
    if (lightMode) {
        // High-end subtle vignette for light mode
        vignette = mix(1.0, vignette, 0.3); 
        fragColor = vec4(color, 1.0) * vignette;
    } else {
        fragColor = vec4(color, haze * 0.5 + 0.1) * vignette;
    }
}

