require 'io/console'

module Kernel
  # 打印带时间的日志
  def log(string)
    print "#{Time.now.strftime("%H:%M:%S")} #{string}\n"
  end

  # 清屏
  def clear_screen
    print "\e[H\e[2J"
  end
  
  def beep
    print "\a"
  end
  
  def speak(string)
    Thread.new {
      system("say #{string}")
    }
  end
  
  def pause(promote = nil)
    promote ||= "按任意键继续..."
    print "#{promote}\n"
    IO.console.getch
  end
end
