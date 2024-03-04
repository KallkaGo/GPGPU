#include ../includes/simplexNoise4d.glsl

uniform float uTime;
uniform sampler2D uBase;
uniform float uDeltaTime;
uniform float uFlowFieldInfluence;
uniform float uFlowFieldStrength;
uniform float uFlowFieldFrequency;

void main() {
  float time = uTime * .2;
  vec2 uv = gl_FragCoord.xy / resolution.xy;
  vec4 particle = texture2D(uParticles, uv);
  vec4 base = texture(uBase, uv);

  if(particle.a <= 0.) {
    particle.a = mod(particle.a, 1.);
    particle.xyz = base.xyz;
  } else {
    float strength = simplexNoise4d(vec4(base.xyz * .2, time + 1.0));

    float influence = (uFlowFieldInfluence - 0.5) * (-2.0);

    strength = smoothstep(influence, 1., strength);

    vec3 flowField = vec3(
      simplexNoise4d(vec4(particle.xyz*uFlowFieldFrequency, time)),
      simplexNoise4d(vec4(particle.xyz*uFlowFieldFrequency + 1., time)), 
      simplexNoise4d(vec4(particle.xyz*uFlowFieldFrequency + 2., time)));

    flowField = normalize(flowField);

    particle.xyz += flowField * uDeltaTime * .3 * strength * uFlowFieldStrength;
    particle.a -= uDeltaTime * .5;
  }

  gl_FragColor = vec4(uv, 1.0, 1.0);
  gl_FragColor = particle;
}