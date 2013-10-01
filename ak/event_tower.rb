# 爬塔

class AK
  


class EventTower
  
  attr_accessor :evid
  attr_accessor :island_id
  attr_accessor :area_id
  attr_accessor :stage_id
  
  attr_accessor :auto_mode
  attr_accessor :encounter_battle_mode
  attr_accessor :stage
  attr_accessor :step_energy
  attr_accessor :monster_id
  attr_accessor :battle_rule
  attr_accessor :encounter_battle_rule
  
  # 碎片计数器
  attr_accessor :item_flag
  
  def initialize(master)
    raise if !master
    
    @core = master
    @evid = 28
    @island_id = 1
    @item_flag = 0
    
    @team_leader_default = 1365
    
    @encounter_battle_rule = {
      "10821" => {
        "name" => "兔子兵",
        "defense" => 10523,
        "resign" => true,
        "team" => [],
        "guts" => 36
      },
      "10822" => {
        "name" => "竹林",
        "defense" => 13422,
        "resign" => true,
        "team" => [],
        "guts" => 42
      },
      "10823" => {
        "name" => "兔子火箭筒",
        "defense" => 29295,
        "resign" => true,
        "team" => [3834, 2871, 7349, 10092, 10057],
        "guts" => 63
      },
      "10824" => {
        "name" => "流浪的吉他手",
        "defense" => 41983,
        "resign" => true,
        "team" => [8404, 3834, 7349, 10092, 10057],
        "guts" => 76
      },
      "10825" => {
        "name" => "大納言大伴御行",
        "defense" => 54124,
        "resign" => false,
        "team" => [10614, 8404, 3834, 3535, 7349],
        "guts" => 117
      },
      "10826" => {
        "name" => "蓬萊的玉之枝",
        "defense" => 80000,
        "resign" => false,
        "team" => [2718, 8404, 3834, 10823, 3774],
        "guts" => 152
      },
      "10827" => {
        "name" => "超級滿月",
        "defense" => 138000,
        "resign" => false,
        "team" => [],
        "guts" => 153
      },
      "10828" => {
        "name" => "時之帝",
        "defense" => 142000,
        "resign" => false,
        "team" => [],
        "guts" => 153
      }
    }
    
    # 兔子
    # 3834 10823 10057 7349 3291
    
    # 吉他
    # 8404 3834 10823 10057 7349
    
    329751814
    
    @battle_rule = {
      "70" => {
        "name" => "稚鳥",
        "defense" => 6477,
        "team" => [7349, 10092, 10057, 1116, 3291],
        "guts" => 30
      },
      "75" => {
        "name" => "稚鳥",
        "defense" => 12165,
        "team" => [2871, 7349, 10092, 10057, 1116],
        "guts" => 41
      },
      "80" => {
        "name" => "桃太郎",
        "defense" => 1500,
        "team" => [7349, 10092, 10057, 1116, 3291],
        "guts" => 41
      },
      "85" => {
        "name" => "桃太郎",
        "defense" => 2211,
        "team" => [],
        "guts" => 0
      },
      "90" => {
        "name" => "桃太郎",
        "defense" => 3633,
        "team" => [],
        "guts" => 0
      },
      "95" => {
        "name" => "桃太郎",
        "defense" => 6477,
        "team" => [],
        "guts" => 0
      },
      "100" => {
        "name" => "桃太郎",
        "defense" => 12165,
        "team" => [10330, 7349, 10092, 10057, 1116],
        "guts" => 48
      },
      "110" => {
        "name" => "讃岐造",
        "defense" => 3200,
        "team" => [7349, 1116, 3291, 10092, 10057],
        "guts" => 30
      },
      "120" => {
        "name" => "讃岐造",
        "defense" => 4716,
        "team" => [7349, 1116, 3291, 10092, 10057],
        "guts" => 30
      },
      "130" => {
        "name" => "讃岐造",
        "defense" => 7748,
        "team" => [7349, 1116, 3291, 10092, 10057],
        "guts" => 30
      },
      "140" => {
        "name" => "讃岐造",
        "defense" => 13812,
        "team" => [3832, 7349, 1161, 3291, 10092],
        "guts" => 41
      },
      "150" => {
        "name" => "讃岐造",
        "defense" => 32000,
        "team" => [1365, 4371, 8400, 10123, 10089],
        "guts" => 45
      },
      "160" => {
        "name" => "月兔姫",
        "defense" => 4800,
        "team" => [7349, 1116, 3291, 10092, 10057],
        "guts" => 30
      },
      "170" => {
        "name" => "月兔姫",
        "defense" => 7074,
        "team" => [7349, 1116, 3291, 10092, 10057],
        "guts" => 30
      },
      "180" => {
        "name" => "月兔姫",
        "defense" => 11622,
        "team" => [8404, 7349, 1161, 3291, 10092],
        "guts" => 36
      },
      "190" => {
        "name" => "月兔姫",
        "defense" => 20718
      },
      "200" => {
        "name" => "月兔姫",
        "defense" => 48000
      }
    }
  end
  
  # 更新楼层状态
  # 返回是否更新成功
  def update_stage_info
    response = @core.request("/app.php?evid=#{@evid}&newest=1&_c=ExtraQuestEventAdventure&action=stage", {}, "获取状态...")
    
    body = response[:raw]
    html = response[:html]
    
    case html.title
    when "ExtraQuestEventAdventure stage - ayakashi"
      p html
      @stage = html.css("#stage-name").first.content.to_i
      log "当前处于 #{@stage} 层"
  
      stage_info = body[/stage:\s+(\{.*\})/, 1]
      if stage_info
        json = JSON.parse(stage_info)
        @area_id = json["area_id"]
        @stage_id = json["master_id"]
        return
      end
    
    when "extra_quest_event_negotiation found - ayakashi"
      p response[:url]
      p @monster_id
      p @encounter_battle_mode
      
      response2 =  @core.request("http://zc2.ayakashi.zynga.com/app.php?evid=#{@evid}&_c=extra_quest_event_negotiation&action=found")
      
      html2 = response2[:html]
      # 不能收，直接释放
      if html2.css('#use-item-button').empty?
        resign_current_encounter
        return update_stage_info
      end
      
      name = html.css('#monster-status .name span').first.content
      promote = html.css('#use-item-button').first.children.first.text
      if agree("#{promote}，交换 #{name}？")
        @core.request("/app.php?_c=extra_quest_event_negotiation&action=negotiate&method=use&evid=#{@evid}", nil, nil, true)
        return update_stage_info
        
      else
        resign_current_encounter
        return update_stage_info
      end

    when "extra_quest_event_npc_battle confirm - ayakashi"
      @monster_id = response[:url][/battle_id=(\d+)/, 1].to_i
      p response[:url]
      fight()
      
    else
      log "不在状态 #{html.title}"
    end
  end # update_stage_info
  
  # 返回为 false 表明操作需进一步干预
  def investigate()
    
    json = @core.request("/app.php?_c=extra_quest_event_adventure&action=proceed&evid=#{@evid}&newest=1", {
      "Accept" => 'application/json'
    })[:json]
    @core.user.update_with_stage_info(json)
    @step_energy = json["stage"]["energy"]
    
    events = json["events"]
    if events.empty?
      log "无事件发生"
      return true
    end
    
    events.each {|event|
      case event["type"]
      when "REDIRECT"
        return proccess_event_redirect(event)
    
      when "NO_ENOUGH_ENERGY"
        log "体力消耗光了"
        speak("NO ENOUGH ENERGY")
        @item_flag = 0
        exit unless @auto_mode
    
      when "GET_EVENT_ITEM"
        @item_flag = (@item_flag == 0)? 3 : @item_flag + 1
        discovery = event["values"]["discovery"]
        log "获取事件物品#{discovery["count"]}，共计#{discovery["totalCount"]}"

      when "GET_MONSTER"
        proccess_event_get_monster(event)
    
      when "STAGE_COMPLETE"
        log "楼层完成"
        return false
    
      when "STAGE_BATTLE_MODE"
        log "进入楼层战斗 #{event}"
        return false

      when nil
        log "事件nil"

      when "LEVEL_UP"
        log "升级了～"
        speak("LEVEL UP")

      else
        log "未处理的类别 #{event}"
      end
    }
    
    true
  end
  
  def proccess_event_get_monster(event)
    monster = event["values"]["settings"]["monster"]
    monster_name = monster["name"]

    if monster["wasDeposited"]
      log "收到#{monster_name}"
      if !@cannot_merge_any_more
          @cannot_merge_any_more = true if @core.merge() == 0
      end
    else
      log "获得#{monster_name}"
      @cannot_merge_any_more = false
    end
  end
  
  def proccess_event_redirect(event)
    log "重定向事件 #{event}"
    uri = event["values"]["url"]
    @monster_id = uri[/battle_id=(\d+)/, 1].to_i
    return fight()
  end
  
  def run(auto_mode = false)
    @auto_mode = auto_mode
    @core.user.fetch_info
    update_stage_info
    
    begin
      while true
        if investigate
          if auto_mode
            if @item_flag > 0
              sleep(4)
              @item_flag -= 1
            else
              percentage = @core.user.info["energy_percentage"]
              minute = @step_energy
              minute -= 1 if percentage > 80
              minute += 1 if percentage < 50
              minute += 2 if percentage < 40
              minute += 3 if percentage < 30
              log "休息 #{minute}m"
              sleep(minute*60)
            end

          else
            sleep(2)
          end
        else
          update_stage_info
        end
      end
    rescue Interrupt
      log "停止"
    end
  end # run
  
  def fight(monster_id = @monster_id)
    if monster_id >= 11800
      log "朵拉 交换铺"
      log "TODO：结果与交涉识别"
      pause
      return false
    end
    
    if !@stage
      @stage = ask("现在是多少层？", Integer)
    end
    
    @encounter_battle_mode = (monster_id > 20000)? false : true
    p monster_id
    p @encounter_battle_mode
    point = @core.user.offense_guts
    log "@stage = #{@stage} 还有攻灵：#{point}"
    
    if @encounter_battle_mode
      info = @encounter_battle_rule[monster_id.to_s]
      p info
      log "遭遇 #{info["name"]}，防：#{info["defense"]}"
    else
      @stage += (5 - @stage%5) unless @stage%5    # 向上取道5的倍数
      p @stage.to_s
      info = @battle_rule[@stage.to_s]
      p info
      log "守卫 #{info["name"]}，防：#{info["defense"]}"
    end
    
    if @auto_mode
      log "选择攻击组 #{info["team"]} 需要灵力 #{info["guts"]}"
      minute_to_wait = info["guts"] - point
      
      if minute_to_wait > 0
        log "需要 #{minute_to_wait}m 恢复"
        sleep(minute_to_wait*60)
      end
      
      @core.set_offense_team(info["team"])
      speak("Fight")
    else
      speak("Ready fight?")
      pause("按任意键开打")
    end
    
    flag = @encounter_battle_mode? 1 : 0
     @core.request("/app.php?target_user_id=#{monster_id}&evid=#{evid}&encounter_battle_mode=#{flag}&_c=extra_quest_event_npc_battle&action=exec_battle", nil, "执行战斗", true)
    
    get_battle_result(@encounter_battle_mode)
    @core.set_team_leader(@team_leader_default)
    
    return true unless @encounter_battle_mode
    
    if info["resign"]
      resign_current_encounter
      return true
    else
      # TODO: 交涉页面分析
      log "看看能否操作"
      return false
    end
  end
  
  # 战斗结果
  # 返回是否战斗成功
  def get_battle_result(is_encounter = true)
    flag = (is_encounter)? 1 : 0
    html = @core.request("/app.php?hid=0&encounter_battle_mode=#{flag}&evid=#{@evid}&_c=extra_quest_event_npc_battle&action=battle_result")[:raw]
    
    if html[/id="tit-won"/].nil?
      log "战斗失败"
      speak("You lost")
      return false
      
    else
      log "战斗胜利"
      speak("You win")
      return true
      
    end
  end
  
  # 放弃当前游荡交涉
  def resign_current_encounter()
     @core.request("/app.php?_c=extra_quest_event_negotiation&action=resign&evid=#{@evid}", nil, "放弃交涉", true)
  end
  
end # class EventTower
end # class AK
