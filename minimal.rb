require 'opengl'
require_relative 'glfw'
include GLFW

key_callback = Proc.new do |window_handle, key, scancode, action, mods|
  if key == GLFW_KEY_ESCAPE && action == GLFW_PRESS
    glfwSetWindowShouldClose(window_handle, 1)
  end
end

if __FILE__ == $0
  glfwInit()
  window = glfwCreateWindow( 640, 480, "minimal", nil, nil )
  glfwMakeContextCurrent( window )
  glfwSetKeyCallback( window, key_callback )

  while glfwWindowShouldClose( window ) == 0
    glClear(GL_COLOR_BUFFER_BIT)
    glfwSwapBuffers( window )
    glfwPollEvents()
  end

  glfwDestroyWindow( window )
  glfwTerminate()
end
