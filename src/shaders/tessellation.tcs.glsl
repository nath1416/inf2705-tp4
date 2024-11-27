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

    float dist1 = length(modelView[3] - p00);
    float dist2 = length(modelView[3] - p01);
    float dist3 = length(modelView[3] - p10);
    float dist4 = length(modelView[3] - p11);

    float mixFactor1 = clamp( (dist1 - MIN_DIST) / (MAX_DIST - MIN_DIST), 0.0f, 1.0f );
    float mixFactor2 = clamp( (dist2 - MIN_DIST) / (MAX_DIST - MIN_DIST), 0.0f, 1.0f );
    float mixFactor3 = clamp( (dist3 - MIN_DIST) / (MAX_DIST - MIN_DIST), 0.0f, 1.0f );
    float mixFactor4 = clamp( (dist4 - MIN_DIST) / (MAX_DIST - MIN_DIST), 0.0f, 1.0f );

    float resultFactor1 = mix(MIN_TESS, MAX_TESS, mixFactor1);
    float resultFactor2 = mix(MIN_TESS, MAX_TESS, mixFactor2);
    float resultFactor3 = mix(MIN_TESS, MAX_TESS, mixFactor3);
    float resultFactor4 = mix(MIN_TESS, MAX_TESS, mixFactor4);

    gl_TessLevelOuter[0] = resultFactor1;
    gl_TessLevelOuter[1] = resultFactor2;
    gl_TessLevelOuter[2] = resultFactor3;
    gl_TessLevelOuter[3] = resultFactor4;
    gl_TessLevelInner[0] = max(resultFactor1, resultFactor3);
    gl_TessLevelInner[1] = max(resultFactor2, resultFactor4);

    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
}
