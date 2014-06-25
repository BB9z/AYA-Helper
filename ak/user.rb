
class AK
  attr_reader :user
  
class User
  attr_accessor :info
  
  def initialize(master, info = {})
    raise if !master
    
    @core = master
    @info = info
    @info ||= {}
    
    @info["time_to_offense_guts_max"] = nil
    @info["time_to_energy_max"] = nil
  end
  
  def fetch_info
    request = @core.request("/app.php?_c=entry&action=mypage", {}, "获取用户信息...")
    json_string = request[:raw][/user = ({.*})/, 1]
    json = JSON.parse(json_string)

    @info.merge!(json)
    @info[:last_update_time] = Time.now

    # p @info
    save_info
  end
  
  def display_info
    puts @info["name"]
    puts "LV: #{@info["level"]} EXP: #{info["exp_percentage"]}%(#{@info["exp_for_next_level"]-@info["exp"]})"
    puts "攻灵: #{@info["offense_guts"]}/#{@info["offense_guts_max"]} 防御灵: #{@info["defense_guts"]}/#{@info["defense_guts_max"]} 体力: #{@info["energy"]}/#{@info["energy_max"]}"
    puts "未分配点数: #{@info["ability_point"]}" if @info["ability_point"] != 0
    puts "胜: #{@info["total_won"]} 败: #{@info["total_lost"]} 胜率: #{(Float(@info["total_won"])/(@info["total_lost"]+@info["total_won"])*100).round(1)}% 解放数: #{@info["completed_parts_count"]}"
    puts "金: #{@info["cash"]} 白银: #{@info["coin"]} 召唤点数: #{@info["gacha_point"]}"
    puts "好友: #{@info["neighbors_count"]}/#{@info["neighbors_limit_count"]}"
  end
  
  def save_info
    @core.user_default[:user] = @info
    @core.save_user_default
  end
  
  def refresh_user
    @core.farm
  end
  
  # 传入整个 stage json
  def update_with_stage_info(info)
    return if info.nil? || info.empty?
    
    org_offense_guts = @info["offense_guts"]
    @info.merge!(info["user"])
    @info[:last_update_time] = Time.now
    
    max_time = @info["time_to_offense_guts_max"];
    offense_guts = @info["offense_guts_max"];
    
    if max_time > 0
      max = @info["offense_guts_max"]
      spend = (max_time - Time.now.to_i)/60
      offense_guts = max - spend
      @info["offense_guts"] = offense_guts
    end
    
    if offense_guts > 2000
      p "offense_guts_max = #{@info["offense_guts_max"]}"
      p "time_to_offense_guts_max = #{@info["time_to_offense_guts_max"]}"
      p "now = #{Time.now.to_i}"
      p "offense_guts = #{offense_guts}"
      p "org_offense_guts = #{org_offense_guts}"
      raise
    end
  end
  
  def offense_guts
    @info["offense_guts"]
  end
  
end # class User
end # class AK