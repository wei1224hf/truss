local cjson = require "cjson"
local pam_json = cjson.new()

local n_correctPartition=1500
local n_grabFromCache=300
local n_grabFromConveyor=700
local n_grabFromIn=100
local n_grabToCache=200
local n_grabToCart=400
local n_grabToOut=800
local n_grabToRGV=900
local n_placePartition=1100

local n_safeHeight=-1297
local n_suckPartition=1000
local n_toWait=500
local n_toWaitYZ=1600
local n_visionOnConveyor=600
local n_visionOnIn=1200
local n_visionOnOut=1300
local n_visionOnPartition=1400
local n_function=1500
local n_getConfig=1700

local n_cacheOffsetX=300
local n_cacheOffsetY=330
local n_cartOffsetX=310
local n_cartOffsetY=270

local var = 0
local bar = 0

local out_poses = {{},{},{{},{},{},{},{},{},{},{},{},{},{},{}},{{},{},{},{},{},{},{},{},{},{},{},{}},{{},{},{},{},{},{},{},{},{},{},{},{}},{{},{},{},{},{},{},{},{},{},{},{},{}}}

for var = 3,6,1 do
  local p12s = out_poses[var]
  for bar = 1,12,1 do
    p12s[bar] = CopyJointTarget( Knext )
  end
end 

function angleBetweenPoints(Ax, Ay, Bx, By)
    local dx = Bx - Ax
    local dy = By - Ay
    return math.deg(math.atan2(dy, dx))
end

function openGrab()
  SetDO("DO_OPEN",1)
  SetDO("DO_CLOSE",0)
  WaitDI("DI_CLOSE",0)
  Sleep(1000)
  if GetDI("DI_OPEN") == 0 then
    S_Error.str = "Unable to open the grab, check the air pressure"
    N_Error.num = N_function.num + 2
    Stop()
  end
  return 1
end

function closeGrab()
  if GetDI("DI_UNDER") == 0 then
    S_Error.str = "there is nothing under the grab"
    N_Error.num = N_function.num + 5
    Stop()
  end
  
  SetDO("DO_OPEN",0)
  SetDO("DO_CLOSE",1)
  WaitDI("DI_OPEN",0)
  Sleep(1000)
  if GetDI("DI_CLOSE") == 0 then
    S_Error.str = "Unable to close the grab, check the air pressure"
    N_Error.num = N_function.num + 6
    Stop()
  end
  return 1
end

function suck()
  if GetDI("DI_UNDER") == 0 then
    S_Error.str = "nothing under"
    N_Error.num = N_function.num + 7
    Stop()
  end
  
  if WaitDI("DI_AIR_LEFT",1,3000) == true then
    S_Error.str = "insufficient left air pressure from vacuum "
    N_Error.num = N_function.num + 8
    Stop()
  end
  if WaitDI("DI_AIR_RIGHT",1,3000) == true then
    S_Error.str = "insufficient right air pressure from vacuum"
    N_Error.num = N_function.num + 9
    Stop()
  end
  SetDO("DO_SUCK",1)
  if WaitDI("DI_AIR_LEFT",0,3000) == true then
    S_Error.str = "nothing sucked on left"
    N_Error.num = N_function.num + 10
    Stop()
  end
  if WaitDI("DI_AIR_RIGHT",0,3000) == true then
    S_Error.str = "nothing sucked on right"
    N_Error.num = N_function.num + 11
    Stop()
  end
  
end

function stopSuck()

  SetDO("DO_SUCK",0)
  if WaitDI("DI_AIR_LEFT",1,3000) == true then
    S_Error.str = "--"
    N_Error.num = N_function.num + 15
    Stop()
  end
  if WaitDI("DI_AIR_RIGHT",1,3000) == true then
    S_Error.str = "--"
    N_Error.num = N_function.num + 16
    Stop()
  end
  
end

function grabFromCache()
  if GetDI("DI_UNDER") == 1 then
    S_Error.str = "something under the grab"
    N_Error.num = n_grabFromCache + 1
    Stop()
  end
  
  if (N_CacheX.num < 1) or (N_CacheX.num > 9) then
    S_Error.str = "N_CacheX is wrong, should between 1 and 9"
    N_Error.num =  n_grabFromCache + 2
    Stop()
  end
  
  if (N_CacheY.num < 1) or (N_CacheY.num > 2) then
    S_Error.str = "N_CacheX is wrong, should between 1 and 2"
    N_Error.num =  n_grabFromCache + 3
    Stop()
  end

  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  local offset_x = (N_CacheX.num - 1) * n_cacheOffsetX
  local offset_y = (N_CacheY.num - 1) * n_cacheOffsetY
  Knext = CopyJointTarget(KcacheCorner)
  Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
  Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y
  Knext.robax.rax_3 = n_safeHeight
  
  TPWrite("X:"..Knext.robax.rax_1.."/Y:"..Knext.robax.rax_2.."/Z:"..Knext.robax.rax_3)

  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(1000)
  openGrab()
  Knext.robax.rax_3 = KcacheCorner.robax.rax_3 + 166 - N_productHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(1000)
  closeGrab()
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
 
  N_Action.num = 0 - n_grabFromCache
end

