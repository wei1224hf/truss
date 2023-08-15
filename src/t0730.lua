
while true do
  Sleep(10)
  SetDO("DO_LIGHT",1)
  Stop()
  SetDO("DO_LIGHT",0)
  Stop()
  SetDO("DO_LIGHT",1)
  Stop()
  SetDO("DO_LIGHT",0)
  Stop()
end