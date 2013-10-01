
class AK
  
  
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
      
      menu.choices("查看已保存的组队") {
        list_saved_team
        pause
      }
    
      menu.choices("查看卡牌") {
        clear_screen
        menu_list_monster
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
  
  
  # 列印攻击组
  # 返回攻击组成员ID数组
  def get_offense_team()
    json = request( "/app.php?_c=monster&action=jsonlist&list_type=offense&order_by=attack-desc", {}, "获取式神数据...")[:json]
    
    @monsters_cache = json["regularMonsters"] + json["reserveMonsters"]
    
    monsters = json["regularMonsters"].map! {|item|
      AKMonster.new item
    }
    
    monster_ids = []
    monsters.each {|item|
      puts item.to_s
      monster_ids.push item.inventory_id
    }
    
    monster_ids
  end
  
  # 设置攻击组
  def set_offense_team(members = [])
    return if members.nil? || members.empty?
    
    offense_team_reset
    add_to_offense_team(members, 2)
    set_team_leader(members.first)
  end
  
  # 设为攻击组
  # 参数：id , 优先级
  def add_to_offense_team(id_or_ids, priority = 1)
    return if id_or_ids.nil?
    
    log "设置优先级"
    if id_or_ids.is_a?(Integer)
      if id_or_ids > 0
         request("/app.php?_c=monster&action=setPriority&list_type=offense&inventory_monster_id=#{id_or_ids}&priority=#{priority}")
      end
    elsif id_or_ids.is_a?(Array)
      request = Net::HTTP::Post.new("/app.php?_c=monster&action=AttackBulk", {
        "Accept-Language" => "zh-cn",
        "Cookie" => @cookie,
        "User-Agent" => @userAgent
      })
      request.set_form_data({
        "_c" => "monster",
        "action" => "AttackBulk",
        "inventory_monster_ids" => id_or_ids * ","
      })
      
      retry_count = 1
      begin
        @http.request(request)
      rescue => e
        retry if retry_count > 0
        retry_count -= 1
      end
      
    else
      raise(ArgumentError, "参数类型错误")
    end
  end
  
  # 重置攻击组
  # 无返回
  def offense_team_reset
    request("/app.php?_c=monster&action=resetPriority&list_type=offense", nil, "重置攻击组")
    nil
  end
  
  # 设置队长
  # 无返回
  def set_team_leader(id)
    id ||= -1
    request("/app.php?inventory_monster_id=#{id}&_c=monster&action=setLeader", nil, nil, true) if id > 0
    nil
  end
  
  # 配置文件
  # 组队已保存？
  def team_saved?(ids)
    raise(ArgumentError, "组队为空") if Array(ids).empty?
    
    saved_teams = Array(@user_default["team"])
    saved_teams.each {|team|
      return true if team[:ids].eql?(ids)
    }
    return false
  end
  
  # 保存组队到配置文件
  def save_team_to_config(ids)
    raise(ArgumentError, "组队为空") if Array(ids).empty?
    return if team_saved?(ids)
    
    begin
      note = ask("输入该组队的备注：")
      item = { :note => note.to_s, :ids => ids }
      @user_default["team"] ||= []
      @user_default["team"].push(item)
      save_user_default
      puts "已保存"
      
    rescue Interrupt
      puts "取消操作"
    end
  end
  
  # 从配置文件中移除组队
  def remove_team_from_config(ids)
    raise(ArgumentError, "组队为空") if Array(ids).empty?
    return if !team_saved?(ids)
    
    @user_default["team"].delete_if {|item|
      item[:ids].eql?(ids)
    }
    save_user_default
    puts "已移除"
    
  end
  
  # 查看保存组队
  def list_saved_team
    teams = @user_default["team"]
    if Array(teams).empty?
      puts "没有保存任何队伍"
    end
    
    teams.each {|item|
      puts "#{item[:note]} #{item[:ids]}"
    }
  end
  
end # class AK