function grabToCache()
  if GetDI("DI_UNDER") == 0 then
    S_Error.str = "Unable to grab toward cache, nothing under the grab"
    N_Error.num = n_grabToCache + 1
    Stop()
  end
  
  if (N_CacheX.num < 1) or (N_CacheX.num > 9) then
    S_Error.str = "N_CacheX is wrong, should between 1 and 9"
    N_Error.num =  n_grabToCache + 2
    Stop()
  end
  
  if (N_CacheY.num < 1) or (N_CacheY.num > 2) then
    S_Error.str = "N_CacheX is wrong, should between 1 and 2"
    N_Error.num =  n_grabToCache + 3
    Stop()
  end

  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
  local offset_x = (N_CacheX.num - 1) * n_cacheOffsetX
  local offset_y = (N_CacheY.num - 1) * n_cacheOffsetY
  Knext = CopyJointTarget(KcacheCorner)
  Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
  Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y
  Knext.robax.rax_3 = n_safeHeight
  
  TPWrite("X:"..Knext.robax.rax_1.."/Y:"..Knext.robax.rax_2.."/Z:"..Knext.robax.rax_3)

  MoveAbsJ(Knext,v300,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = KcacheCorner.robax.rax_3
  if N_productHeight.num == 332 then
    Knext.robax.rax_3 = KcartCorner.robax.rax_3 - 166
  end
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(2000)
  openGrab()
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
  N_CacheX.num = N_CacheX.num + 1
  if N_CacheX.num > 9 then
    N_CacheY.num = N_CacheY.num + 1
    if N_CacheY.num > 2 then
      S_Error.str = "cache is full"
      N_Error.num =  n_grabToCache + 4
    end
  end
  N_Action.num = 0 - n_grabToCache
end

function grabToCart()
  if GetDI("DI_UNDER") == 0 then
    S_Error.str = "nothing under the grab"
    N_Error.num = n_grabToCart + 1
    Stop()
  end
  
  if (N_CartX.num < 1) or (N_CartX.num > 3) then
    S_Error.str = "N_CartX is wrong, should between 1 and 3"
    N_Error.num = n_grabToCart + 2
    Stop()
  end
  
  if (N_CartY.num < 1) or (N_CartY.num > 2) then
    S_Error.str = "N_CartY is wrong, should between 1 and 2"
    N_Error.num = n_grabToCart + 3
    Stop()
  end
  
  if (N_CartZ.num < 1) or (N_CartZ.num > 2) then
    S_Error.str = "N_CartZ is wrong, should between 1 and 2"
    N_Error.num = n_grabToCart + 4
    Stop()
  end
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
  local offset_x = (N_CartX.num - 1) * n_cartOffsetX
  local offset_y = (N_CartY.num - 1) * n_cartOffsetY
  Knext = CopyJointTarget(KcartCorner)
  Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
  Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y
  
  Knext.robax.rax_3 = n_safeHeight  
  TPWrite("X:"..Knext.robax.rax_1.."/Y:"..Knext.robax.rax_2.."/Z:"..Knext.robax.rax_3)  
  MoveAbsJ(Knext,v400,fine,tool0,wobj0,load0)
  
  Knext.robax.rax_3 = KcartCorner.robax.rax_3 + 166 - N_productHeight.num * N_CartZ.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(1000)
  openGrab()
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
  N_Action.num = 0 - n_grabToCart
end

function grabToRGV()
  if GetDI("DI_UNDER") == 0 then
    S_Error.str = "nothing under the grab"
    N_Error.num = n_grabToRGV + 1
    Stop()
  end
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  Sleep(1000)

  if (N_RGV.num < 1) or (N_RGV.num > 5) then
    S_Error.str = "N_RGV is wrong, should between 1 and 5"
    N_Error.num = n_grabToRGV + 2
    Stop()
  end  
  
  local _RGV_PS = {KRGV1,KRGV2,KRGV3,KRGV4,KRGV5}
  local _RGV_P = _RGV_PS[N_RGV.num]

  Knext = CopyJointTarget(_RGV_P)
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  Sleep(1000)
  Knext.robax.rax_3 = _RGV_P.robax.rax_3 + 166 - N_RGVZ.num * N_productHeight.num
  TPWrite("z:"..Knext.robax.rax_3)
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(1000)
  openGrab()
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
  N_RGV.num = N_RGV.num + 1
  N_Action.num = 0 - n_grabToRGV
end

function visionOnConveyor()
  if GetDI("DI_UNDER") == 1 then
    S_Error.str = "something under the grab"
    N_Error.num = n_visionOnConveyor + 1
    Stop()
  end

  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
  Knext = CopyJointTarget(Kconveyor_V)
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v300,fine,tool0,wobj0,load0)
  Sleep(300)  
  N_V.num = 0
  SetDO("DO_V1",0)
  SetDO("DO_V2",0)
  SetDO("DO_V3",0)
  SetDO("DO_V4",0)
  N_V_step.num = 1
  SetDO("DO_LIGHT",1)
  
  Knext.robax.rax_3 = Kconveyor_V.robax.rax_3 + 166 -332
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  Sleep(500)
  Knext.robax.rax_3 = Kconveyor_V.robax.rax_3 + 166 - N_productHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)  
  Sleep(2000)
  N_V.num = 1
  WaitDO("DO_V1",1,30000,false)
  N_V.num = 0
  
  Kconveyor.robax.rax_1 =  N_VX.num
  Kconveyor.robax.rax_2 =  N_VY.num

  N_Action.num = 0 - n_visionOnConveyor
  
end

function grabFromConveyor()
  SetDO("DO_LIGHT",0)
  SetDO("DO_UP",1)
  
  local _current = GetJointTarget("Xyzw")
  local _Kconveyor_V = CopyJointTarget(Kconveyor_V)
  _Kconveyor_V.robax.rax_3 = _Kconveyor_V.robax.rax_3  + 166 - N_productHeight.num
  local distance = getDistanceByK(_Kconveyor_V,_current)
  
  if distance > 10 then
    S_Error.str = "current position is not suitable"
    N_Error.num = n_grabFromConveyor + 1
    --Stop()
  end
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = _Kconveyor_V.robax.rax_3 - 0
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  Knext = CopyJointTarget(Kconveyor)
  Knext.robax.rax_3 = _Kconveyor_V.robax.rax_3 - 0
  Knext.robax.rax_4 = N_conveyorR.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  openGrab()
  Knext.robax.rax_3 = Kconveyor.robax.rax_3 + 166 - N_productHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  closeGrab()
  
  Knext.robax.rax_3 = Knext.robax.rax_3 - 166
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = n_safeHeight
  Knext.robax.rax_4 = -90
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  N_Action.num = 0 - n_grabFromConveyor
end

