
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
  
  def say(string)
    Thread.new {
      system("say #{string}")
    }
  end
  
end
