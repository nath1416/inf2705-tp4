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
	// TODO
    // float h = (attribIn.height + 16)/64.0f;
	// FragColor = vec4(h,h,h,1.0);
    
    if(attribIn.height < 0.3){
        FragColor = texture(sandSampler, attribIn.texCoords);
    } else if(attribIn.height < 0.35){
        // TODO: interpolation entre les textures
        FragColor = texture(groundSampler, attribIn.texCoords);
    }else if(attribIn.height < 0.6){
        FragColor = texture(groundSampler, attribIn.texCoords);
    }else if(attribIn.height < 0.65){
        // TODO: interpolation entre les textures
        FragColor = texture(snowSampler, attribIn.texCoords);
    } else {
        FragColor = texture(snowSampler, attribIn.texCoords);
    }

}
