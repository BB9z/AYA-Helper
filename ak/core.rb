require 'rubygems'
require 'yaml'
require 'highline/import'
require_relative '../lib/log.rb'

require_relative 'event_tower.rb'
require_relative 'event_pvp.rb'
require_relative 'event.rb'
require_relative 'farm.rb'
require_relative 'friends.rb'
require_relative 'guild.rb'
require_relative 'menu.rb'
require_relative 'merge_rule.rb'
require_relative 'merge.rb'
require_relative 'monster.rb'
require_relative 'page_router.rb'
require_relative 'request.rb'
require_relative 'team.rb'
require_relative 'user.rb'

class AK
  attr_accessor :user_default
  attr_accessor :cannot_merge_any_more

  def initialize(config = {})
    Encoding.default_external = Encoding::UTF_8
    
    @user_default = YAML.load_file("config.yml")
    @user_default ||= {}
    config = @user_default.merge(config)
    @cookie = config["cookie"]
    @guild_id = config["guild_id"]
    @sound_alert = config["sound_alert"]
    sound_alert("Welcome")
    raise unless @cookie
    
    @userAgent = "Mozilla/5.0 (iPad; CPU OS 6_1 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Mobile/10B141 ZyngaBundleIdentifier/com.zynga.zjayakashi.0 ZyngaBundleVersion/1.9.0"
    
    @cannot_merge_any_more = true
    
    user_info = @user_default[:user]
    @user = User.new(self, user_info)
    @user.fetch_info if !user_info || user_info["id"].nil?
  end

  def run
    case ARGV.first
    when "restart"
      log "重启中..."
      sleep(1)
      
    end
    
    begin
      while menu_home
      end
    rescue Interrupt => e
      puts "> 用户终止\n#{e.backtrace.first}"
    end
  end
  
  def restart
    exec($0, "restart")
  end
  
  def save_user_default
    begin
      File.open("config.yml", 'w+') {|f|
        f.write(@user_default.to_yaml)
      }
      return true
      
    rescue Exception => e
      log "设置没有成功保存，错误信息：\n  #{e.inspect}"
      return false
    end
  end
  
  def sound_alert(string)
    sound_alert(string) if @sound_alert
  end
end
