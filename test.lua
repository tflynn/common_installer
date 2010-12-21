#!/usr/bin/env lua

COMPONENT_OPTIONS =  {
  
  baseSystem = {  name = 'Basic System', },
  
}

print(COMPONENT_OPTIONS.baseSystem.name)
notThere = COMPONENT_OPTIONS.baseSystem['notthere']
if notThere == nil then
  print("notThere isn't there")
else
  print("notThere is there")
end



