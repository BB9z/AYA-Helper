# 

class AK
  
class Farm
  
  def initialize(master)
    raise if !master
    
    @core = master
  end
  
  # count ，为 0 或不提供默认永久
  def auto_farm(time_interval = 60, count = 0)
    count = -1 if count.nil? || count <= 0
    
    begin
      while true
        farm
    
        break if count == 0
        count -= 1 if count > 0
    
        sleep(time_interval)
      end
    rescue Interrupt
      log "停止"
    end
  end
  
  def farm(island_id = 3, area_id = 8, stage_id = 11)
    json = @core.request("/app.php?_c=adventure&action=proceed&island_id=#{island_id}&area_id=#{area_id}&stage_id=#{stage_id}", {
      "Accept" => 'application/json'
    })[:json]
    @core.user.update_with_stage_info(json)
    
    events = json["events"]
    if events.empty?
      log "无事件发生"
      return
    end
  
    events.each {|event|
      case event["type"]
      when "NO_ENOUGH_ENERGY"
        log "体力消耗光了"
        speak("NO ENOUGH ENERGY")
    
      when "GET_MONSTER"      
        monster = event["values"]["settings"]["monster"]
        monster_name = monster["name"]
      
        if monster["wasSold"]
          log "卖出#{monster_name}"
          if !@cannot_merge_any_more
              @cannot_merge_any_more = true if @core.merge() == 0
          end
        else
          log "获得#{monster_name}"
          @cannot_merge_any_more = false
        end
    
      when "ENCOUNTER_OTHER_PLAYER"
        log "其他玩家"
    
      when nil
        log "事件nil"
    
      when "LEVEL_UP"
        log "升级了～"
        speak("LEVEL UP")
    
      else
        log "未处理的类别 #{event["type"]}"
        speak("Unknow type")
      end
    }
  end
end # class Farm
end # class AK
