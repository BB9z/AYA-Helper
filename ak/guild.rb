# 工会

class AK
  
  # 打印公会讨论版
  def talk(count)
    count ||= 7

    response = request("/app.php?_c=guild&action=getBullets&guildId=#{@guild_id}", {
      "Referer" => "http://zc2.ayakashi.zynga.com/app.php?_c=entry&action=mypage"
    }, "请求留言板内容...")

    html = response[:html]
    html.search('//ul[@id="neighbors-list"]/li').each {|tag|
      if count > 0
        count -= 1
      else
        break
      end
  
      name = tag.css('.name').first.content
      contentRawString = tag.css('.status').first.content
      m = /\n(\s*)(?<A>.*)\n(\s*)(?<B>.*)\n/.match(contentRawString)
      print name + ":\n  " + m['A'] + " (" + m['B'] + ")\n\n"
    }
  
  end
  
end
