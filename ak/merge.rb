# 

class AK
  
  # 用材料式神喂被保护的式神
  def merge_up
    
    begin
      all_monsters = fetch_monsters
    
      monster_needs_upgrade = all_monsters.select {|m|
        !m.max_level? && m.rarity >= 1 && m.is_not_use_material
      }
      
      log "需要升级的式神："
      monster_needs_upgrade.each {|item|
        puts item.to_s(1)
      }
      
      material_pool = all_monsters - monster_needs_upgrade
      material_pool.select! {|m|
        m.level >=5 && m.level <=8 && m.rarity < 3 && !m.is_not_use_material
      }
      # log "材料式神共计 #{material_pool.count}"
      
      monster_needs_upgrade.each {|m|
        ct_attribute = m.attribute
        
        ct_materials = material_pool.select {|material|
          material.attribute == ct_attribute
        }
        
        if ct_materials.empty?
          log "没有材料可以强化 #{m.name}，跳过"
        else
          log "强化 #{m.name} 中"
          material_pool -= ct_materials
          
          # log "当前材料 #{ct_materials}"
          m_level_should_be = m.rarity * 10 + 20
          ct_level = m.level
          ct_id = m.inventory_id
          
          while ct_level < m_level_should_be && !ct_materials.empty?
            ct_level = merge_with_materials(ct_id, [ct_materials.pop.inventory_id]).to_i
          end
          
          material_pool += ct_materials
        end
      }
  
    rescue => e
      puts e.inspect
      puts e.backtrace
    end
  end
  
  def get_merge_rule
    return @merge_rule if @merge_rule
    
    @merge_rule = MergeRule.new {
      define3(89, "反枕")
      define3(91, "鐮鼬")
      define3(90, "鼠幫嘍囉")

      define(  2, 116, "管狐+黑曜石勾玉")
      define( 15, 116, "雪童子+黑曜石勾玉")
      define(342, 113, "可樂小童+黑曜石勾玉")
      define(343, 116, "鳥身女妖+黑曜石勾玉")
      define(344, 116, "鬼火+黑曜石勾玉")
    
      define( 90, 116, "鼠幫嘍囉+黑曜石勾玉")

      define(105, 113, "山崎烝+水晶勾玉")
      define(153, 113, "藍天使+水晶勾玉")
      define(154, 113, "九天玄女+水晶勾玉")
      define(270, 113, "領航員克拉克+水晶勾玉")
      define(327, 113, "水手雪莉+水晶勾玉")
      define(351, 113, "朝食+水晶勾玉")
      define(352, 113, "午食+水晶勾玉")
      define(353, 113, "晚食+水晶勾玉")
      define(362, 113, "黑天使+水晶勾玉")

      define(  1, 113, "天鈿女命+水晶勾玉")
      define( 77, 113, "白天使+水晶勾玉")
      define(345, 113, "朧+水晶勾玉")
      define(360, 113, "激素劍士+水晶勾玉")

      define(101, 113, "楓+水晶勾玉")
      define3(101, "楓")

      define3(102, "飛鏢女")
      define3(103, "手指虎")
      define3(355, "戰輪")

      define(104, 119, "娜塔莉奈浮+電氣石勾玉")
      define(106, 119, "西維亞+電氣石勾玉")
      define(799, 119, "長髮公主的頭髮[夏]+電氣石勾玉")
      define(350, 119, "風車+電氣石勾玉")
      define(355, 119, "戰輪+電氣石勾玉")
    }
  end
  
  def merge
    mr = get_merge_rule
  
    response = request("/app.php?_c=merge", {}, "请求式神数据...")[:raw]
      
    dataString = response[/materialMonsters\:\s+(\[.*\])/, 1]
    json = JSON.parse(dataString)
    log "式神共计 #{json.count}"
  
    mergedCount = 0
    mr.rules.each {|rule|
      if rule[:bulk]
        mergedCount += bulkMerge(rule[:target], json)
      elsif
        targetItems = json.select {|item|
          item['master_id'] == rule[:target] && item['level'] == 1
        }
        json -= targetItems
      
        meterialItmes = json.select {|item|
          item['master_id'] == rule[:meterial] && item['level'] == 1
        }
        json -= meterialItmes
      
        while !targetItems.empty? && !meterialItmes.empty?
          merge_with_materials(
            targetItems.pop['inventory_monster_id'],
            [ meterialItmes.pop['inventory_monster_id'] ]
          )
          mergedCount += 1
        end
  
        json += targetItems
        json += meterialItmes
      end
    }
  
    if mergedCount != 0
      print "\n"
      log "#{mergedCount} 个式神被合并"
    else
      log "没有式神可被合并"
    end
    
    mergedCount
  end

  # 大批3合1
  def bulkMerge(masterID, materialItems)
    mt = materialItems.select {|item|
      item['master_id'] == masterID && item['level'] == 1
    }
  
    mergedCount = 0
    materialItems -= mt
    while mt.count >= 4
      merge_with_materials(mt.pop['inventory_monster_id'], mt.pop(3).map{|item| item['inventory_monster_id']})
      mergedCount += 3
    end
    materialItems += mt
  
    return mergedCount
  end

  # 合并卡牌
  # 输入卡牌ID
  # 返回升级后的级数目
  def merge_with_materials(main, materialArray)
    response = request("/app.php?_c=merge&action=merge_bulk&base_inventory_monster_id=#{main}&material_inventory_monster_ids[]=#{materialArray.join("&material_inventory_monster_ids[]=")}")
    
    if response[:raw][/<title>merge merge_bulk - ayakashi<\/title>/]
      html = response[:html]
      level_tag = html.css('#level-up-text span.st').first
      level = level_tag.content
      print "#{level} "
      return level
    else
      print "x "
      -1
    end
  end
  
  def printMaterialArray(array)
    array.each {|item|
      p "#{item['name']} #{item['inventory_monster_id']} #{item['master_id']}"
    }
  end
end