
class AK
class EventPVP
  
  def initialize(master)
    raise if !master
    
    @core = master
    
  end
  
  def run
    begin
      # while true
        
      # end
    rescue Interrupt
      log "停止"
    end
  end
  
end # class EventPVP
end # class AK