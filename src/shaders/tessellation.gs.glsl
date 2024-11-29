#version 330 core

layout(triangles) in;
layout(triangle_strip, max_vertices = 6) out;

in ATTRIB_TES_OUT {
    float height;
    vec2 texCoords;
    vec4 patchDistance;
} attribIn[];

out ATTRIB_GS_OUT {
    float height;
    vec2 texCoords;
    vec4 patchDistance;
    vec3 barycentricCoords;
} attribOut;

void main() {
    for (int i = 0; i < gl_in.length(); ++i) {
        attribOut.height = attribIn[i].height;
        attribOut.texCoords = attribIn[i].texCoords;
        attribOut.patchDistance = attribIn[i].patchDistance;
        attribOut.barycentricCoords = vec3(0.0, 0.0, 0.0); 
        attribOut.barycentricCoords[i] = 1.0;
        gl_Position = gl_in[i].gl_Position;
        EmitVertex();
    }

    EndPrimitive();
}