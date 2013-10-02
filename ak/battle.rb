
class AK
  
  def battle_exec(target_user_id, target_parts_id = 0)
    raise(ArgumentError, "目标ID未提供或格式不正确") if target_user_id.is_a?(Integer)
    
    response = request("/app.php?_c=battle&action=exec_battle&target_user_id=#{target_user_id}&target_parts_id=#{target_parts_id}&from_battle_tab=&ref=")
    result_json_string = response[:raw][/var result = ({.*})/, 1]
    p result_json_string
    
    result_json = JSON.parse(result_json_string)
    p result_json
    battle_report(result_json) if result_json
    
  end
  
  # 战斗结果报告
  def battle_report(result_json)
    opponent_user = result_json["opponent"]["user"]    
    print "对手：#{opponent_user["name"]} 最终防御：#{opponent_user["resultTotalDefensePoints"]}\n"
    
    opponent_monsters = result_json["opponent"]["monsters"]
    print "卡组："
  end
  
end