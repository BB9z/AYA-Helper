
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