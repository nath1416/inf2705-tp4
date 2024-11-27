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
    vec3 v0 = gl_in[0].gl_Position.xyz;
    vec3 v1 = gl_in[1].gl_Position.xyz;
    vec3 v2 = gl_in[2].gl_Position.xyz;

    vec3 bc0 = vec3(1.0, 0.0, 0.0);
    vec3 bc1 = vec3(0.0, 1.0, 0.0);
    vec3 bc2 = vec3(0.0, 0.0, 1.0);

    for (int i = 0; i < gl_in.length(); ++i) {
        attribOut.height = attribIn[i].height;
        attribOut.texCoords = attribIn[i].texCoords;
        attribOut.patchDistance = attribIn[i].patchDistance;
        attribOut.barycentricCoords = vec3(0.0, 0.0, 0.0); 

        if (i == 0) {
            attribOut.barycentricCoords = bc0;
        } else if (i == 1) {
            attribOut.barycentricCoords = bc1;
        } else if (i == 2) {
            attribOut.barycentricCoords = bc2;
        }

        gl_Position = gl_in[i].gl_Position;
        EmitVertex();
    }

    // End the primitive
    EndPrimitive();
}