# 菜单

class AK
  
  # 主菜单
  def menu_home
    clear_screen
    say "<%= color('  -- AK 辅助系统 --  ', :bold, :white, :on_red) %>\n"
    
    choose do |menu|
      menu.header = "请选择操作"
      menu.character = true
      menu.echo = false
      menu.prompt = "请输入操作序号"
      menu.overwrite = true
      
      menu.choices("爬塔") {
        clear_screen
        et = EventTower.new(self)
        et.run
        pause
      }

      menu.choice("用户信息查看") {
        clear_screen
        p @user.offense_guts
        # @user.fetch_info
        pause
      }
      
      menu.choices("卡组管理") {
        menu_team
      }
      
      menu.choices("挂机模式") {
        menu_auto
      }
      
      menu.choices("耗尽模式") {
        menu_one_way
      }

      menu.choices("合并材料卡") {
        clear_screen
        merge
        pause
      }

      menu.choices("工会留言板") {
        clear_screen
        talk 5
        pause
      }
      
      menu.choices("设置") {
        menu_setting
      }
      
      menu.choices("重启") {
        clear_screen
        restart
      }
      
    end
    
    true
  end
  
  # 挂机模式
  def menu_auto
    clear_screen
    
    choose do |menu|
      menu.header = ">> 挂机模式"
      menu.character = true
      menu.echo = false
      menu.prompt = "请输入操作序号"
      
      menu.choice("自动211") {
        clear_screen
        log(">> 自动211")
        fm = Farm.new(self)
        fm.run
        pause
      }
      
      menu.choice("自动爬塔") {
        et = EventTower.new(self)
        et.run(true)
        pause
      }
      
      menu.choice("返回") {}
    end
  end
  
  # 耗尽模式
  def menu_one_way
    clear_screen
    
    choose do |menu|
      menu.header = ">> 耗尽模式"
      menu.character = true
      menu.echo = false
      menu.prompt = "请输入操作序号"
      
      menu.choice("211至无体力") {
        clear_screen
        log(">> 211至无体力")
        fm = Farm.new(self)
        fm.one_way_mode = true
        fm.farm_interval = 0
        fm.run
        pause
      }
      
      menu.choice("爬塔至无体力") {
        clear_screen
        log(">> 爬塔至无体力")
        et = EventTower.new(self)
        et.run
        pause
      }
      
      menu.choice("返回") {}
    end
  end
  
  # 设置
  def menu_setting
    clear_screen
    
    choose {|menu|
      menu.header = ">> 设置"
      menu.character = true
      menu.echo = false
      menu.prompt = "请输入操作序号"
      
      menu.choice("重设 cookies") {
        puts "当前 cookies 值:"
        puts @user_default["cookie"]
        
        string = ask("请输入 cookies 值，留空取消") {|q|
        }
        string = string.to_s
        if string.length > 0
          @user_default["cookie"] = string
          save_user_default
        else
          log "操作取消"
        end
        pause "按任意键返回..."
      }
      
      if @user_default["sound_alert"]
        menu.choice("关闭声音") {
          @user_default["sound_alert"] = false
          save_user_default
        }
      else
        menu.choice("开启声音") {
          @user_default["sound_alert"] = true
          save_user_default
        }
      end
      
      menu.choice("返回") {}
    }
  end
  
end
