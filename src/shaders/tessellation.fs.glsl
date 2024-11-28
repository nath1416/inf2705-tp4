#version 330 core

in ATTRIB_GS_OUT
{
    float height;
    vec2 texCoords;
    vec4 patchDistance;
    vec3 barycentricCoords;
} attribIn;

uniform sampler2D groundSampler;
uniform sampler2D sandSampler;
uniform sampler2D snowSampler;
uniform bool viewWireframe;

out vec4 FragColor;

float edgeFactor(vec3 barycentricCoords, float width)
{
    vec3 d = fwidth(barycentricCoords);
    vec3 f = step(d * width, barycentricCoords);
    return min(min(f.x, f.y), f.z);
}

float edgeFactor(vec4 barycentricCoords, float width)
{
    vec4 d = fwidth(barycentricCoords);
    vec4 f = step(d * width, barycentricCoords);
    return min(min(min(f.x, f.y), f.z), f.w);
}

const vec3 WIREFRAME_COLOR = vec3(0.5f);
const vec3 PATCH_EDGE_COLOR = vec3(1.0f, 0.0f, 0.0f);

const float WIREFRAME_WIDTH = 0.5f;
const float PATCH_EDGE_WIDTH = 0.5f;

void main()
{
    // TODO: interpolation entre les textures
    if(attribIn.height < 0.3) {
        FragColor = texture(sandSampler, attribIn.texCoords);
    } else if(attribIn.height < 0.35) {
        vec4 texture1 = texture(sandSampler, attribIn.texCoords);
        vec4 texture2 = texture(groundSampler, attribIn.texCoords);
        FragColor = mix(texture1, texture2, (attribIn.height - 0.3)/0.05);
    } else if(attribIn.height < 0.6) {
        FragColor = texture(groundSampler, attribIn.texCoords);
    } else if(attribIn.height < 0.65) {
        vec4 texture1 = texture(groundSampler, attribIn.texCoords);
        vec4 texture2 = texture(snowSampler, attribIn.texCoords);
        FragColor = mix(texture1, texture2, (attribIn.height - 0.6)/0.05);
    } else {
        FragColor = texture(snowSampler, attribIn.texCoords);
    }
}
