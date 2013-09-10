
class AK
class Event
  
  def initialize(master, &block)
    raise if !master
    
    if block_given?
        instance_eval(&block)
    end
  end
  
end # class Event
end # class AK
