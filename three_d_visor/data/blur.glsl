// Adapted from:
// http://callumhay.blogspot.com/2010/09/gaussian-blur-shader-glsl.html


#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

varying vec4 vertTexCoord;
uniform sampler2D texture;
uniform float pixelX;
uniform float xLength;
uniform float pixelY;
uniform float yLength;
uniform int blurSize;
uniform int horizontalPass;
uniform float sigma;

uniform vec2 texOffset;
const float PI = 3.14159265;


bool isInBounds(float pixelComp, float compValue, float length){
	bool result = (pixelComp >= (compValue - length)) && (pixelComp <= (compValue + length));
	
	return result;
}


void main() {
	vec2 p = vertTexCoord.st;
		
	bool isXInBounds = isInBounds(gl_FragCoord.x, pixelX, xLength);
	bool isYInBounds = isInBounds(gl_FragCoord.y, pixelY, yLength);
	
	if (!(isXInBounds && isYInBounds)){
		float numBlurPixelsPerSide = float(blurSize / 2); 

		// Incremental Gaussian Coefficent Calculation (See GPU Gems 3 pp. 877 - 889)
		vec3 incrementalGaussian;
		incrementalGaussian.x = 1.0 / (sqrt(2.0 * PI) * sigma);
		incrementalGaussian.y = exp(-0.5 / (sigma * sigma));
		incrementalGaussian.z = incrementalGaussian.y * incrementalGaussian.x;

		vec4 avgValue = vec4(0.0, 0.0, 0.0, 0.0);
		float coefficientSum = 0.0;
		
		// Take the central sample first...
		avgValue += texture2D(texture, p) * incrementalGaussian.x;
		coefficientSum += incrementalGaussian.x;
		incrementalGaussian.xy *= incrementalGaussian.yz;
		
		// Go through the remaining 8 vertical samples (4 on each side of the center)
		for (float i = 1.0; i <= numBlurPixelsPerSide; i++) {
			avgValue += texture2D(texture, p - i * texOffset) * incrementalGaussian.x;
			avgValue += texture2D(texture, p + i * texOffset) * incrementalGaussian.x;
			coefficientSum += 2.0 * incrementalGaussian.x;
			incrementalGaussian.xy *= incrementalGaussian.yz;
		}
		
		gl_FragColor = avgValue / coefficientSum;
	}
	
	else
		gl_FragColor = texture2D(texture, p);
}
