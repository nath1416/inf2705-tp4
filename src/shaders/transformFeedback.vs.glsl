#version 330 core

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 velocity;
layout (location = 2) in vec4 color;
layout (location = 3) in vec2 size;
layout (location = 4) in float timeToLive;

out vec3 positionMod;
out vec3 velocityMod;
out vec4 colorMod;
out vec2 sizeMod;
out float timeToLiveMod;

uniform float time;
uniform float dt;

uint seed = uint(time * 1000.0) + uint(gl_VertexID);
uint randhash( ) // entre  0 et UINT_MAX
{
    uint i=((seed++)^12345391u)*2654435769u;
    i ^= (i<<6u)^(i>>26u); i *= 2654435769u; i += (i<<5u)^(i>>12u);
    return i;
}
float random() // entre  0 et 1
{
    const float UINT_MAX = 4294967295.0;
    return float(randhash()) / UINT_MAX;
}

const float PI = 3.14159265359f;
vec3 randomInCircle(in float radius, in float height)
{
    float r = radius * sqrt(random());
    float theta = random() * 2 * PI;
    return vec3(r * cos(theta), height, r * sin(theta));
}


const float MAX_TIME_TO_LIVE = 2.0f;
const float INITIAL_RADIUS = 0.2f;
const float INITIAL_HEIGHT = 0.0f;
const float FINAL_RADIUS = 0.5f;
const float FINAL_HEIGHT = 5.0f;

const float INITIAL_SPEED_MIN = 0.5f;
const float INITIAL_SPEED_MAX = 0.6f;

const float INITIAL_TIME_TO_LIVE_RATIO = 0.85f;

const float INITIAL_ALPHA = 0.0f;
const float ALPHA = 0.1f;
const vec3 YELLOW_COLOR = vec3(1.0f, 0.9f, 0.0f);
const vec3 ORANGE_COLOR = vec3(1.0f, 0.4f, 0.2f);
const vec3 DARK_RED_COLOR = vec3(0.1, 0.0, 0.0);

const vec3 ACCELERATION = vec3(0.0f, 0.1f, 0.0f);

// void main()
// {
//     

//     if(timeToLiveNorm < 0.0 || timeToLive > MAX_TIME_TO_LIVE)
//     {
//         // Reset to initial state
//         positionMod = randomInCircle(INITIAL_RADIUS, INITIAL_HEIGHT);
//         velocityMod = randomInCircle(INITIAL_SPEED_MIN, INITIAL_HEIGHT) * (1.0f - INITIAL_TIME_TO_LIVE_RATIO);
//         colorMod = vec4(YELLOW_COLOR, INITIAL_ALPHA) * smoothstep(0.2, 1.0, timeToLiveNorm);
//         sizeMod = vec2(size.x * random() * 1.5, size.y * random());
//         timeToLiveMod = MAX_TIME_TO_LIVE;
//     }
//     else
//     {
//         // Update state
//         positionMod = position + velocity * dt;
//         velocityMod = velocity + ACCELERATION * dt;
//         colorMod = vec4(YELLOW_COLOR, INITIAL_ALPHA) * smoothstep(0.2, 1.0, timeToLiveNorm);
        
//         float sizeFactor = 1.0f + (timeToLiveNorm - 0.3) / 0.7 * 0.5;
//         sizeMod = vec2(size.x * sizeFactor, size.y);

//         timeToLiveMod = timeToLive - dt;
//     }
// }

vec4 changeColor(float timeToLiveNorm)
{
    if(timeToLiveNorm < 0.25){
        return vec4(YELLOW_COLOR, ALPHA);
    }
    if(timeToLiveNorm < 0.3){
        return vec4(ORANGE_COLOR, INITIAL_ALPHA) * smoothstep(0.2, 1.0, timeToLiveNorm);
    }
    if(timeToLiveNorm < 0.5){
        return vec4(DARK_RED_COLOR, ALPHA);
    }
    if(timeToLiveNorm < 0.75){
        return vec4(DARK_RED_COLOR, ALPHA) * smoothstep(0.2, 1.0, timeToLiveNorm);
    }
}

void main()
{

    float timeToLiveNorm = (timeToLive) / MAX_TIME_TO_LIVE;
    if(timeToLive < 0.0) {
        // Init
        positionMod = randomInCircle(INITIAL_RADIUS, INITIAL_HEIGHT);
        // velocityMod = vec3(0.0f, random() * (INITIAL_SPEED_MAX - INITIAL_SPEED_MIN) + INITIAL_SPEED_MIN, 0.0f);
        velocityMod  = normalize(randomInCircle(0.5f, 5.0f)) * (random() * (INITIAL_SPEED_MAX - INITIAL_SPEED_MIN) + INITIAL_SPEED_MIN);
        colorMod = changeColor(1-timeToLiveNorm);
        sizeMod = vec2(size.x /2, size.y * random());
        timeToLiveMod = (random() * (MAX_TIME_TO_LIVE - 1.7f) + 1.7f) * INITIAL_TIME_TO_LIVE_RATIO;
    } else {
        // Update
        positionMod = position + velocity * dt;
        velocityMod = velocity + ACCELERATION * dt;
        // colorMod = vec4(YELLOW_COLOR, INITIAL_ALPHA) * smoothstep(0.2, 1.0, timeToLiveNorm);
        colorMod = changeColor(1-timeToLiveNorm);
        sizeMod = size + vec2(0.1f, 0.1f) * dt;
        timeToLiveMod = timeToLive - dt;
    }
}
