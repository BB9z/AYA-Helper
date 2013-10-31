# 

class AK
  
class Farm
  
  attr_accessor :one_way_mode
  attr_accessor :farm_interval
  
  # <= 0 永久
  attr_accessor :farm_count
  
  attr_reader :should_continue_run
  attr_reader :is_running
  
  def initialize(master)
    raise if !master
    
    @core = master
    @one_way_mode = false
    @farm_interval = 60
    @farm_count = -1
    
  end
  
  def run
    return if @is_running
    
    @is_running = true
    @should_continue_run = true
    @farm_count = -1 if @farm_count.nil? || @farm_count <= 0
    
    begin
      while @should_continue_run
        farm
    
        break if @farm_count == 0
        @farm_count -= 1 if @farm_count > 0
    
        sleep(@farm_interval)
      end
    rescue Interrupt
      log "停止"
    end
    
    @is_running = false
  end
  
  def farm(island_id = 3, area_id = 8, stage_id = 11)
    json = @core.request("/app.php?_c=adventure&action=proceed&island_id=#{island_id}&area_id=#{area_id}&stage_id=#{stage_id}", {
      "Accept" => 'application/json'
    }, nil, @one_way_mode)[:json]
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
        @should_continue_run = false if @one_way_mode
    
      when "GET_MONSTER"      
        monster = event["values"]["settings"]["monster"]
        monster_name = monster["name"]
      
        if monster["wasSold"]
          log "卖出#{monster_name}"
          if !@core.cannot_merge_any_more
              @core.cannot_merge_any_more = true if @core.merge() == 0
          end
        else
          log "获得#{monster_name}"
          @core.cannot_merge_any_more = false
        end
    
      when "ENCOUNTER_OTHER_PLAYER"
        log "其他玩家"
    
      when nil
        log "事件nil"
    
      when "LEVEL_UP"
        log "升级了～"
        speak("LEVEL UP")
    
      else
        log "未处理的类别 #{event}"
        speak("Unknow type")
        @should_continue_run = false if @one_way_mode
      end
    }
  end
end # class Farm
end # class AK
