#include "scene_particles.h"

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#include "imgui/imgui.h"

#include "utils.h"
#include "shader_object.h"

#include <iostream>



static const unsigned int MAX_N_PARTICULES = 10000;
static Particle particles[MAX_N_PARTICULES] = { {{0,0,0},{0,0,0},{0,0,0,0}, {0,0},0} };

SceneParticles::SceneParticles(bool& isMouseMotionEnabled)
: Scene()
, m_isMouseMotionEnabled(isMouseMotionEnabled)
, m_cameraOrientation(0)
, m_oldTime(0)
, m_cumulativeTime(0.0f)
, m_tfo(0)
, m_vao(0)
, m_vbo{0, 0}
, m_nParticles(1)
, m_nMaxParticles(1000)
, m_timeLocationTransformFeedback(-1)
, m_dtLocationTransformFeedback(-1)
, m_modelViewLocationParticle(-1)
, m_projectionLocationParticle(-1)
, m_flameTexture("../textures/flame.png")
, m_menuVisible(true)
{
    initializeShader();
    initializeTexture();

    glEnable(GL_PROGRAM_POINT_SIZE);
    
    // TODO
    glGenVertexArrays(1, &m_vao);
    glBindVertexArray(m_vao);
    for (int i = 0; i < 5; i++) {
        glEnableVertexAttribArray(i);
    }

    glGenBuffers(2, m_vbo);

    glBindBuffer(GL_ARRAY_BUFFER, m_vbo[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(particles), particles, GL_DYNAMIC_COPY);

    glBindBuffer(GL_ARRAY_BUFFER, m_vbo[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(particles), nullptr, GL_DYNAMIC_COPY);

    glGenTransformFeedbacks(1, &m_tfo);
    glBindTransformFeedback(GL_TRANSFORM_FEEDBACK, m_tfo);
}

SceneParticles::~SceneParticles()
{
    // TODO
    glDeleteBuffers(2, m_vbo);
    glDeleteVertexArrays(1, &m_vao);
    glDeleteTransformFeedbacks(1, &m_tfo);
}

void SceneParticles::run(Window& w)
{
    updateInput(w);
    
    drawMenu();
    
    glm::mat4 view = getCameraThirdPerson(2.5);
    glm::mat4 projPersp = getProjectionMatrix(w);
    glm::mat4 modelView = view;

    float time = w.getTick() / 1000.0;
    float dt = time - m_oldTime;
    m_oldTime = time;
    m_cumulativeTime += dt;
    if (dt > 1.0f)
        m_nParticles = 1;

    m_transformFeedbackShaderProgram.use();
    glUniform1f(m_timeLocationTransformFeedback, time);
    glUniform1f(m_dtLocationTransformFeedback, dt);
    
    // TODO: buffer binding
    // TODO: update particles
    // TODO: swap buffers

    m_particuleShaderProgram.use();
    m_flameTexture.use(0);
    
    glUniformMatrix4fv(m_modelViewLocationParticle, 1, GL_FALSE, &modelView[0][0]);
    glUniformMatrix4fv(m_projectionLocationParticle, 1, GL_FALSE, &projPersp[0][0]);

    // TODO: buffer binding
    // TODO: Draw particles without depth write and with blending
    

    if (m_cumulativeTime > 1.0f / 60.0f)
    {
        m_cumulativeTime = 0.0f;
        if (++m_nParticles > m_nMaxParticles)
            m_nParticles = m_nMaxParticles;
    }
}

void SceneParticles::updateInput(Window& w)
{
    int x = 0, y = 0;
    if (m_isMouseMotionEnabled)
        w.getMouseMotion(x, y);
    m_cameraOrientation.y -= x * 0.01f;
    m_cameraOrientation.x -= y * 0.01f;
    
    if (w.getKeyHold(Window::Key::W))
        m_cameraOrientation.x -= 0.03;
    if (w.getKeyHold(Window::Key::S))
        m_cameraOrientation.x += 0.03;
    if (w.getKeyHold(Window::Key::A))
        m_cameraOrientation.y -= 0.03;
    if (w.getKeyHold(Window::Key::D))
        m_cameraOrientation.y += 0.03;
}

void SceneParticles::drawMenu()
{
    if (!m_menuVisible) return;

    ImGui::Begin("Scene Parameters");
    ImGui::End();
}


void SceneParticles::initializeShader()
{
    // Particule shader
    {
        std::string vertexCode = readFile("shaders/particle.vs.glsl");
        std::string geometryCode = readFile("shaders/particle.gs.glsl");
        std::string fragmentCode = readFile("shaders/particle.fs.glsl");

        ShaderObject vertex(GL_VERTEX_SHADER, vertexCode.c_str());
        ShaderObject geometry(GL_GEOMETRY_SHADER, geometryCode.c_str());
        ShaderObject fragment(GL_FRAGMENT_SHADER, fragmentCode.c_str());
        m_particuleShaderProgram.attachShaderObject(vertex);
        m_particuleShaderProgram.attachShaderObject(geometry);
        m_particuleShaderProgram.attachShaderObject(fragment);
        m_particuleShaderProgram.link();

        m_modelViewLocationParticle = m_particuleShaderProgram.getUniformLoc("modelView");
        m_projectionLocationParticle = m_particuleShaderProgram.getUniformLoc("projection");
    }
    
    // Transform feedback shader
    {
        std::string vertexCode = readFile("shaders/transformFeedback.vs.glsl");

        ShaderObject vertex(GL_VERTEX_SHADER, vertexCode.c_str());
        m_transformFeedbackShaderProgram.attachShaderObject(vertex);

        // TODO
        
        m_transformFeedbackShaderProgram.link();

        m_timeLocationTransformFeedback = m_transformFeedbackShaderProgram.getUniformLoc("time");
        m_dtLocationTransformFeedback = m_transformFeedbackShaderProgram.getUniformLoc("dt");
    }
}

void SceneParticles::initializeTexture()
{
    m_flameTexture.setFiltering(GL_LINEAR);
    m_flameTexture.setWrap(GL_CLAMP_TO_EDGE);
}

