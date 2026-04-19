#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uVelocity;
uniform float uIsLight;

out vec4 fragColor;

// ── SDF ──
float sdRoundedRect(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

// ── Hash ──
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// ── Height Mapping (Matching CustomPainter logic) ──
float getHeight(vec2 id, float t) {
    // Slightly higher frequency for more visible wave peaks
    float w1 = sin((id.x * 0.4) + (t * 1.2));
    float w2 = cos((id.y * 0.5) + (t * 0.9));
    float w3 = sin(length(id * 0.4) - (t * 1.5));
    
    // Composite wave normalization
    float h = ((w1 + w2 + w3) / 3.0 + 1.0) / 2.0;
    
    // Smoothstep interpolation for more organic motion
    h = h * h * (3.0 - 2.0 * h);
    
    // Push low values lower so they feel "at one with the ground" more often
    h = pow(h, 1.6); 
    
    // Velocity interaction (subtle ripple acceleration)
    return h * (1.0 + uVelocity * 0.6);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    // Fix aspect ratio distortion for squares
    vec2 aspectUv = (FlutterFragCoord().xy - 0.5 * uSize) / min(uSize.x, uSize.y);
    bool lightMode = uIsLight > 0.5;

    // Slowed down internal clock for "one bit slower" feel
    float t = uTime * 0.75; 

    // ── Grid Scaling (Matching 75.0px box size vibe) ──
    float gridScale = 7.5; 
    vec2 gUv = aspectUv * gridScale;
    vec2 id = floor(gUv);
    vec2 fUv = fract(gUv) - 0.5;

    // ── 3D Surface Elevation ──
    float h = getHeight(id, t);
    
    // Neomorphic parameters tuned for "Deeper" feel
    float boxHalfSize = 0.40; 
    float corner = 0.12;
    float dist = sdRoundedRect(fUv, vec2(boxHalfSize), corner);
    
    // Dynamic offsets increased for more "Prominent" pop
    float baseOffset = 0.0;
    float highOffset = 0.085; // Increased from 0.065 for deeper waves
    vec2 shadowOffset = vec2(mix(baseOffset, highOffset, h));
    
    // Fade out shadow faster when low to ground
    float shadowIntensity = smoothstep(0.05, 0.25, h);

    // ── Color Schemes (Synced with AppColors) ──
    vec3 color;
    vec3 bgColor = lightMode ? vec3(0.933, 0.949, 0.968) : vec3(0.015, 0.019, 0.023); 
    vec3 surfaceColor;
    
    if (lightMode) {
        color = bgColor;
        
        // Dark Shadow (Bottom Right)
        float sDist = sdRoundedRect(fUv - shadowOffset, vec2(boxHalfSize), corner);
        float darkBlur = 0.04 + h * 0.15; 
        float darkShadow = smoothstep(darkBlur, -0.01, sDist);
        color = mix(color, vec3(0.02, 0.05, 0.1), darkShadow * 0.25 * shadowIntensity); 
        
        // Light Shadow (Top Left)
        float lDist = sdRoundedRect(fUv + shadowOffset, vec2(boxHalfSize), corner);
        float lightShadow = smoothstep(darkBlur * 0.7, -0.01, lDist);
        color = mix(color, vec3(1.0), lightShadow * 0.98 * shadowIntensity);
        
        // Body color shift
        surfaceColor = mix(bgColor, vec3(1.0), h * 0.65); 
    } else {
        color = bgColor;
        
        // Deep Black Shadow (Bottom Right)
        float sDist = sdRoundedRect(fUv - shadowOffset, vec2(boxHalfSize), corner);
        float darkBlur = 0.04 + h * 0.15; 
        float darkShadow = smoothstep(darkBlur, -0.01, sDist);
        color = mix(color, vec3(0.0), darkShadow * 0.95 * shadowIntensity); 
        
        // Subtle Rim Light (Top Left)
        float lDist = sdRoundedRect(fUv + shadowOffset, vec2(boxHalfSize), corner);
        float lightShadow = smoothstep(darkBlur * 0.6, -0.01, lDist);
        color = mix(color, vec3(1.0), lightShadow * 0.12 * shadowIntensity); 
        
        // Body color shift
        surfaceColor = mix(bgColor, vec3(0.1, 0.15, 0.25), h * 0.7); 
    }

    // Apply the box surface
    if (dist < 0.0) {
        color = surfaceColor;
        
        // Add subtle 3D lighting gradient on the surface itself
        float grad = dot(normalize(fUv), vec2(-0.707)) * 0.5 + 0.5;
        color += (lightMode ? 1.0 : 0.5) * (grad - 0.5) * 0.05;
    }

    // Final film grain (Premium touch)
    float grain = (hash(uv * (uTime + 1.0)) - 0.5) * 0.012;
    color += grain;

    fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