function grabToOut()

  SetDO("DO_LIGHT",0)
  if GetDI("DI_UNDER") == 0 then
    S_Error.str = "nothing under the grab"
    N_Error.num = n_grabToOut + 1
    Stop()
  end
  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    SetDO("DO_UP",1)  
    Sleep(3000)
  end
  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    S_Error.str = "the sucker should be up, not be down"
    N_Error.num = n_grabToOut + 2
    Stop()
  end

  if (N_Tray.num < 3) or (N_Tray.num > 6) then
    S_Error.str = "N_Tray num is wrong, should between 3 and 6"
    N_Error.num =  n_grabToOut + 3
    Stop()
  end  

  local _z_ = {0,0,N_Out3Z,N_Out4Z,N_Out5Z,N_Out6Z}
  local _i_ = {0,0,N_Out3I,N_Out4I,N_Out5I,N_Out6I}

  local _z = _z_[N_Tray.num]
  local _i = _i_[N_Tray.num]
  
  if (_i.num < 1 or _i.num > 12) then
    S_Error.str = "index num is wrong, should between 1 and 12"
    N_Error.num = n_grabToOut + 3
    Stop()
  end  

  Knext = GetJointTarget ("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)

  local poses = out_poses[N_Tray.num]
  local _p_1_12 = {poses[8],poses[5],poses[2],poses[3],poses[6],poses[9],poses[12],poses[11],poses[10],poses[7],poses[4],poses[1]}
  Knext = _p_1_12[_i.num]

  Knext.robax.rax_3 = n_safeHeight
  
  if (_i.num ==1 ) then
    Knext.robax.rax_4 = -90
  elseif (_i.num ==2 ) then
    Knext.robax.rax_4 = 0
  elseif (_i.num ==3 ) then
    Knext.robax.rax_4 = 90
  elseif (_i.num ==4 ) then
    Knext.robax.rax_4 = -178    
  elseif ((_i.num ==5 ) or (_i.num ==6 )) then
    Knext.robax.rax_4 = -178
  elseif (_i.num ==7 ) then
    Knext.robax.rax_4 = -178
  elseif (_i.num ==8 ) then
    Knext.robax.rax_4 = -90
  elseif (_i.num ==9) then
    Knext.robax.rax_4 = 0
  elseif ((_i.num ==10 ) or (_i.num ==11 )) then
    Knext.robax.rax_4 = 0
  elseif (_i.num ==12) then
    Knext.robax.rax_4 = 0 
  end  
  TPWrite("x:"..Knext.robax.rax_1.."/y:"..Knext.robax.rax_2.."/i:".._i.num)  
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = K6RT.robax.rax_3 + 166 - _z.num * N_productHeight.num
  TPWrite("z:"..Knext.robax.rax_3)  
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(1000)
  openGrab()
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)

  _i.num = _i.num + 1

  N_Action.num = 0 - n_grabToOut
end

function placePartition()
  if GetDI("DI_UNDER") == 0 then
    S_Error.str = "Partition dropped "
    N_Error.num = n_placePartition + 1
    Stop()
  end
  
  if (N_Tray.num < 3) or (N_Tray.num > 6) then
    S_Error.str = "N_Out num is wrong, should between 3 and 6"
    N_Error.num = n_placePartition + 2
    Stop()
  end  

  local _z_ = {0,0,N_Out3Z,N_Out4Z,N_Out5Z,N_Out6Z}
  local _z = _z_[N_Tray.num]
  
  if (_z.num < 1) or (_z.num > 6) then
    S_Error.str = "Z num should between 1 and 6"
    N_Error.num = n_placePartition + 2
    Stop()
  end  
  
  Knext = GetJointTarget ("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)  
  
  local poses12 = out_poses[N_Tray.num]
  local center_x = (poses12[1].robax.rax_1 + poses12[12].robax.rax_1)/2
  local center_y = (poses12[1].robax.rax_2 + poses12[12].robax.rax_2)/2
  
  Knext = CopyJointTarget( KP3 )
  Knext.robax.rax_1 = center_x - 98.374
  Knext.robax.rax_2 = center_y - 2.183
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v400,fine,tool0,wobj0,load0) 
  if GetDI("DI_UNDER") == 0 then
    S_Error.str = "Partition dropped while arrriving"
    N_Error.num = n_placePartition + 1
    Stop()
  end
  
  Knext.robax.rax_3 = KP3.robax.rax_3 + 166 - _z.num * N_productHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)  
  stopSuck()
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)  
  SetDO("DO_UP",1)
  
  N_Action.num = 0 - n_placePartition
end

