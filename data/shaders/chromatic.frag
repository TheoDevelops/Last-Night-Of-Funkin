#pragma header

uniform sampler2D colorTexture;

uniform vec2 enabled;
uniform vec2 mouseFocusPoint;

out vec4 fragColor;

void main() {
  float redOffset   =  0.009;
  float greenOffset =  0.006;
  float blueOffset  = -0.006;

  vec2 texSize  = textureSize(colorTexture, 0).xy;
  vec2 texCoord = gl_FragCoord.xy / texSize;

  vec2 direction = texCoord - mouseFocusPoint;

  fragColor = texture2d(colorTexture, texCoord);

  if (enabled.x != 1) { return; }

  fragColor.r = texture2d(colorTexture, texCoord + (direction * vec2(redOffset  ))).r;
  fragColor.g = texture2d(colorTexture, texCoord + (direction * vec2(greenOffset))).g;
  fragColor.b = texture2d(colorTexture, texCoord + (direction * vec2(blueOffset ))).b;
}