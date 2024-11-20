#version 400 core

layout(vertices = 4) out;

uniform mat4 modelView;

const float MIN_TESS = 4;
const float MAX_TESS = 64;

const float MIN_DIST = 30.0f;
const float MAX_DIST = 100.0f;

void main()
{
	// TODO

    vec4 p00 = gl_in[0].gl_Position;
    vec4 p01 = gl_in[1].gl_Position;
    vec4 p10 = gl_in[2].gl_Position;
    vec4 p11 = gl_in[3].gl_Position;

    vec4 uVec = p01 - p00;
    vec4 vVec = p10 - p00;
    vec4 normal = normalize( vec4(cross(vVec.xyz, uVec.xyz), 0) );

    float dist = length(modelView[3] - p00);

    float mixFactor = clamp( (dist - MIN_DIST) / (MAX_DIST - MIN_DIST), 0.0f, 1.0f );
    mixFactor = mix(MIN_TESS, MAX_TESS, mixFactor);

    gl_TessLevelOuter[0] = mixFactor;
    gl_TessLevelOuter[1] = mixFactor;
    gl_TessLevelOuter[2] = mixFactor;
    gl_TessLevelOuter[3] = mixFactor;
    gl_TessLevelInner[0] = mixFactor;
    gl_TessLevelInner[1] = mixFactor;

    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
}
