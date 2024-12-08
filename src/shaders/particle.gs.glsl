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
    for (int i = 0; i < 4; i++)
    {
        vec4 pos = gl_in[0].gl_Position;

        float halfSizeX = attribIn[0].size.x / 2.0;
        float halfSizeY = attribIn[0].size.y / 2.0;

        pos.x += ((i % 2) * 2.0 - 1.0) * halfSizeX; 
        pos.y += ((i / 2) * 2.0 - 1.0) * halfSizeY;

        gl_Position = projection * pos;

        attribOut.color = attribIn[0].color;
        attribOut.texCoords = vec2(i % 2, i / 2);
        
        EmitVertex();
    }
    EndPrimitive(); 
}