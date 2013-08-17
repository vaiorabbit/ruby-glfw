# -*- coding: utf-8 -*-
require_relative 'glfw'

if __FILE__ == $0

  xpos_s32 = FFI::MemoryPointer.new :int
  ypos_s32 = FFI::MemoryPointer.new :int
  xpos_f64 = FFI::MemoryPointer.new :double
  ypos_f64 = FFI::MemoryPointer.new :double

  puts "===  glfwInit ==="
  p GLFW::glfwInit

  puts "=== glfwSetTime ==="
  GLFW::glfwSetTime( 0.0 )

  puts "===  glfwGetVersion ==="
  major_ptr = FFI::MemoryPointer.new :pointer
  minor_ptr = FFI::MemoryPointer.new :pointer
  rev_ptr = FFI::MemoryPointer.new :pointer
  GLFW::glfwGetVersion(major_ptr, minor_ptr, rev_ptr)
  print major_ptr.get_int32(0), minor_ptr.get_int32(0), rev_ptr.get_int32(0), "\n"

  puts "=== glfwGetVersionString ==="
  p GLFW::glfwGetVersionString

  puts "=== glfwSetErrorCallback ==="
  cb_GLFWerrorfun = Proc.new do |error_code, error_desc|
    p "glfwSetErrorCallback called.", error_code, error_desc
  end
  p GLFW::glfwSetErrorCallback( cb_GLFWerrorfun )

  puts "=== glfwGetMonitors ==="
  count = FFI::MemoryPointer.new :int
  monitors = GLFW::glfwGetMonitors(count)
  puts "count=#{count.get_int32(0)}"
  p monitors.get_pointer(0)

  puts "=== glfwGetPrimaryMonitor ==="
  primary_monitor = GLFW::glfwGetPrimaryMonitor()
  p primary_monitor

  puts "=== glfwGetMonitorPos ==="
  GLFW::glfwGetMonitorPos( primary_monitor, xpos_s32, ypos_s32 )
  puts "xpos=#{xpos_s32.get_int32(0)}, ypos=#{ypos_s32.get_int32(0)}"

  puts "=== glfwGetMonitorPhysicalSize ==="
  width = FFI::MemoryPointer.new :int
  height = FFI::MemoryPointer.new :int
  GLFW::glfwGetMonitorPhysicalSize( primary_monitor, width, height )
  puts "width=#{width.get_int32(0)}, height=#{height.get_int32(0)}"

  puts "=== glfwGetMonitorName ==="
  p GLFW::glfwGetMonitorName( primary_monitor )

  puts "=== glfwSetMonitorCallback ==="
  cb_GLFWmonitorfun = Proc.new do |primary_monitor, event|
    p "glfwSetMonitorCallback called.", primary_monitor, event
  end
  p GLFW::glfwSetMonitorCallback( cb_GLFWmonitorfun )

  puts "=== glfwGetVideoModes ==="
  count_out_ptr = FFI::MemoryPointer.new :int
  vid_modes = GLFW::glfwGetVideoModes( primary_monitor, count_out_ptr )
  count_out = count_out_ptr.get_int32(0)
  if count_out > 0
    count_out.times do |count|
      puts "glfwGetVideoModes : vid_modes[#{count}] exists."
    end
  else
    puts "glfwGetVideoModes : count_out == 0"
  end

  puts "=== glfwGetVideoMode ==="
  vid_mode_ptr = GLFW::glfwGetVideoMode( primary_monitor )
  vid_mode = GLFW::GLFWvidmode.new(vid_mode_ptr)
  puts "vidmode : width=#{vid_mode[:width]}, height=#{vid_mode[:height]}, redBits=#{vid_mode[:redBits]}, greenBits=#{vid_mode[:greenBits]}, blueBits=#{vid_mode[:blueBits]}, refreshRate=#{vid_mode[:refreshRate]}"

  puts "=== glfwGetGammaRamp ==="
  gamma_ramp_default_ptr = GLFW::glfwGetGammaRamp( primary_monitor )
  gamma_ramp_default = GLFW::GLFWgammaramp.new(gamma_ramp_default_ptr)
  puts "Default gamma ramp array count = #{gamma_ramp_default[:size]}"
  gamma_ramp_default[:size].times do |i|
    printf "\t [%02d] r=#{gamma_ramp_default[:red].get_ushort(i)}, g=#{gamma_ramp_default[:green].get_ushort(i)}, b=#{gamma_ramp_default[:blue].get_ushort(i)}\n", i
    if false #i >= 10
      puts "\t ..."
      break
    end
  end

  puts "=== glfwSetGamma ==="
  gamma_exponent = 2.2
  GLFW::glfwSetGamma( primary_monitor, gamma_exponent )
  puts "gamma exponent=#{gamma_exponent}"

  gamma_ramp_current_ptr = GLFW::glfwGetGammaRamp( primary_monitor )
  gamma_ramp_current = GLFW::GLFWgammaramp.new(gamma_ramp_current_ptr)
  puts "Current gamma ramp array count = #{gamma_ramp_current[:size]}"
  gamma_ramp_current[:size].times do |i|
    printf "\t [%02d] r=#{gamma_ramp_current[:red].get_ushort(i)}, g=#{gamma_ramp_current[:green].get_ushort(i)}, b=#{gamma_ramp_current[:blue].get_ushort(i)}\n", i
    if i >= 10
      puts "\t ..."
      break
    end
  end

  puts "=== glfwSetGammaRamp ==="
  # Build GLFWgammaramp instance
  gamma_exponent_restore = 1.5
  gamma_ramp_restore = GLFW::GLFWgammaramp.new
  gamma_ramp_restore[:size] = 256
  gamma_ramp_restore[:red] = FFI::MemoryPointer.new :ushort, 256
  gamma_ramp_restore[:green] = FFI::MemoryPointer.new :ushort, 256
  gamma_ramp_restore[:blue] = FFI::MemoryPointer.new :ushort, 256
  sizeof_ushort = 2
  for i in 0...256
    value = ((i / 255.0) ** (1.0 / gamma_exponent_restore)) * 65535.0 + 0.5
    value = 0.0 if value < 0.0
    value = 65535.0 if value > 65535.0
    put_offset = i*sizeof_ushort
    gamma_ramp_restore[:red].put_ushort(put_offset, value)
    gamma_ramp_restore[:green].put_ushort(put_offset, value)
    gamma_ramp_restore[:blue].put_ushort(put_offset, value)
  end

  gamma_ramp_restore[:size].times do |i|
    printf "\t [%02d] r=#{gamma_ramp_restore[:red].get_ushort(i)}, g=#{gamma_ramp_restore[:green].get_ushort(i)}, b=#{gamma_ramp_restore[:blue].get_ushort(i)}\n", i
    if i >= 10
      puts "\t ..."
      break
    end
  end
  GLFW::glfwSetGammaRamp( primary_monitor, gamma_ramp_restore )


  puts "=== glfwDefaultWindowHints ==="
  GLFW::glfwDefaultWindowHints()
  puts "Resets all window hints to default."

  puts "=== glfwWindowHint ==="
  GLFW::glfwWindowHint( GLFW::GLFW_CLIENT_API, GLFW::GLFW_OPENGL_API )
  GLFW::glfwWindowHint( GLFW::GLFW_SAMPLES, 1 )

  puts "=== glfwCreateWindow ==="
  window_handle = GLFW::glfwCreateWindow( 640, 480, "Ruby-3 (FFI Edition)", nil, nil )
  puts window_handle

  puts "=== glfwSetWindowTitle ==="
  GLFW::glfwSetWindowTitle( window_handle, "Ｒｕｂｙ−ＧＬＦＷ３（ＦＦＩ　Ｅｄｉｔｉｏｎ）" )

  puts "=== glfwGetWindowPos ==="
  GLFW::glfwGetWindowPos( window_handle, xpos_s32, ypos_s32 )
  puts "xpos=#{xpos_s32.get_int32(0)}, ypos=#{ypos_s32.get_int32(0)}"

  puts "=== glfwSetWindowPos ==="
  GLFW::glfwSetWindowPos( window_handle, 200, 200 )

  puts "=== glfwGetWindowSize ==="
  GLFW::glfwGetWindowSize( window_handle, width, height )
  puts "width=#{width.get_int32(0)}, height=#{height.get_int32(0)}"

  puts "=== glfwSetWindowSize ==="
  GLFW::glfwSetWindowSize( window_handle, 720, 405 )

  puts "=== glfwGetFramebufferSize ==="
  GLFW::glfwGetFramebufferSize( window_handle, width, height )
  puts "width=#{width.get_int32(0)}, height=#{height.get_int32(0)}"

  puts "=== glfwGetWindowMonitor ==="
  fullscreen_monitor = GLFW::glfwGetWindowMonitor( window_handle )
  puts "fullscreen_monitor=#{fullscreen_monitor}"

  puts "=== glfwGetWindowAttrib ==="
  window_attrib = GLFW::glfwGetWindowAttrib( window_handle, GLFW::GLFW_RESIZABLE )
  puts "window_attrib=#{window_attrib.to_s(16)}"
  window_attrib = GLFW::glfwGetWindowAttrib( window_handle, GLFW::GLFW_VISIBLE )
  puts "window_attrib=#{window_attrib.to_s(16)}"
  window_attrib = GLFW::glfwGetWindowAttrib( window_handle, GLFW::GLFW_ICONIFIED )
  puts "window_attrib=#{window_attrib.to_s(16)}"
  window_attrib = GLFW::glfwGetWindowAttrib( window_handle, GLFW::GLFW_DECORATED )
  puts "window_attrib=#{window_attrib.to_s(16)}"

  puts "=== glfwSetWindowUserPointer ==="
  puts "default_window_user_pointer=#{GLFW::glfwGetWindowUserPointer(window_handle)}"
  window_user_pointer = FFI::MemoryPointer.new :int
  puts "window_user_pointer=#{window_user_pointer}"
  GLFW::glfwSetWindowUserPointer( window_handle, window_user_pointer )
  puts "default_window_user_pointer=#{GLFW::glfwGetWindowUserPointer(window_handle)}"

  puts "=== glfwSetWindowPosCallback ==="
  cb_GLFWwindowposfun = Proc.new do |window_handle, xpos, ypos|
    p "GLFWwindowposfun called.", window_handle, xpos, ypos
  end
  p GLFW::glfwSetWindowPosCallback( window_handle, cb_GLFWwindowposfun )

  puts "=== glfwSetWindowSizeCallback ==="
  cb_GLFWwindowsizefun = Proc.new do |window_handle, width, height|
    p "GLFWwindowsizefun called.", window_handle, width, height
  end
  p GLFW::glfwSetWindowSizeCallback( window_handle, cb_GLFWwindowsizefun )

  puts "=== glfwSetWindowCloseCallback ==="
  cb_GLFWwindowclosefun = Proc.new do |window_handle|
    p "GLFWwindowclosefun called.", window_handle
  end
  p GLFW::glfwSetWindowCloseCallback( window_handle, cb_GLFWwindowclosefun )

  puts "=== glfwSetWindowRefreshCallback ==="
  cb_GLFWrefreshfun = Proc.new do |window_handle|
    p "GLFWrefreshfun called.", window_handle
  end
  p GLFW::glfwSetWindowRefreshCallback( window_handle, cb_GLFWrefreshfun )

  puts "=== glfwSetWindowFocusCallback ==="
  cb_GLFWfocusfun = Proc.new do |window_handle, focused|
    p "GLFWfocusfun called.", window_handle, focused
  end
  p GLFW::glfwSetWindowFocusCallback( window_handle, cb_GLFWfocusfun )

  puts "=== glfwSetWindowIconifyCallback ==="
  cb_GLFWiconifyfun = Proc.new do |window_handle, iconified|
    p "GLFWiconifyfun called.", window_handle, iconified
  end
  p GLFW::glfwSetWindowIconifyCallback( window_handle, cb_GLFWiconifyfun )

  puts "=== glfwSetFramebufferSizeCallback ==="
  cb_GLFWframebuffersizefun = Proc.new do |window_handle, width, height|
    p "GLFWframebuffersizefun called.", window_handle, width, height
  end
  p GLFW::glfwSetFramebufferSizeCallback( window_handle, cb_GLFWframebuffersizefun )

  puts "=== glfwSetKeyCallback ==="
  cb_GLFWkeyfun = Proc.new do |window_handle, key, scancode, action, mods|
    p "GLFWkeyfun called.", window_handle, key, scancode, action, mods
  end
  p GLFW::glfwSetKeyCallback( window_handle, cb_GLFWkeyfun )

  puts "=== glfwSetCharCallback ==="
  cb_GLFWcharfun = Proc.new do |window_handle, character|
    p "GLFWcharfun called.", window_handle, characer
  end
  p GLFW::glfwSetCharCallback( window_handle, cb_GLFWcharfun )

  puts "=== glfwSetMouseButtonCallback ==="
  cb_GLFWmousebuttonfun = Proc.new do |window_handle, button, action, mods|
    p "GLFWmousebuttonfun called.", window_handle, button, action, mods
  end
  p GLFW::glfwSetMouseButtonCallback( window_handle, cb_GLFWmousebuttonfun )

  puts "=== glfwSetCursorPosCallback ==="
  cb_GLFWcursorposfun = Proc.new do |window_handle, xpos, ypos|
    p "GLFWcursorposfun called.", window_handle, xpos, ypos
  end
  p GLFW::glfwSetCursorPosCallback( window_handle, cb_GLFWcursorposfun )

  puts "=== glfwSetCursorEnterCallback ==="
  cb_GLFWcursorenterfun = Proc.new do |window_handle, entered|
    p "GLFWcursorenterfun called.", window_handle, entered
  end
  p GLFW::glfwSetCursorEnterCallback( window_handle, cb_GLFWcursorenterfun )

  puts "=== glfwSetScrollCallback ==="
  cb_GLFWscrollfun = Proc.new do |window_handle, xoffset, yoffset|
    p "GLFWscrollfun called.", window_handle, xoffset, yoffset
  end
  p GLFW::glfwSetScrollCallback( window_handle, cb_GLFWscrollfun )

  puts "=== glfwGetInputMode ==="
  printf "GLFW_CURSOR=0x%08x\n", GLFW::glfwGetInputMode(window_handle, GLFW::GLFW_CURSOR)
  printf "GLFW_STICKY_KEYS=%d\n", GLFW::glfwGetInputMode(window_handle, GLFW::GLFW_STICKY_KEYS)
  printf "GLFW_STICKY_MOUSE_BUTTONS=%d\n", GLFW::glfwGetInputMode(window_handle, GLFW::GLFW_STICKY_MOUSE_BUTTONS)

  puts "=== glfwSetInputMode ==="
  GLFW::glfwSetInputMode( window_handle, GLFW::GLFW_CURSOR, GLFW::GLFW_CURSOR_NORMAL )
  GLFW::glfwSetInputMode( window_handle, GLFW::GLFW_STICKY_KEYS, 0 ) # GL_TRUE or GL_FALSE
  GLFW::glfwSetInputMode( window_handle, GLFW::GLFW_STICKY_MOUSE_BUTTONS, 0 ) # GL_TRUE or GL_FALSE

  puts "=== glfwJoystickPresent / glfwGetJoystickName ==="
  joystick_available = GLFW::glfwJoystickPresent( GLFW::GLFW_JOYSTICK_1 )
  puts "joystick_available = #{joystick_available > 0 ? 'TRUE' : 'FALSE'}"
  joystick_count_ptr = nil
  joystick_axes_count_ptr = nil
  joystick_buttons_count_ptr = nil
  joystick_axes_count = 0
  joystick_buttons_count = 0
  if joystick_available > 0
    joystick_count_ptr = FFI::MemoryPointer.new :int
    joystick_axes_count_ptr = FFI::MemoryPointer.new :int
    joystick_buttons_count_ptr = FFI::MemoryPointer.new :int
    puts "glfwGetJoystickName = #{GLFW::glfwGetJoystickName(GLFW::GLFW_JOYSTICK_1)}"

    GLFW::glfwGetJoystickAxes(GLFW::GLFW_JOYSTICK_1, joystick_axes_count_ptr)
    joystick_axes_count = joystick_axes_count_ptr.get_int32(0)
    puts "#axes = #{joystick_axes_count}"

    GLFW::glfwGetJoystickButtons(GLFW::GLFW_JOYSTICK_1, joystick_buttons_count_ptr)
    joystick_buttons_count = joystick_buttons_count_ptr.get_int32(0)
    puts "#button = #{joystick_buttons_count}"
  end

  puts "=== glfwSetClipboardString / glfwGetClipboardString ==="
  GLFW::glfwSetClipboardString( window_handle, "日本語" )
  puts "Clipboard string = #{GLFW::glfwGetClipboardString(window_handle)}"

  puts "=== glfwMakeContextCurrent / glfwGetCurrentContext ==="
  GLFW::glfwMakeContextCurrent( window_handle )
  puts "window_handle = #{window_handle}"
  puts "glfwGetCurrentContext() = #{GLFW::glfwGetCurrentContext()}"

  puts "=== glfwExtensionSupported / glfwGetProcAddress ==="
  extension_name = ["GL_EXT_framebuffer_object", "GL_ARB_buffer_storage"]
  extension_name.each do |ext|
    extension_available = 0 != GLFW::glfwExtensionSupported( ext )
    puts "#{ext} is #{extension_available ? 'available' : 'unavailable'}"
    if ext == "GL_EXT_framebuffer_object" && extension_available
      proc_name = "glFramebufferTexture2DEXT"
      proc_address = GLFW::glfwGetProcAddress( proc_name )
      puts "#{proc_name} is at #{proc_address.get_pointer(0)}"
    end
  end

  puts "=== glfwSwapInterval ==="
  GLFW::glfwSwapInterval( 1 )

  puts "=== glfwWindowShouldClose ==="
  loop_count = 0
  should_close = GLFW::glfwWindowShouldClose(window_handle)
  while ( should_close == 0 )
    # glfwSwapBuffers
    GLFW::glfwSwapBuffers( window_handle )
    # glfwPollEvents / glfwWaitEvents
    GLFW::glfwPollEvents() # GLFW::glfwWaitEvents()

    # glfwGetKey / glfwGetMouseButton
    space_key = GLFW::glfwGetKey( window_handle, GLFW::GLFW_KEY_SPACE )
    puts "GLFW_KEY_SPACE pressed." if space_key == GLFW::GLFW_PRESS

    mouse = GLFW::glfwGetMouseButton( window_handle, GLFW::GLFW_MOUSE_BUTTON_LEFT )
    puts "GLFW_MOUSE_BUTTON_LEFT pressed." if mouse == GLFW::GLFW_PRESS

    # glfwGetCursorPos / glfwSetCursorPos
    GLFW::glfwGetCursorPos( window_handle, xpos_f64, ypos_f64 )
    if GLFW::glfwGetKey(window_handle, GLFW::GLFW_KEY_LEFT_SHIFT) == GLFW::GLFW_PRESS
      puts "Cursor position=(#{xpos_f64.get_double(0)}, #{ypos_f64.get_double(0)} "
    end
    if GLFW::glfwGetKey(window_handle, GLFW::GLFW_KEY_RIGHT_SHIFT) == GLFW::GLFW_PRESS
      GLFW::glfwSetCursorPos( window_handle, 0.0, 0.0 )
      puts "Cursor position=(#{xpos_f64.get_double(0)}, #{ypos_f64.get_double(0)} "
    end

    # Check joystick inputs
    if joystick_available > 0
      # glfwGetJoystickAxes
      if joystick_axes_count > 0
        axis_values_ptr = GLFW::glfwGetJoystickAxes( GLFW::GLFW_JOYSTICK_1, joystick_axes_count_ptr )
        p axis_values_ptr.get_float(0)
      end

      # glfwGetJoystickButtons
      if joystick_buttons_count > 0
        button_status_ptr = GLFW::glfwGetJoystickButtons( GLFW::GLFW_JOYSTICK_1, joystick_buttons_count_ptr )
        p button_status_ptr.get_uchar(0)
      end
    end

    # Show / Hide Window
    loop_count += 1

    if loop_count == 10
      puts "=== glfwHideWindow ==="
      GLFW::glfwHideWindow( window_handle )
    end
    if loop_count == 20
      puts "=== glfwShowWindow ==="
      GLFW::glfwShowWindow( window_handle )
    end

    if loop_count == 50
      puts "=== glfwIconifyWindow ==="
      GLFW::glfwIconifyWindow( window_handle )
    end
    if loop_count == 100
      puts "=== glfwRestoreWindow ==="
      GLFW::glfwRestoreWindow( window_handle )
    end

    if loop_count > 500
      puts "=== glfwSetWindowShouldClose ==="
      close_value = 3
      puts "close_value=#{close_value}"
      GLFW::glfwSetWindowShouldClose( window_handle, close_value )
    end
    should_close = GLFW::glfwWindowShouldClose(window_handle)
  end
  puts "should_close=#{should_close}"

  puts "=== glfwDestroyWindow ==="
  GLFW::glfwDestroyWindow( window_handle )

  puts "=== glfwGetTime ==="
  puts "GLFW time = #{GLFW::glfwGetTime()}"

  puts "== glfwTerminate ==="
  p GLFW::glfwTerminate

end