function suckPartition()
  if GetDI("DI_UNDER") == 1 then
    S_Error.str = "something under the grab"
    N_Error.num = n_suckPartition + 1
    Stop()
  end 
  
  SetDO("DO_LIGHT",0)
  SetDO("DO_UP",1)
  SetDO("DO_SUCK",0)
  
  Knext = GetJointTarget ("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v400,fine,tool0,wobj0,load0)  
  
  if WaitDI("DI_AIR_UP",1,5000) == true then
    S_Error.str = "Abnormal cylinder lifting, no up signal detected "
    N_Error.num = n_suckPartition + 2
    Stop()
  end
  if WaitDI("DI_AIR_DOWN",0,5000) == true then
    S_Error.str = "Abnormal cylinder lifting, the down signal is still there "
    N_Error.num = n_suckPartition + 3
    Stop()
  end

  Knext = CopyJointTarget( KsuckOffset_U )
  Knext.robax.rax_3 = n_safeHeight
  TPWrite("x:"..Knext.robax.rax_1.."/y:"..Knext.robax.rax_2)
  MoveAbsJ(Knext,v400,fine,tool0,wobj0,load0)  
  SetDO("DO_UP",0)
  MoveAbsJ(KsuckOffset_U,v200,fine,tool0,wobj0,load0)
  if GetDI("DI_UNDER") == 1 then
    S_Error.str = "there is a partition stuck on the shelf, remove it"
    N_Error.num = n_suckPartition + 6
    Stop()
  end  
  MoveAbsJ(Ksuck_U,v100,fine,tool0,wobj0,load0)
  if WaitDI("DI_AIR_UP",0,3000) == true then
    S_Error.str = "cylidner shoud be down, but the up signal is still there"
    N_Error.num = n_suckPartition + 2
    Stop()
  end
  if WaitDI("DI_AIR_DOWN",1,3000) == true then
    S_Error.str = "no cylidner down signal detected "
    N_Error.num = n_suckPartition + 3
    Stop()
  end
  
  local ret = SearchL("DI_UNDER",1,Psuck_D,Psuck,v100,tool0,wobj0)
  if ret == true then 
    local littleLow = GetJointTarget("Xyzw")
    littleLow.robax.rax_3 = littleLow.robax.rax_3 + 190
    MoveAbsJ(littleLow,v200,fine,tool0,wobj0,load0)
    Sleep(500)
    suck()
  else
    S_Error.str = "Partition not found "
    N_Error.num = n_suckPartition + 1
    Stop()
  end
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
  if GetDI("DI_UNDER") == 0 then
    S_Error.str = "Partition dropped "
    N_Error.num = n_suckPartition + 1
    Stop()
  end
  
  N_Action.num = 0 - n_suckPartition

end


function toWait()
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  TPWrite("To safe height")
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  SetDO("DO_LIGHT",0)
  Knext.robax.rax_2 = Kwait.robax.rax_2
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  MoveAbsJ(Kwait,v200,fine,tool0,wobj0,load0)
  N_Action.num = 0 - n_toWait
end

function toWaitYZ()
  SetDO("DO_LIGHT",0)
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  Knext.robax.rax_2 = Kwait.robax.rax_2
  Knext.robax.rax_4 = -90
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  N_Action.num = 0 - n_toWaitYZ
end

function grabFromIn()
  if GetDI("DI_UNDER") == 1 then
    S_Error.str = "Unable to grab, something under the grab"
    N_Error.num = n_grabFromIn + 1
    Stop()
  end
  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    SetDO("DO_UP",1)  
    Sleep(3000)
  end
  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    S_Error.str = "the sucker should be up, not be down"
    N_Error.num = n_grabFromIn + 2
    Stop()
  end

  if (N_Tray.num < 1) or (N_Tray.num > 2) then
    S_Error.str = "N_In num is wrong, should between 1 and 2"
    N_Error.num = n_grabFromIn + 3
    Stop()
  end  
    
  local _xyz = {{N_In1X,N_In1Y,N_In1Z},{N_In2X,N_In2Y,N_In2Z}}
  
  local _x = _xyz[N_Tray.num][1].num
  local _y = _xyz[N_Tray.num][2].num
  local _z = _xyz[N_Tray.num][3].num
  
  if (_x < 1) or (_x > 5) then
    S_Error.str = "X is wrong, should between 1 and 5"
    N_Error.num = n_grabFromIn + 4
    Stop()
  end
  
  if (_y < 1) or (_y > 4) then
    S_Error.str = "Y num is wrong, should between 1 and 4"
    N_Error.num = n_grabFromIn + 5
    Stop()
  end
  
  if (_z < 1) or (_z > 6) then
    S_Error.str = "Z is wrong, should between 1 and 6"
    N_Error.num = n_grabFromIn + 6
    Stop()
  end
  SetDO("DO_LIGHT",0)
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
  local _K_LB1 = CopyJointTarget( K1LB )
  local _K_RB1 = CopyJointTarget( K1RB )
  local _K_LT1 = CopyJointTarget( K1LT )
  local _K_RT1 = CopyJointTarget( K1RT )
  local _K_LB2 = CopyJointTarget( K2LB )
  local _K_RB2 = CopyJointTarget( K2RB )
  local _K_LT2 = CopyJointTarget( K2LT )
  local _K_RT2 = CopyJointTarget( K2RT )

  local p_in = {{_K_LB1,_K_LT1,_K_RT1,_K_RB1},{_K_LB2,_K_LT2,_K_RT2,_K_RB2}}
  
  local index = _x + (_y - 1) * 5
  
  local _LB = p_in[N_Tray.num][1]
  local _LT = p_in[N_Tray.num][2]
  local _RT = p_in[N_Tray.num][3]
  local _RB = p_in[N_Tray.num][4]

  if (index >= 1) and (index <= 5) then
    local LB_x = _LB.robax.rax_1
    local LB_y = _LB.robax.rax_2
    
    local RB_x = _RB.robax.rax_1
    local RB_y = _RB.robax.rax_2
    
    local gap_x = (RB_x - LB_x)/4
    local gap_y = (RB_y - LB_y)/4
    
    local offset_x = (_x - 1) * gap_x
    local offset_y = (_x - 1) * gap_y
    Knext = CopyJointTarget( _LB )
    Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
    Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y 

  end 
  
  if (index >= 16) and (index <= 20) then
    local LT_x = _LT.robax.rax_1
    local LT_y = _LT.robax.rax_2
    
    local RT_x = _RT.robax.rax_1
    local RT_y = _RT.robax.rax_2
    
    local gap_x = (RT_x - LT_x)/4
    local gap_y = (RT_y - LT_y)/4
    
   
    local offset_x = (_x - 1) * gap_x
    local offset_y = (_x - 1) * gap_y
    Knext = CopyJointTarget( _LT )
    Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
    Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y 

  end 
  
  if (index == 6) or (index == 11) then
    local LT_x = _LT.robax.rax_1
    local LT_y = _LT.robax.rax_2
    
    local LB_x = _LB.robax.rax_1
    local LB_y = _LB.robax.rax_2
    
    local gap_x = (LB_x - LT_x)/3
    local gap_y = (LB_y - LT_y)/3
    
    if index == 11 then    
      Knext = CopyJointTarget( _LT )
      Knext.robax.rax_1 = Knext.robax.rax_1 + gap_x
      Knext.robax.rax_2 = Knext.robax.rax_2 + gap_y  
    elseif index == 6 then    
      Knext = CopyJointTarget( _LB )
      Knext.robax.rax_1 = Knext.robax.rax_1 - gap_x
      Knext.robax.rax_2 = Knext.robax.rax_2 - gap_y  
    end

  end
  
  if (index == 10) or (index == 15) then
    local RT_x = _RT.robax.rax_1
    local RT_y = _RT.robax.rax_2
    
    local RB_x = _RB.robax.rax_1
    local RB_y = _RB.robax.rax_2
    
    local gap_x = (RB_x - RT_x)/3
    local gap_y = (RB_y - RT_y)/3
    
    if index == 15 then    
      Knext = CopyJointTarget( _RT )
      Knext.robax.rax_1 = Knext.robax.rax_1 + gap_x
      Knext.robax.rax_2 = Knext.robax.rax_2 + gap_y  
    elseif index == 10 then    
      Knext = CopyJointTarget( _RB )
      Knext.robax.rax_1 = Knext.robax.rax_1 - gap_x
      Knext.robax.rax_2 = Knext.robax.rax_2 - gap_y  
    end    
  end 
  
  if (index == 7) or (index == 8) or (index == 9) or (index == 12) or (index == 13) or (index == 14) then
    Knext = CopyJointTarget( _RT )
    local center_x = (_RT.robax.rax_1 + _LT.robax.rax_1 + _RB.robax.rax_1 + _LB.robax.rax_1)/4
    local center_y = (_RT.robax.rax_2 + _LT.robax.rax_2 + _RB.robax.rax_2 + _LB.robax.rax_2)/4
    
    local gap_x = ((_RT.robax.rax_1 - _LT.robax.rax_1) + (_RB.robax.rax_1 - _LB.robax.rax_1))/2/4
    local gap_y = ((_RB.robax.rax_2 - _RT.robax.rax_2) + (_LB.robax.rax_2 - _LT.robax.rax_2))/2/3
    
    Knext.robax.rax_1 = center_x + (_x - 3) * gap_x
    Knext.robax.rax_2 = center_y - (_y - 2.5) * gap_y
    
  end 

  local _height = Knext.robax.rax_3
  
  TPWrite("x:"..Knext.robax.rax_1.."/y:"..Knext.robax.rax_2)
  
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  Sleep(500)
  openGrab()
  
  if N_productHeight.num == 166 then
    Knext.robax.rax_3 = _height - 166 + (3 - _z) * 332 + 166
  else
    Knext.robax.rax_3 = _height - 166 + (3 - _z) * 332
  end
  TPWrite("z:"..Knext.robax.rax_3)
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(500)
  closeGrab()
  
  Knext.robax.rax_3 = n_safeHeight  
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  Knext.robax.rax_2 = Kwait.robax.rax_2
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
  local __x = _xyz[N_Tray.num][1]
  local __y = _xyz[N_Tray.num][2]
  local __z = _xyz[N_Tray.num][3]
  
  __x.num = __x.num + 1
  if __x.num > 5 then
    __x.num = 1
    __y.num = __y.num + 1
    if __y.num > 4 then
      __y.num = 1
      __z.num =  __z.num - 1
      if __z.num == 0 then
        S_Error.str = "pallet is empty"
        N_Error.num =  n_grabFromIn + 7
      end
    end
  end

  N_Action.num = 0 - n_grabFromIn
  
end

function visionOnIn()
  if GetDI("DI_UNDER") == 1 then
    S_Error.str = "Unable to grab, something under the grab"
    N_Error.num = n_visionOnIn + 1
    Stop()
  end
  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    SetDO("DO_UP",1)  
    Sleep(3000)
  end
  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    S_Error.str = "the sucker should be up"
    N_Error.num = n_visionOnIn + 2
    Stop()
  end

  if (N_Tray.num < 1) or (N_Tray.num > 2) then
    S_Error.str = "N_In num is wrong : "..N_Tray.num
    N_Error.num = n_visionOnIn + 3
    Stop()
  end 
  
  local p_v = {{K1LBV,K1LTV,K1RTV,K1RBV},{K2LBV,K2LTV,K2RTV,K2RBV}}
  local p_ = {{K1LB,K1LT,K1RT,K1RB},{K2LB,K2LT,K2RT,K2RB}}

  N_V.num = 0
  SetDO("DO_V1",0)
  SetDO("DO_V2",0)
  SetDO("DO_V3",0)
  SetDO("DO_V4",0)
  N_V_step.num = 1
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  Knext.robax.rax_2 = Kwait.robax.rax_2
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
 
  local _p_v = p_v[N_Tray.num][N_V_step.num]
  
  Knext = CopyJointTarget(_p_v)
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  SetDO("DO_LIGHT",1)

  MoveAbsJ(_p_v,v200,fine,tool0,wobj0,load0)
  Sleep(500)
  N_V.num = 1
  WaitDO("DO_V1",1,30000,false)
  N_V.num = 0
  local _p = p_[N_Tray.num][N_V_step.num]
  _p.robax.rax_1 = _p_v.robax.rax_1 - Kconveyor_V.robax.rax_1 + N_VX.num
  _p.robax.rax_2 = _p_v.robax.rax_2 - Kconveyor_V.robax.rax_2 + N_VY.num
  
  N_V_step.num = N_V_step.num + 1
  local _p_v2 = p_v[N_Tray.num][N_V_step.num]
  MoveAbsJ(_p_v2,v200,fine,tool0,wobj0,load0)
  Sleep(500)
  N_V.num = 1
  WaitDO("DO_V2",1,30000,false)
  N_V.num = 0
  local _p2 = p_[N_Tray.num][N_V_step.num]
  _p2.robax.rax_1 = _p_v2.robax.rax_1 - Kconveyor_V.robax.rax_1 + N_VX.num
  _p2.robax.rax_2 = _p_v2.robax.rax_2 - Kconveyor_V.robax.rax_2 + N_VY.num
  
  N_V_step.num = N_V_step.num + 1
  local _p_v3 = p_v[N_Tray.num][N_V_step.num]
  MoveAbsJ(_p_v3,v200,fine,tool0,wobj0,load0)
  Sleep(500)
  N_V.num = 1
  WaitDO("DO_V3",1,30000,false)
  N_V.num = 0
  local _p3 = p_[N_Tray.num][N_V_step.num]
  _p3.robax.rax_1 = _p_v3.robax.rax_1 - Kconveyor_V.robax.rax_1 + N_VX.num
  _p3.robax.rax_2 = _p_v3.robax.rax_2 - Kconveyor_V.robax.rax_2 + N_VY.num
  
  N_V_step.num = N_V_step.num + 1
  local _p_v4 = p_v[N_Tray.num][N_V_step.num]
  MoveAbsJ(_p_v4,v200,fine,tool0,wobj0,load0)
  Sleep(500)
  N_V.num = 1
  WaitDO("DO_V4",1,30000,false)
  N_V.num = 0
  local _p4 = p_[N_Tray.num][N_V_step.num]
  _p4.robax.rax_1 = _p_v4.robax.rax_1 - Kconveyor_V.robax.rax_1 + N_VX.num
  _p4.robax.rax_2 = _p_v4.robax.rax_2 - Kconveyor_V.robax.rax_2 + N_VY.num
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)  
  Knext.robax.rax_2 = Kwait.robax.rax_2
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)  
  SetDO("DO_LIGHT",0)
  
  local _table = {{},{},{},{}}
  
  for var=1,4,1 do
    _table[var] = CopyJointTarget(p_[N_Tray.num][var])
  end
  local str =  pam_json.encode(_table)

 
  local posfile = io.open("/home/controller/usr/Program/pos"..N_Tray.num..".json","w")
  io.output(posfile)
  io.write(str)
  Sleep(500)
  posfile:close()    
  
  N_V_step.num = 0
  N_Action.num = 0 - n_visionOnIn 
  
