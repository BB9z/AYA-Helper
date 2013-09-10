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
  
  # 卡组管理
  def menu_team
    clear_screen
    
    choose do |menu|
      menu.header = ">> 卡组管理"
      menu.character = true
      menu.echo = false
      menu.prompt = "请输入操作序号"
      
      menu.choices("攻击组查看") {
        ids = get_offense_team
        menu_team_management(ids)
      }
      menu.choices("防御组查看") {
      }
    
      menu.choices("设置攻击组") {
        menu_team_picker {|ids|
          log "设置中，请稍后..."
          set_offense_team(ids)
          puts "攻击组已更新"
          pause
        }
      }
      
      menu.choices("攻击组重置") {
        log "设置中，请稍后"
        offense_team_reset
      }
    
      menu.choices("设置防御组") {
        log "设置中，请稍后"
        
      }
      
      menu.choices("查看已保存的组队") {
        list_saved_team
        pause
      }
    
      menu.choices("列印被保护卡牌") {
        clear_screen
        list_protected_monster
        pause
      }
      
      menu.choices("列印所有卡牌") {
        clear_screen
        list_all_monster
        pause
      }

      menu.choice("返回") {
      }
    end
  end
  
  # 选择队伍
  def menu_team_picker(&block)
    raise(ArgumentError, "必须有回调") if !block_given?
    
    choose {|menu|
      menu.header = "选择队伍"
      menu.prompt = "键入输入序号，然后按回车"
      
      menu.choices("手工输入") {
        input = ask("输入攻击组卡牌ID数组，首位为队长，如 100 21 3 56 3：").split(/\D/)
        input.map! {|item| item.to_i }
        input.keep_if {|item| item.to_i > 0}
        
        yield(input)
      }
      
      teams = @user_default["team"]
      if teams && teams.count > 0
        teams.each {|item|
          menu.choice("#{item[:note]} #{item[:ids]}") {
            yield(item[:ids])
          }
        }
      end
    
      menu.choice("取消") {
      }
    }
  end
  
  # 管理当前显示的队伍
  def menu_team_management(ids = [])
    choose do |menu|
      menu.header = ">> 卡组管理"
      menu.prompt = "输入操作序号，然后按回车"
      
      if team_saved?(ids)
        menu.choices("从预设中移除") {
          remove_team_from_config(ids)
          pause
        }
      else
        menu.choices("保存到预设") {
          save_team_to_config(ids)
          pause
        }
      end
      
      menu.choice("设置为当前进攻组") {
        clear_screen
        log "设置中请稍后"
        set_offense_team(ids)
        pause
      }
      
      menu.choice("设置为当前防守组") {
        clear_screen
        log "设置中请稍后"
      }

      menu.choice("返回") {
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
        auto_farm
      }
      
      menu.choice("自动爬塔") {
        et = EventTower.new(self)
        et.run(true)
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
