# 合并规则
# 

class AK

class MergeRule
  attr_accessor(:rules)
  
  def initialize(&block)
    @rules = [];
    
    if block_given?
        instance_eval(&block)
    end
  end
  
  def size
    @rules.size
  end
  
  def define(masterID, meterialID, note = "", bulk = false)
    @rules.push({ 
      :note => note,
      :target => masterID,
      :meterial => meterialID,
      :bulk => bulk,
    })
  end
  
  def define3(meterialID, note = "")
    @rules.push({ 
      :note => note,
      :target => meterialID,
      :meterial => meterialID,
      :bulk => true
    })
  end
  
  def printRules
    print "Rules = [\n"
    @rules.each {|rule|
      print "  #{rule[:note]} #{rule[:target]} #{rule[:meterials]} #{rule[:bulk]}\n"
    }
    print "]\n"
  end
end
end # class AK