end

function visionOnOut()
  if GetDI("DI_UNDER") == 1 then
    S_Error.str = "Unable to grab, something under the grab"
    N_Error.num = n_visionOnOut + 1
    Stop()
  end
  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    SetDO("DO_UP",1)  
    Sleep(3000)
  end
  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    S_Error.str = "the sucker should be up"
    N_Error.num = n_visionOnOut + 2
    Stop()
  end

  if (N_Tray.num < 3) or (N_Tray.num > 6) then
    S_Error.str = "N_In num is wrong, should between 3 and 6"
    N_Error.num = n_visionOnOut + 3
    Stop()
  end 
  
  N_V.num = 0
  SetDO("DO_V1",0)
  SetDO("DO_V2",0)
  SetDO("DO_V3",0)
  SetDO("DO_V4",0)
  SetDO("DO_LIGHT",0)
  local p_v = {{0,0,0,0},{0,0,0,0},{K3_V1,K3_V2 ,K3_V3,K3_V4 },{K4_V1,K4_V2 ,K4_V3,K4_V4},{K5_V1,K5_V2 ,K5_V3,K5_V4},{K6_V1,K6_V2 ,K6_V3, K6_V4}}

  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  N_V_step.num = 1
  Knext = CopyJointTarget(p_v[N_Tray.num][N_V_step.num])
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  SetDO("DO_LIGHT",1)
  
  Knext = CopyJointTarget(p_v[N_Tray.num][N_V_step.num])
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
  Sleep(500)
  N_V.num = 1
  WaitDO("DO_V1",1,30000,false)
  N_V.num = 0
  N_V_step.num = N_V_step.num + 1
  
  Knext = CopyJointTarget(p_v[N_Tray.num][N_V_step.num])
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  Sleep(500)
  N_V.num = 1
  WaitDO("DO_V2",1,30000,false)
  N_V.num = 0
  N_V_step.num = N_V_step.num + 1
  
  Knext = CopyJointTarget(p_v[N_Tray.num][N_V_step.num])
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  Sleep(500)
  N_V.num = 1
  WaitDO("DO_V3",1,30000,false)
  N_V.num = 0
  N_V_step.num = N_V_step.num + 1
  
  Knext = CopyJointTarget(p_v[N_Tray.num][N_V_step.num])
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  Sleep(500)
  N_V.num = 1
  WaitDO("DO_V4",1,30000,false)
  N_V.num = 0

  local offset = 0
  if N_Tray.num == 4 then
    offset = 1185
  end
  if N_Tray.num == 5 then
    offset = 1185 + 1550
  end  
  if N_Tray.num == 6 then
    offset = 1185 + 1550 + 1185
  end    
  local p__ = out_poses[N_Tray.num]
  p__[1].robax.rax_1 = N_VX1.num + offset
  p__[2].robax.rax_1 = N_VX2.num+ offset
  p__[3].robax.rax_1 = N_VX3.num+ offset
  p__[4].robax.rax_1 = N_VX4.num+ offset
  p__[5].robax.rax_1 = N_VX5.num+ offset
  p__[6].robax.rax_1 = N_VX6.num+ offset
  p__[7].robax.rax_1 = N_VX7.num+ offset
  p__[8].robax.rax_1 = N_VX8.num+ offset
  p__[9].robax.rax_1 = N_VX9.num+ offset
  p__[10].robax.rax_1 = N_VX10.num+ offset
  p__[11].robax.rax_1 = N_VX11.num+ offset
  p__[12].robax.rax_1 = N_VX12.num+ offset
  
  p__[1].robax.rax_2 = N_VY1.num
  p__[2].robax.rax_2 = N_VY2.num
  p__[3].robax.rax_2 = N_VY3.num
  p__[4].robax.rax_2 = N_VY4.num
  p__[5].robax.rax_2 = N_VY5.num
  p__[6].robax.rax_2 = N_VY6.num
  p__[7].robax.rax_2 = N_VY7.num
  p__[8].robax.rax_2 = N_VY8.num
  p__[9].robax.rax_2 = N_VY9.num
  p__[10].robax.rax_2 = N_VY10.num
  p__[11].robax.rax_2 = N_VY11.num
  p__[12].robax.rax_2 = N_VY12.num 
  
  local angle = angleBetweenPoints(p__[1].robax.rax_1,p__[1].robax.rax_2,p__[10].robax.rax_1,p__[10].robax.rax_2)
  if ((angle>-89.5) or (angle<-90.5)) then
    S_Error.str = "tray has rotation : "..angle
    N_Error.num = n_visionOnOut + 4
    TPWrite("angle:"..angle)
    toWaitYZ()
    Stop()
  end
  
  local str = pam_json.encode(p__)
  local posfile = io.open("/home/controller/usr/Program/pos"..N_Tray.num..".json","w")
  io.output(posfile)
  io.write(str)
  Sleep(500)
  posfile:close()  
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)  
  Knext.robax.rax_2 = Kwait.robax.rax_2
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)  
  SetDO("DO_LIGHT",0)  

  N_V_step.num =0
  N_Action.num = 0 - n_visionOnOut 
  
