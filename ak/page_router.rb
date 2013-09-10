#

class AK
  
  
  class NotDefinedPage < StandardError  
  end
  
  # 传入请求 url 和 内容 文本
  # 返回页面对应的可操作集合
  # 元素是 { uri => "www", note => "测试" }
  def page_router(content = nil)
    return [] if content.nil?
    
    
  end
  
end
