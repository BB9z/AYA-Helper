# 

class AK
  
  # 用材料式神喂被保护的式神
  def merge_up
    monster = list_monster(1) {|item|
        item.is_not_use_material && !item.max_level?
    }
    
    restart
    
    response = request("/app.php?_c=merge", {}, "请求式神数据...")[:raw]
  
    dataString = response[/materialMonsters\:\s+(\[.*\])/, 1]
    json = JSON.parse(dataString)
    log "式神共计 #{json.count}"
    printMaterialArray(json)
    exit
  
  
    monsters = json.map {|item| AKMonster.new(item)}
  
    up_monsters = monsters.select {|m|
      !m.max_level? && m.rarity >= 3 && m.is_not_use_material
    }
    monsters -= up_monsters
    p up_monsters
    
    monsters = monsters.sort {|a, b|
      
      
      if a.rarity != b.rarity
        return +1 if a.rarity > b.rarity
        return -1
      end
      
      
    }
    
    
    return if up_monsters.empty?
  
    reday_materials = monsters.select {|m|
      m.level >=5 && m.level <=8 && m.rarity < 3 && !m.is_not_use_material
    }
    p reday_materials
    monsters -= reday_materials
  end
  
  def get_merge_rule
    return @merge_rule if @merge_rule
    
    @merge_rule = MergeRule.new {
      define( 89, 116, "反枕+黑曜石勾玉")
      
      define3(89, "反枕")
      define3(91, "鐮鼬")
      define3(90, "鼠幫嘍囉")

      define(  2, 116, "管狐+黑曜石勾玉")
      define( 15, 116, "雪童子+黑曜石勾玉")
      define(342, 113, "可樂小童+黑曜石勾玉")
      define(343, 116, "鳥身女妖+黑曜石勾玉")
    
      define( 90, 116, "鼠幫嘍囉+黑曜石勾玉")

      define(105, 113, "山崎烝+水晶勾玉")
      define(270, 113, "領航員克拉克+水晶勾玉")
      define(351, 113, "朝食+水晶勾玉")
      define(352, 113, "午食+水晶勾玉")
      define(353, 113, "晚食+水晶勾玉")
      define(362, 113, "黑天使+水晶勾玉")

      define(  1, 113, "天鈿女命+水晶勾玉")
      define(345, 113, "朧+水晶勾玉")
      define(360, 113, "激素劍士+水晶勾玉")

      define(101, 113, "楓+水晶勾玉")
      define3(101, "楓")

      define3(102, "飛鏢女")
      define3(103, "手指虎")
      define3(355, "戰輪")

      define(104, 119, "娜塔莉奈浮+電氣石勾玉")
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
          mergedCount += mergeCard(
            targetItems.pop['inventory_monster_id'],
            [ meterialItmes.pop['inventory_monster_id'] ]
          )
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
      mergedCount += mergeCard(mt.pop['inventory_monster_id'], mt.pop(3).map{|item| item['inventory_monster_id']})
    end
    materialItems += mt
  
    return mergedCount
  end

  # 合并卡牌
  # 输入卡牌ID
  # 返回被吸收的卡牌数
  def mergeCard(main, materialArray)
    response = request("/app.php?_c=merge&action=merge_bulk&base_inventory_monster_id=#{main}&material_inventory_monster_ids[]=#{materialArray.join("&material_inventory_monster_ids[]=")}")
    
    if response[:raw][/<title>merge merge_bulk - ayakashi<\/title>/]
      html = response[:html]
      html.css('#level-up-text span.st').each {|tag|
        print "#{tag.content} "
      }
      materialArray.count
    else
      print "x "
      0
    end
  end
  
  def printMaterialArray(array)
    array.each {|item|
      p "#{item['name']} #{item['inventory_monster_id']} #{item['master_id']}"
    }
  end
end