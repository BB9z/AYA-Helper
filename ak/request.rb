require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'

class AK
  attr_accessor :cookie
  attr_accessor :userAgent
  attr_accessor :http
  
  class RequestError < StandardError  
  end
  
  class HTTPInternalServerError < StandardError  
  end
  
  def http
    if !@http
      uri = URI.parse("http://zc2.ayakashi.zynga.com")
      @http = Net::HTTP.new(uri.host, uri.port)
      # @http.set_debug_output $stderr
      @http.read_timeout = 4
    end
    
    @http
  end
  
  def http=(new_http)
    if @http
      @http.finish if @http.started?
    end
    @http = new_http
  end
  
  # 网络请求
  # 返回 { json? => true/false, json => foo, html => bar, url => "www" }
  def request(uri, header = {}, request_start_promte = nil, one_way = false)
    retry_count = 3
    header ||= {}
    
    begin
      if retry_count == 0
        speak("Network down")
        raise RequestError, "无法建立连接"
      end
      
      log "#{request_start_promte}" if request_start_promte
      
      response = self.http.request_get(uri, {
        "Accept-Language" => "zh-cn",
        "Cookie" => @cookie,
        "User-Agent" => @userAgent
      }.merge(header))
      
      # p response
      # p response.body
      
      raise HTTPInternalServerError if response.is_a? Net::HTTPInternalServerError
      
    rescue SocketError, Errno::ENETUNREACH, Errno::EADDRNOTAVAIL, Errno::EHOSTUNREACH
      log "网络错误，重试"
      sleep(60)
      retry_count -= 1
      self.http = nil
  
    rescue Errno::ETIMEDOUT, Net::ReadTimeout
      log "连接超时，重试"
      sleep(10)
      retry_count -= 1
      retry
      
    rescue Errno::ENOTCONN, Zlib::BufError
      sleep(2)
      self.http = nil
      retry
      
    rescue HTTPInternalServerError
      sleep(60)
      self.http = nil
      p response
      retry
      
    end # try
    
    self.http.finish if self.http.started?
    
    if response.is_a? Net::HTTPFound
      uri = response["location"]
      if one_way
        return
      else
        log "重定向到 #{uri}"
        return request(uri)
      end
    end
    
    log "请求状态不正常 #{uri} #{response}" if !response.is_a? Net::HTTPOK
    
    content = response.body.force_encoding('UTF-8')
    retuen_value = {
      :json? => false,
      :json => nil,
      :html => nil,
      :raw => content,
      :url => uri
    }
    
    if content[/<!DOCTYPE html>/]
      html = Nokogiri::HTML.parse content
      return retuen_value.merge({ :html => html })
    end
    
    begin
      json = JSON.parse content
      return retuen_value.merge({ :json? => true, :json => json })
    rescue JSON::ParserError
      log "#{uri} 的返回内容既不是 JSON 也不是 HTML"
      return retuen_value
    end
  end # request
  
end