end

function getDistanceByK(K1,K2)
  local _x = math.abs(K1.robax.rax_1 - K2.robax.rax_1)
  local _y = math.abs(K1.robax.rax_2 - K2.robax.rax_2)
  local _z = math.abs(K1.robax.rax_3 - K2.robax.rax_3)
  
  local distance = (_x^2 + _y^2 + _z^2 + 0.0001)^0.5
  return distance
end

function getConfig()
  if N_Tray.num < 3 then
    
    local p_ = {{K1LB,K1LT,K1RT,K1RB},{K2LB,K2LT,K2RT,K2RB}}
    
    local readfile = io.open("/home/controller/usr/Program/pos"..N_Tray.num..".json","r")
    local readf = readfile:read("*a")
    readfile:close()
    local posistions = pam_json.decode(readf)


    local var2=0

    for var2=1,4,1 do
      p_[N_Tray.num][var2].robax.rax_1 = posistions[var2].robax.rax_1
      p_[N_Tray.num][var2].robax.rax_2 = posistions[var2].robax.rax_2
    end

  else
    local readfile = io.open("/home/controller/usr/Program/pos"..N_Tray.num..".json","r")
    local readf = readfile:read("*a")
    readfile:close()
    local posistions = pam_json.decode(readf)
    out_poses[N_Tray.num] = posistions;
    TPWrite("x:"..out_poses[N_Tray.num][1].robax.rax_1.."/y:"..out_poses[N_Tray.num][1].robax.rax_2)
  end
  
  N_Action.num = 0 - n_getConfig
end

