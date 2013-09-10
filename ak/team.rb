
class AK
  
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
    members ||= []
    
    members.each_index {|ix|
      if ix == 0
        offense_team_reset
      
        set_team_leader members[ix]
      else
        add_to_offense_team(members[ix], 2)
      end
    }
  end
  
  # 设为攻击组
  # 参数：id , 优先级
  def add_to_offense_team(id, priority = 1)
    id ||= -1
    if id > 0
       request "/app.php?_c=monster&action=setPriority&list_type=offense&inventory_monster_id=#{id}&priority=#{priority}"
    end
    nil
  end
  
  # 重置攻击组
  # 无返回
  def offense_team_reset
    request("/app.php?_c=monster&action=resetPriority&list_type=offense")
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
    
    saved_teams = @user_default["team"]
    saved_teams ||= []
    
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
