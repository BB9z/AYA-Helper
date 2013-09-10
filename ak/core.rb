require 'rubygems'
require 'yaml'
require 'highline/import'
require_relative '../lib/log.rb'

require_relative 'event_tower.rb'
require_relative 'event.rb'
require_relative 'farm.rb'
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
  attr_reader :http
  attr_accessor :user_default

  def initialize(config = {})
    @user_default = YAML.load_file("config.yml")
    @user_default ||= {}
    config = @user_default.merge(config)
    @cookie = config["cookie"]
    @guild_id = config["guild_id"]
    @sound_alert = config["sound_alert"]
    sound_alert("Welcome")
    raise unless @cookie
    
    uri = URI.parse("http://zc2.ayakashi.zynga.com")
  
    @userAgent = "Mozilla/5.0 (iPad; CPU OS 6_1 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Mobile/10B141 ZyngaBundleIdentifier/com.zynga.zjayakashi.0 ZyngaBundleVersion/1.9.0"
  
    @http = Net::HTTP.new(uri.host, uri.port)
    # @http.set_debug_output $stderr
    @http.read_timeout = 4
    @cannot_merge_any_more = false
    
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
  
  def pause(promote = nil)
    promote ||= "按任意键继续..."
    ask(promote) {|q|
      q.echo = false
      q.character = true
    }
  end
  
  def sound_alert(string)
    speak(string) if @sound_alert
  end
  
  def farm(island_id = 3, area_id = 8, stage_id = 11)
    fm = Farm.new(self)
    fm.farm(island_id, area_id, stage_id)
  end
  
  def auto_farm(time_interval = 60, count = 0)
    time_interval ||= 60
    
    fm = Farm.new(self)
    fm.auto_farm(time_interval, count)
  end
  
end
