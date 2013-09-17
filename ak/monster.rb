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
  
  # 卡组管理
  def menu_list_monster
    clear_screen
    
    choose do |menu|
      menu.header = "卡组管理 >> 列打印卡牌"
      menu.character = true
      menu.echo = false
      menu.prompt = "请输入类型序号"
      
      menu.choices("所有卡牌") {
        clear_screen
        list_all_monster
        pause
      }
      
      menu.choices("被保护卡牌") {
        clear_screen
        list_protected_monster
        pause
      }
      
      menu.choices("降妖防") {
        clear_screen
        list_monster(2) {|item|
          item.skill_description["降低敵方妖魔防禦力"]
        }
        pause
      }
      
      menu.choices("降神防") {
        clear_screen
        list_monster(2) {|item|
          item.skill_description["降低敵方神靈防禦力"]
        }
        pause
      }
      
      menu.choices("降99防") {
        clear_screen
        list_monster(2) {|item|
          item.skill_description["降低敵方九十九神防禦力"]
        }
        pause
      }

      menu.choice("返回") {
      }
    end
  end
  
  
  def list_monster(display_style = 1, &filter_block)
    filter_block = Proc.new {|_item| true} unless filter_block
    
    begin
      monsters = fetch_monsters.select(&filter_block)
      log "符合条件的式神共计 #{monsters.count}"
    
      monsters.each {|item|
        # p item
        puts item.to_s(display_style)
      }
  
    rescue => e
      p e.inspect
      puts e.backtrace
    end
  end
  
  # 打印被保护式神
  def list_protected_monster
    list_monster(1) {|item|
        item.is_not_use_material
    }
  end
  
  # 打印所有式神
  def list_all_monster
    list_monster(2)
  end
  
  # 获取式神数据
  # 返回数组，元素是 AKMonster
  def fetch_monsters
    json = request( "/app.php?_c=monster&action=jsonlist&list_type=all&order_by=rarity-desc", nil,  "获取式神数据...")[:json]
    monsters = json["monsters"]
    
    monsters.map! {|item|
      AKMonster.new item
    }
    
    @monsters_cache = monsters
    monsters
  end
  
end
