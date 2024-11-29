#version 330 core

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;


in ATTRIB_VS_OUT
{
    vec4 color;
    vec2 size;
} attribIn[];

out ATTRIB_GS_OUT
{
    vec4 color;
    vec2 texCoords;
} attribOut;

uniform mat4 projection;

void main()
{
    // TODO
    ivec4 indices = ivec4(0, 1, 2, 3);
    for (int i = 0; i < 4; i++)
    {
        int index = indices[i];
        vec4 pos = gl_in[0].gl_Position;
        pos.x += (i & 1) * attribIn[0].size.x;
        pos.y += (i & 2) * attribIn[0].size.y;
        gl_Position = projection * pos;
        attribOut.color = attribIn[0].color;
        attribOut.texCoords = vec2((i & 1), (i & 2));
        EmitVertex();
    }
    EndPrimitive();
}
