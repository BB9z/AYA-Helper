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
    @evid = 27
    @island_id = 1
    @item_flag = 0
    
    @team_leader_default = 1365
    
    @encounter_battle_rule = {
      "10821" => {
        "name" => "洲際彈道飛彈",
        "defense" => 12523,
        "resign" => true,
        "team" => [199, 7349, 1161, 3291, 10092],
        "guts" => 36
      },
      "10822" => {
        "name" => "希費斯特斯",
        "defense" => 13422,
        "resign" => true,
        "team" => [10330, 7349, 10091, 10089, 10123],
        "guts" => 42
      },
      "10823" => {
        "name" => "卡利",
        "defense" => 29295,
        "resign" => true,
        "team" => [4371, 3834, 7349, 3291, 1116],
        "guts" => 79
      },
      "10824" => {
        "name" => "忠勝的蜻蛉切",
        "defense" => 29295,
        "resign" => true,
        "team" => [8404, 3834, 7349, 3291, 1116],
        "guts" => 76
      },
      "10825" => {
        "name" => "奇稻田公主",
        "defense" => 54124,
        "resign" => false,
        "team" => [8392, 2718, 8404, 3834, 7349],
        "guts" => 134
      },
      "10826" => {
        "name" => "建御雷神",
        "defense" => 80000,
        "resign" => false,
        "team" => [8392, 6597, 2718, 8404, 3834],
        "guts" => 157
      },
      "10827" => {
        "name" => "多管火箭發射系統",
        "defense" => 115000,
        "resign" => false,
        "team" => [2718, 8404, 3834, 3833, 3774],
        "guts" => 153
      },
      "10828" => {
        "name" => "米蘭達",
        "defense" => 138000,
        "resign" => false,
        "team" => [2718, 8404, 3834, 3833, 3774],
        "guts" => 153
      }
    }
    
    @battle_rule = {
      "110" => {
        "name" => "八岐大蛇",
        "defense" => 3200,
        "team" => [7349, 1116, 3291, 10092, 10057],
        "guts" => 30
      },
      "120" => {
        "name" => "八岐大蛇",
        "defense" => 4716,
        "team" => [7349, 1116, 3291, 10092, 10057],
        "guts" => 30
      },
      "130" => {
        "name" => "八岐大蛇",
        "defense" => 7748,
        "team" => [7349, 1116, 3291, 10092, 10057],
        "guts" => 30
      },
      "140" => {
        "name" => "八岐大蛇",
        "defense" => 13812,
        "team" => [3832, 7349, 1161, 3291, 10092],
        "guts" => 41
      },
      "150" => {
        "name" => "八岐大蛇",
        "defense" => 32000,
        "team" => [1365, 4371, 8400, 10123, 10089],
        "guts" => 45
      },
      "160" => {
        "name" => "衛星加農炮",
        "defense" => 4800,
        "team" => [7349, 1116, 3291, 10092, 10057],
        "guts" => 30
      },
      "170" => {
        "name" => "衛星加農炮",
        "defense" => 7074,
        "team" => [7349, 1116, 3291, 10092, 10057],
        "guts" => 30
      },
      "180" => {
        "name" => "衛星加農炮",
        "defense" => 11622,
        "team" => [199, 7349, 1161, 3291, 10092],
        "guts" => 36
      },
      "190" => {
        "name" => "衛星加農炮",
        "defense" => 20718
      },
      "200" => {
        "name" => "衛星加農炮",
        "defense" => 48000
      }
    }
  end
  
  # 更新楼层状态
  # 返回是否更新成功
  def update_stage_info
    response = @core.request("/app.php?evid=#{@evid}&_c=extra_quest_event_adventure&action=stage", {}, "获取状态...")
    
    body = response[:raw]
    html = response[:html]
    
    case html.title
    when "extra_quest_event_adventure stage - ayakashi"
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
      @core.pause("按任意键开打")
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