function forManual()
  MoveAbsJ(Kwait,v100,fine,tool0,wobj0,load0)
  
  MoveAbsJ(K1RBU,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K2RBU,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(Ksuck,v100,fine,tool0,wobj0,load0)
  MoveL(Psuck,v100,fine,tool0,wobj0,load0)
  MoveL(Psuck_U,v100,fine,tool0,wobj0,load0)
  MoveL(Psuck_D,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(Ksuck_U,v100,fine,tool0,wobj0,load0)
  
  MoveAbsJ(KsuckOffset_U,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(KlineS,v100,fine,tool0,wobj0,load0)  
  MoveAbsJ(KlineSU,v100,fine,tool0,wobj0,load0) 

  MoveAbsJ(K1LT,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K1LB,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K1RB,v100,fine,tool0,wobj0,load0)

  MoveAbsJ(K1RT,v100,fine,tool0,wobj0,load0)  
  MoveAbsJ(K1LT,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K2LB,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K2RT,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K2RB,v100,fine,tool0,wobj0,load0)  

  MoveAbsJ(K3LT,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K3LB,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K3RB,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K3RT,v100,fine,tool0,wobj0,load0)  
  MoveAbsJ(K4LT,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K4LB,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K4RB,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K4RT,v100,fine,tool0,wobj0,load0)  
  MoveAbsJ(K5LT,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K5LB,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K5RB,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K5RT,v100,fine,tool0,wobj0,load0)  
  MoveAbsJ(K6LT,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K6LB,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K6RB,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K6RT,v100,fine,tool0,wobj0,load0)  
  
  MoveAbsJ(K1LTV,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K1LBV,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K1RBV,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K1RTV,v100,fine,tool0,wobj0,load0)  
  
  MoveAbsJ(K2LTV,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K2LBV,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K2RTV,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K2RBV,v100,fine,tool0,wobj0,load0)

  MoveAbsJ(K3_V1,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K3_V2,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K3_V3,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K3_V4,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K4_V1,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K4_V2,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K4_V3,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K4_V4,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K5_V1,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K5_V2,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K5_V3,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K5_V4,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K6_V1,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K6_V2,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K6_V3,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K6_V4,v100,fine,tool0,wobj0,load0)

  MoveAbsJ(KcacheCorner,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(KcartCorner,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(KcacheCornerU,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(KcartCornerU,v100,fine,tool0,wobj0,load0)  
  
  MoveAbsJ(KRGV1,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(KRGV1U,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(KRGV2,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(KRGV2U,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(KRGV3,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(KRGV3U,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(KRGV4,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(KRGV4U,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(KRGV5,v100,fine,tool0,wobj0,load0) 
  MoveAbsJ(KRGV5U,v100,fine,tool0,wobj0,load0)      
  MoveAbsJ(Kconveyor,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(Kconveyor_V,v100,fine,tool0,wobj0,load0)  
  MoveAbsJ(KconveyorU,v100,fine,tool0,wobj0,load0)  
  
  MoveAbsJ(KP3,v100,fine,tool0,wobj0,load0)  
  MoveAbsJ(KP4,v100,fine,tool0,wobj0,load0)  
  MoveAbsJ(KP5,v100,fine,tool0,wobj0,load0)  
  MoveAbsJ(KP6,v100,fine,tool0,wobj0,load0)  
  
  MoveAbsJ(KP3U,v100,fine,tool0,wobj0,load0)  
  MoveAbsJ(KP4U,v100,fine,tool0,wobj0,load0)  
  MoveAbsJ(KP5U,v100,fine,tool0,wobj0,load0)  
  MoveAbsJ(KP6U,v100,fine,tool0,wobj0,load0)  

end

SetDO("DO_LIGHT",0)


function _main()
  N_Tray.num = 1
  getConfig()
  N_Tray.num = 2
  getConfig()
  N_Tray.num = 3
  getConfig()
  N_Tray.num = 4
  getConfig()
  N_Tray.num = 5
  getConfig()  
  N_Tray.num = 6
  getConfig()        
  while true do
    Sleep(10)
    if GetDO("DO_AllowCrawl") == 1 then
      if N_Action.num == n_grabFromIn then
        grabFromIn()
      elseif N_Action.num == n_grabFromCache then
        grabFromCache()
      elseif N_Action.num == n_grabFromConveyor then
        grabFromConveyor()
      elseif N_Action.num == n_suckPartition then
        suckPartition()
      end
    else
      if N_Action.num == n_grabToRGV then
        grabToRGV()  
      elseif N_Action.num == n_grabToOut then
        grabToOut()   
      elseif N_Action.num == n_grabToCache then
        grabToCache()              
      elseif N_Action.num == n_grabToCart then
        grabToCart() 
      elseif N_Action.num == n_placePartition then
        placePartition() 
      end
    end
    if N_Action.num == n_visionOnIn then
      visionOnIn()
    elseif N_Action.num == n_visionOnOut then
      visionOnOut()
    elseif N_Action.num == n_visionOnConveyor then
      visionOnConveyor()
    elseif N_Action.num == n_visionOnPartition then
      visionOnPartition()
    elseif N_Action.num == n_toWait then
      toWait()    
    elseif N_Action.num == n_toWaitYZ then
      toWaitYZ()             
    elseif N_Action.num == n_correctPartition then
      correctPartition()       
    elseif N_Action.num == n_getConfig then
      getConfig()       
    end    
  end
end
--toWaitYZ()

_main()

local function GLOBALDATA_DEFINE()
SPEEDDATA("v250",250.000,500.000,250.000,70.000)
SPEEDDATA("v300",300.000,500.000,300.000,70.000)
SPEEDDATA("v400",400.000,500.000,400.000,70.000)
SPEEDDATA("v600",600.000,500.000,600.000,70.000)

NUMDATA("N_Action",0)
NUMDATA("N_CacheX",0)
NUMDATA("N_CacheY",0)
NUMDATA("N_CacheZ",0)
NUMDATA("N_CartX",0)
NUMDATA("N_CartY",0)
NUMDATA("N_CartZ",0)
NUMDATA("N_Error",0)
NUMDATA("N_Tray",0)
NUMDATA("N_In1X",0)
NUMDATA("N_In1Y",0)
NUMDATA("N_In1Z",0)
NUMDATA("N_In2X",0)
NUMDATA("N_In2Y",0)
NUMDATA("N_In2Z",0)

NUMDATA("N_Out3I",0)
NUMDATA("N_Out3Z",0)
NUMDATA("N_Out4I",0)
NUMDATA("N_Out4Z",0)
NUMDATA("N_Out5I",0)
NUMDATA("N_Out5Z",0)
NUMDATA("N_Out6I",0)
NUMDATA("N_Out6Z",0)

NUMDATA("N_RGV",0)
NUMDATA("N_RGVZ",0)
NUMDATA("N_V_step",0)
NUMDATA("N_conveyorR",-90)

NUMDATA("N_productHeight",166)

NUMDATA("N_V",0)
NUMDATA("N_VX",-99999)
NUMDATA("N_VY",0)

NUMDATA("N_VX1",0)
NUMDATA("N_VY1",0)
NUMDATA("N_VX2",0)
NUMDATA("N_VY2",0)
NUMDATA("N_VX3",0)
NUMDATA("N_VY3",0)
NUMDATA("N_VX4",0)
NUMDATA("N_VY4",0)
NUMDATA("N_VX5",0)
NUMDATA("N_VY5",0)
NUMDATA("N_VX6",0)
NUMDATA("N_VY6",0)
NUMDATA("N_VX7",0)
NUMDATA("N_VY7",0)
NUMDATA("N_VX8",0)
NUMDATA("N_VY8",0)
NUMDATA("N_VX9",0)
NUMDATA("N_VY9",0)
NUMDATA("N_VX10",0)
NUMDATA("N_VY10",0)
NUMDATA("N_VX11",0)
NUMDATA("N_VY11",0)
NUMDATA("N_VX12",0)
NUMDATA("N_VY12",0)

JOINTTARGET("K1RTV",{-8697.210,845.078,-1044.990,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1RBV",{-8700.420,1706.800,-1044.960,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1LBV",{-9903.640,1705.240,-1044.960,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1LTV",{-9896.770,833.095,-1044.950,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})

JOINTTARGET("K1LB",{-9727.010,1712.370,-765.417,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1LT",{-9721.760,838.815,-760.058,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1RB",{-8524.500,1713.230,-758.983,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1RT",{-8522.530,840.578,-759.956,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})

JOINTTARGET("K2LB",{-17913.800,1713.690,-758.815,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2LBV",{-8090.500,1709.050,-1045.010,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2LT",{-7912.870,838.693,-767.534,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2LTV",{-8090.040,834.731,-1045.000,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2RB",{-6715.410,1711.630,-757.582,-90.010,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2RBV",{-6893.060,1707.590,-1045.020,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2RT",{-6710.940,841.758,-757.090,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2RTV",{-6888.390,836.301,-1045.000,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})

JOINTTARGET("K3_V1",{-5281.510,1337.200,-189.079,-90.002,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V2",{-4601.520,1339.350,-189.110,-89.995,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V3",{-5272.870,840.521,-189.081,-90.004,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V4",{-4587.150,840.521,-189.087,-89.996,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})

JOINTTARGET("K4_V1",{-4096.51,1337.200,-189.079,-90.002,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V2",{-3416.52,1339.350,-189.110,-89.995,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V3",{-4087.87,840.521,-189.081,-90.004,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V4",{-3402.15,840.521,-189.087,-89.996,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})

JOINTTARGET("K5_V1",{-2546.51,1337.200,-189.079,-90.002,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V2",{-1866.52,1339.350,-189.110,-89.995,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V3",{-2537.87,840.521,-189.081,-90.004,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V4",{-1852.14,840.521,-189.087,-89.996,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})

JOINTTARGET("K6RT",{-773.941,881.847,-82.254,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V1",{-1361.51,1337.200,-189.079,-90.002,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V2",{-681.52,1339.350,-189.110,-89.995,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V3",{-1352.87,840.521,-189.081,-90.004,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V4",{-667.14,840.521,-189.087,-89.996,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})

JOINTTARGET("KP3",{-5051.230,1279.610,-137.190,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP3U",{-5051.230,1279.610,-950.190,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP4",{-3868.040,1294.850,-137.842,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP4U",{-3868.040,1294.850,-950.842,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP5",{-2314.530,1279.590,-145.796,-179.432,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP5U",{-2326.280,1279.610,-950.842,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP6",{-1138.400,1277.440,-137.201,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP6U",{-1138.400,1277.440,-950.201,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV1",{-5826.13,1359.44,-99,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV2",{-5825.13,1036.14,-99,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV3",{-5829.07,712.82,-99,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV4",{-5833.77,398.24,-99,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV5",{-5832.93,79.20,-99,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})

JOINTTARGET("KRGV1U",{-5826.13,1359.44,-1297,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV2U",{-5825.13,1036.14,-1297,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV3U",{-5829.07,712.82,-1297,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV4U",{-5833.77,398.24,-1297,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV5U",{-5832.93,79.20,-1297,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})

JOINTTARGET("KcacheCorner",{-8706.230,57.436,-189.931,-90.014,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcacheCornerU",{-8706.230,57.434,-1297.000,-90.014,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcartCorner",{-9759.480,-0.370,-195.537,-178.075,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcartCorner_U",{-9759.480,-0.370,-1297.000,-178.075,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Kconveyor",{-1319.660,227.076,-116.054,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KconveyorU",{-1506.900,181.091,-626.322,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Kconveyor_V",{-1506.900,181.091,-246.322,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KlineS",{-6852.470,2034.730,-1535.000,-94.925,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KlineSU",{-6852.470,2034.730,-1535.000,-94.925,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Knext",{0.000,0.000,0.000,0.000,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Ksuck",{-23.582,1225.050,-175.355,-179.097,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KsuckOffset_U",{-23.584,1173.020,-755.609,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Ksuck_U",{-23.582,1225.050,-755.615,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Kwait",{-5716.540,350.441,-1297.000,-90.331,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
ROBTARGET("Psuck",{-23.580,1225.050,-175.360},{0.007874,0.000000,0.000000,-0.999969},{-2,0,0,0},{0.000,0.000,0.000,0.000,0.000,0.000,0.000},0.000)
ROBTARGET("Psuck_D",{-23.581,1225.050,-289.273},{0.007874,0.000000,0.000000,-0.999969},{-2,0,0,0},{0.000,0.000,0.000,0.000,0.000,0.000,0.000},0.000)
ROBTARGET("Psuck_U",{-23.580,1225.050,-755.620},{0.007874,0.000000,0.000000,-0.999969},{-2,0,0,0},{0.000,0.000,0.000,0.000,0.000,0.000,0.000},0.000)
STRINGDATA("S_Code","0")
STRINGDATA("S_Error","Partition dropped ")
end
print("The end!")