# 式神
# 

class AKMonster
  attr_reader :is_not_use_material
  attr_reader :inventory_id
  attr_reader :master_id
  attr_reader :is_max_level
  attr_reader :rarity
  attr_reader :level
  attr_reader :name
  attr_reader :attribute
  attr_reader :skill_description
  attr_reader :attack_point
  attr_reader :defense_point
  attr_reader :required_guts
  attr_reader :skill_level
  
  def initialize(info)
    @is_not_use_material = info["is_not_use_material"] || false
    @inventory_id = info["inventory_monster_id"] || -1
    @master_id = info["master_id"] || -1
    @is_max_level = info["is_level_cap"] || false
    @level = info["level"] || 0
    @rarity = info["rarity"] || -1
    @name = info["name"] || ""
    @attribute = info["attribute"] || -1
    @skill_description = info["skill_description"] || "无"
    @attack_point = info["attack_point"] || 0
    @defense_point = info["defense_point"] || 0
    @required_guts = info["required_guts"] || 1
    @skill_level = info["skill_level"] || 0
  end
  
  def max_level?
    @is_max_level
  end
  
  def to_s(style = 1)
    case style
    when 1
      format("%-7s\t(%5d):  Lv%2d  A:%5d/%3d  D:%5d/%3d  耗:%2d  技(%2d): %s", @name, @inventory_id, @level, @attack_point, @attack_point/@required_guts, @defense_point, @defense_point/@required_guts, @required_guts, @skill_level, @skill_description)
      
    when 2
      format("%5d %-9s\t(%5d):  Lv%2d  A:%5d/%3d  D:%5d/%3d  耗:%2d  技: %s", @master_id, @name, @inventory_id, @level, @attack_point, @attack_point/@required_guts, @defense_point, @defense_point/@required_guts, @required_guts, @skill_description)
    end
  end
end


class AK
  
  attr_accessor :monsters_cache
  
  # 打印被保护式神
  def list_protected_monster
    begin
      log "获取式神数据..."
      protected_monsters = fetch_monsters.select {|item|
        item.is_not_use_material
      }
      log "被保护式神共计 #{protected_monsters.count}"
    
      protected_monsters.each {|item|
        # p item
        puts item.to_s
      }
  
    rescue => e
      p e.inspect
      puts e.backtrace
    end

  end
  
  # 打印所有式神
  def list_all_monster
    begin
      log "获取式神数据..."
      monsters = fetch_monsters
      monsters.each {|item|
        puts item.to_s(2)
      }
      log "式神共计 #{monsters.count}"
  
    rescue => e
      p e.inspect
      puts e.backtrace
    end

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
  
  # 获取式神数据
  # 返回数组，元素是 AKMonster
  def fetch_monsters
    json = request( "/app.php?_c=monster&action=jsonlist&list_type=all&order_by=rarity-desc")[:json]
    monsters = json["monsters"]
    
    monsters.map! {|item|
      AKMonster.new item
    }
    
    @monsters_cache = monsters
    monsters
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
  
end
