local cjson = require "cjson"
local pam_json = cjson.new()

--程序执行号
local n_grabFromIn=100
local n_grabToCache=200
local n_grabFromCache=300
local n_grabToCart=400
local n_toWait=500
local n_visionOnConveyor=600
local n_grabFromConveyor=700
local n_grabToOut=800
local n_grabToRGV=900
local n_suckPartition=1000
local n_placePartition=1100
local n_visionOnIn=1200
local n_visionOnOut=1300
local n_visionOnPartition=1400
local n_correctPartition=1500
local n_toWaitYZ=1600
local n_getConfig=1700
local n_function=1800
--在安全高度层运行时,速度可以快
local n_safeHeight=-1297
local n_grablInHeight = -765
local n_suckUpSlowly = -569.56
local n_cacheOffsetX=300
local n_cacheOffsetY=330
local n_cartOffsetX=300
local n_cartOffsetY=270

local var = 0
local bar = 0

local PLC_DELAY = 2500

--3*12个坐标,存储出口盘的放置坐标. 拍隔板的4个梯形块后,会生成这些坐标,然后存储到硬盘里. 在程序启动时,会加载读取这些坐标配置
--初始化前需要先把坐标对象给塞进去
local out_poses = {{},{},{{},{},{},{},{},{},{},{},{},{},{},{}},{{},{},{},{},{},{},{},{},{},{},{},{}},{{},{},{},{},{},{},{},{},{},{},{},{}},{{},{},{},{},{},{},{},{},{},{},{},{}}}
for var = 3,6,1 do
  local p12s = out_poses[var]
  for bar = 1,12,1 do
    p12s[bar] = CopyJointTarget( Knext )
    

  end
end 

local v_safeHeight = CopySpeedData(v600)
local v_vertical = CopySpeedData(v250)
local v_grab = CopySpeedData(v100)
local v_suckUpSlowly = CopySpeedData(v50)


function angleBetweenPoints(Ax, Ay, Bx, By)
    local dx = Bx - Ax
    local dy = By - Ay
    return math.deg(math.atan2(dy, dx))
end

--打开爪子
function openGrab()
  SetDO("DO_OPEN",1)
  SetDO("DO_CLOSE",0)
  WaitDI("DI_CLOSE",0)
  Sleep(500)
  local ret = WaitDI("DI_OPEN",1,5000,true)
  if ret == true then
    S_Error.str = "Unable to open the grab, check the air pressure"
    N_Error.num = N_function.num + 2
    Stop()
  end
  return 1
end

--关闭爪子
function closeGrab()
  local ret = GetDI("DI_UNDER")
  if ret == 0 then
    S_Error.str = "there is nothing under the grab"
    N_Error.num = N_function.num + 5
    Stop()
  end
  
  SetDO("DO_OPEN",0)
  SetDO("DO_CLOSE",1)
  WaitDI("DI_OPEN",0)
  Sleep(500)
  local ret = WaitDI("DI_CLOSE",1,5000,true)
  if ret == true then
    S_Error.str = "Unable to close the grab, check the air pressure"
    N_Error.num = N_function.num + 6
    Stop()
  end
  return 1
end


--隔板吸关闭
function stopSuck()

  SetDO("DO_SUCK",0)
  if WaitDI("DI_AIR_LEFT",1,3000,true) == true then
    S_Error.str = "left air is still sucking"
    N_Error.num = N_function.num + 15
    Stop()
  end
  if WaitDI("DI_AIR_RIGHT",1,3000,true) == true then
    S_Error.str = "right air is still sucking"
    N_Error.num = N_function.num + 16
    Stop()
  end
  
end

--从缓存台抓轮盘
function grabFromCache()
  N_Action.num = n_grabFromCache
  if GetDI("DI_UNDER") == 1 then
    S_Error.str = "something under the grab"
    N_Error.num = n_grabFromCache + 1
    Stop()
  end
  
  local x = PR_Buffer_Num.num
  local y = 1
  
  if (x > 9) then
      y = 2
      x = x - 9 
  end
  N_CacheX.num = x
  N_CacheY.num = y
  
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
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  
  local offset_x = (N_CacheX.num - 1) * n_cacheOffsetX
  local offset_y = (N_CacheY.num - 1) * n_cacheOffsetY
  Knext = CopyJointTarget(KcacheCorner)
  Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
  Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y
  Knext.robax.rax_3 = n_safeHeight
  
  TPWrite("X:"..Knext.robax.rax_1.."/Y:"..Knext.robax.rax_2.."/Z:"..Knext.robax.rax_3)
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0)
  openGrab()

  Knext.robax.rax_3 = KcacheCorner.robax.rax_3 + 166 - N_productHeight.num - 332
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)

  Knext.robax.rax_3 = KcacheCorner.robax.rax_3 + 166 - N_productHeight.num
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)
  SetDO("DO_Grabbing",1)
  closeGrab()
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight

  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
 
  N_Action.num = 0 - n_grabFromCache
end

--满盘抓取从滚筒末端到缓存区
function grabToCache()
  N_Action.num = n_grabToCache
  if GetDI("DI_UNDER") == 0 then
    S_Error.str = "Unable to grab toward cache, nothing under the grab"
    N_Error.num = n_grabToCache + 1
    Stop()
  end
  
  local x = PR_Buffer_Num.num
  local y = 1
  
  if (x > 9) then
      y = 2
      x = x - 9 
  end
  N_CacheX.num = x
  N_CacheY.num = y
  
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
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  
  local offset_x = (N_CacheX.num - 1) * n_cacheOffsetX
  local offset_y = (N_CacheY.num - 1) * n_cacheOffsetY
  Knext = CopyJointTarget(KcacheCorner)
  Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
  Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y
  Knext.robax.rax_3 = n_safeHeight
  
  TPWrite("X:"..Knext.robax.rax_1.."/Y:"..Knext.robax.rax_2.."/Z:"..Knext.robax.rax_3)
  
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = KcacheCorner.robax.rax_3
  if N_productHeight.num == 332 then
    Knext.robax.rax_3 = KcartCorner.robax.rax_3 - 166
  end
  local h_grab = Knext.robax.rax_3
  Knext.robax.rax_3 = h_grab - 332
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = h_grab
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)
  SetDO("DO_Grabbing",0)
  openGrab()
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  
  N_Action.num = 0 - n_grabToCache
end

--满盘抓取从滚筒末端到不良品小车
function grabToCart()
  N_Action.num = n_grabToCart
  if GetDI("DI_UNDER") == 0 then
    S_Error.str = "nothing under the grab"
    N_Error.num = n_grabToCart + 1
    Stop()
  end
  
  local x = 1
  local y = 1
  local z = 1
  if ((PR_Buffer_Num.num % 2)==0) then
      z = 2
  end
  if (PR_Buffer_Num.num<=6) then
      y = 2
      x = math.ceil(PR_Buffer_Num.num/2)  
  else
      y = 1
      x = math.ceil((PR_Buffer_Num.num-6)/2)  
  end
 
  N_CartX.num = x
  N_CartY.num = y
  N_CartZ.num = z
  
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
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  
  local offset_x = (N_CartX.num - 1) * n_cartOffsetX
  local offset_y = (N_CartY.num - 1) * n_cartOffsetY
  Knext = CopyJointTarget(KcartCorner)
  Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
  Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y
  
  Knext.robax.rax_3 = n_safeHeight  
  TPWrite("X:"..Knext.robax.rax_1.."/Y:"..Knext.robax.rax_2.."/Z:"..Knext.robax.rax_3)  
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0)
  local h_grab = KcartCorner.robax.rax_3 + 166 - N_productHeight.num * N_CartZ.num
  Knext.robax.rax_3 = h_grab - 332
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = KcartCorner.robax.rax_3 + 166 - N_productHeight.num * N_CartZ.num
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)
  SetDO("DO_Grabbing",0)
  openGrab()
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  
  N_Action.num = 0 - n_grabToCart
end

--空盘抓取放置到小车
function grabToRGV()
  N_Action.num = n_grabToRGV
  if GetDI("DI_UNDER") == 0 then
    S_Error.str = "nothing under the grab"
    N_Error.num = n_grabToRGV + 1
    Stop()
  end
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  Sleep(1000)

  if (PR_Rob_pos_put.num < 1) or (PR_Rob_pos_put.num > 10) then
    S_Error.str = "N_RGV is wrong, should between 1 and 5"
    N_Error.num = n_grabToRGV + 2
    Stop()
  end  
  
  local idx = math.ceil((PR_Rob_pos_put.num - 1)/2)+1
  local _RGV_PS = {KRGV1,KRGV2,KRGV3,KRGV4,KRGV5}
  local _RGV_P = _RGV_PS[idx]

  Knext = CopyJointTarget(_RGV_P)
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0)
  local h_grab = _RGV_P.robax.rax_3 + 166 - N_productHeight.num
  Knext.robax.rax_3 = h_grab - 332
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = h_grab
  TPWrite("z:"..Knext.robax.rax_3)
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)
  SetDO("DO_Grabbing",0)
  openGrab()
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)  

  N_Action.num = 0 - n_grabToRGV
end

--视觉识别滚筒末端
function visionOnConveyor()
  N_Action.num = n_visionOnConveyor
  if GetDI("DI_UNDER") == 1 then
    S_Error.str = "something under the grab"
    N_Error.num = n_visionOnConveyor + 1
    Stop()
  end

  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  
  Knext = CopyJointTarget(Kconveyor_V)
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0)
  Sleep(300)  
  N_V.num = 0
  SetDO("DO_V1",0)
  N_V_step.num = 1
  SetDO("DO_LIGHT",1)
  
  Knext.robax.rax_3 = Kconveyor_V.robax.rax_3 + 166 -332

  Knext.robax.rax_3 = Kconveyor_V.robax.rax_3 + 166 - N_productHeight.num
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)  
  Sleep(300)
  N_V.num = 1
  WaitDO("DO_V1",1,30000,false)
  N_V.num = 0
  Sleep(300)
  Kconveyor.robax.rax_1 =  N_VX.num
  Kconveyor.robax.rax_2 =  N_VY.num

  N_Action.num = 0 - n_visionOnConveyor
  
end

--从滚筒末端抓取
function grabFromConveyor()
  N_Action.num = n_grabFromConveyor
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
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)
  
  Knext = CopyJointTarget(Kconveyor)
  Knext.robax.rax_3 = _Kconveyor_V.robax.rax_3 - 0
  Knext.robax.rax_4 = N_conveyorR.num + 45
  if Knext.robax.rax_4 > 180 then
    Knext.robax.rax_4 = Knext.robax.rax_4 - 360
  end
  TPWrite("z:"..Knext.robax.rax_3.."/x:"..Knext.robax.rax_1.."/y:"..Knext.robax.rax_2)
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)
  openGrab()
  Knext.robax.rax_3 = Kconveyor.robax.rax_3 + 166 - N_productHeight.num
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)
  SetDO("DO_Grabbing",1)
  closeGrab()
  
  Knext.robax.rax_3 = Knext.robax.rax_3 - 166
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = n_safeHeight
  Knext.robax.rax_4 = -90
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  N_Action.num = 0 - n_grabFromConveyor
end

--滚筒末端抓取到出口盘放置
function grabToOut()
  N_Action.num = n_grabToOut
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

  if (PR_Tray_Num.num < 3) or (PR_Tray_Num.num > 6) then
    S_Error.str = "N_Tray num is wrong, should between 3 and 6"
    N_Error.num =  n_grabToOut + 3
    Stop()
  end  

  local _z_ = {0,0,N_Out3Z,N_Out4Z,N_Out5Z,N_Out6Z}
  local _i_ = {0,0,N_Out3I,N_Out4I,N_Out5I,N_Out6I}

  local _z = _z_[PR_Tray_Num.num]
  local _i = _i_[PR_Tray_Num.num]
  
  _z.num = PR_layers.num
  _i.num = (PR_Rob_pos_put.num-1) % 12 + 1
  
  if (_i.num < 1 or _i.num > 12) then
    S_Error.str = "index num is wrong, should between 1 and 12"
    N_Error.num = n_grabToOut + 3
    Stop()
  end  

  Knext = GetJointTarget ("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)

  local poses = out_poses[PR_Tray_Num.num]
  local _p_1_12 = {poses[8],poses[5],poses[7],poses[6],poses[4],poses[9],poses[1],poses[12],poses[2],poses[11],poses[3],poses[10]}

  poses[1].robax.rax_4 = 90
  poses[2].robax.rax_4 = 90
  poses[3].robax.rax_4 = -177
  poses[4].robax.rax_4 = 0
  poses[5].robax.rax_4 = 0
  poses[6].robax.rax_4 = -177
  poses[7].robax.rax_4 = 0 
  poses[8].robax.rax_4 = -90 
  poses[9].robax.rax_4 = -177  
  poses[10].robax.rax_4 = 0  
  poses[11].robax.rax_4 = -90  
  poses[12].robax.rax_4 = -90                                           
 
  Knext = _p_1_12[_i.num]
  
  Knext.robax.rax_3 = n_safeHeight
  
  TPWrite("x:"..Knext.robax.rax_1.."/y:"..Knext.robax.rax_2.."/i:".._i.num)  
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0)
  local grabHeight = K6RT.robax.rax_3 + 166 - _z.num * N_productHeight.num
  TPWrite("z:"..Knext.robax.rax_3.."/R:"..Knext.robax.rax_4) 
  if _z.num < 5 then
    Knext.robax.rax_3 = grabHeight - 332 
    MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  end
  Knext.robax.rax_3 = grabHeight  
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)
  SetDO("DO_Grabbing",0)
  openGrab()
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  Knext.robax.rax_4 = -90
  if (_z.num == 6) and (N_productHeight.num == 166) then
    Knext.robax.rax_2 = Kwait.robax.rax_2
  end
  if (_z.num == 3) and (N_productHeight.num == 332) then
    Knext.robax.rax_2 = Kwait.robax.rax_2
  end
  
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)

  N_Action.num = 0 - n_grabToOut
end

--放置隔板
function placePartition()
  N_Action.num = n_placePartition
  if GetDI("DI_UNDER") == 0 then
    S_Error.str = "Partition dropped "
    N_Error.num = n_placePartition + 1
    Stop()
  end
  
  if (PR_Tray_Num.num < 3) or (PR_Tray_Num.num > 6) then
    S_Error.str = "N_Out num is wrong, should between 3 and 6"
    N_Error.num = n_placePartition + 2
    Stop()
  end  

  local _z_ = {0,0,N_Out3Z,N_Out4Z,N_Out5Z,N_Out6Z}
  local _z = _z_[PR_Tray_Num.num]
  _z.num = PR_layers.num
  
  if (_z.num < 2) or (_z.num > 6) then
    S_Error.str = "Z num should between 2 and 6"
    N_Error.num = n_placePartition + 2
    Stop()
  end  
  
  Knext = GetJointTarget ("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)  
  
  local poses12 = out_poses[PR_Tray_Num.num]
  local center_x = (poses12[1].robax.rax_1 + poses12[12].robax.rax_1)/2
  local center_y = (poses12[1].robax.rax_2 + poses12[12].robax.rax_2)/2
  
  Knext = CopyJointTarget( KP3 )
  Knext.robax.rax_1 = center_x - 98.374 -2
  Knext.robax.rax_2 = center_y - 2.183 + 5
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0) 
  if GetDI("DI_UNDER") == 0 then
    S_Error.str = "Partition dropped while arrriving"
    N_Error.num = n_placePartition + 1
    Stop()
  end
  local h_grab = KP3.robax.rax_3 + 166 - (_z.num - 1) * N_productHeight.num
  Knext.robax.rax_3 = h_grab - 88
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)    
  Knext.robax.rax_3 = h_grab
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)  
  SetDO("DO_Grabbing",0)
  stopSuck()
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)  
  SetDO("DO_UP",1)
  
  N_Action.num = 0 - n_placePartition
end

--吸取隔板
function suckPartition()
  N_Action.num = n_suckPartition
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
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)  
  
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
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0)  
  SetDO("DO_UP",0)
  MoveAbsJ(KsuckOffset_U,v_grab,fine,tool0,wobj0,load0)
  if GetDI("DI_UNDER") == 1 then
    S_Error.str = "there is a partition stuck on the shelf, remove it"
    N_Error.num = n_suckPartition + 6
    Stop()
  end  
  MoveAbsJ(Ksuck_U,v_grab,fine,tool0,wobj0,load0)
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
  
  local ret = SearchL("DI_UNDER",1,Psuck_D,Psuck,v_grab,tool0,wobj0)
  if ret == true then 
    
    if WaitDI("DI_AIR_LEFT",1,3000,true) == true then
      S_Error.str = "insufficient left air pressure from vacuum "
      N_Error.num = N_function.num + 8
      Stop()
    end
    if WaitDI("DI_AIR_RIGHT",1,3000,true) == true then
      S_Error.str = "insufficient right air pressure from vacuum"
      N_Error.num = N_function.num + 9
      Stop()
    end
    
    local current = GetJointTarget("Xyzw")
    current.robax.rax_3 = current.robax.rax_3 + 152.14
    MoveAbsJ(current,v_grab,fine,tool0,wobj0,load0)
    SetDO("DO_SUCK",1)
    SetDO("DO_Grabbing",1)
    Sleep(500)
    if GetDI("DI_AIR_LEFT")==1 then
      local databody = GetRobTarget("Xyzw", tool0, wobj0)    
      local ret2 = SearchL("DI_AIR_LEFT",0,databody,Psuck,v_grab,tool0,wobj0)
    end    
  else
    S_Error.str = "Partition not found "
    N_Error.num = n_suckPartition + 1
    Stop()
  end
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_suckUpSlowly
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = KsuckOffset_U.robax.rax_3  
  MoveAbsJ(Knext,v_suckUpSlowly,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  if GetDI("DI_UNDER") == 0 then
    S_Error.str = "Partition dropped "
    N_Error.num = n_suckPartition + 1
    Stop()
  end
  
  N_Action.num = 0 - n_suckPartition

end

--到等待位置
function toWait()
  N_Action.num = n_toWait
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  TPWrite("To safe height")
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  SetDO("DO_LIGHT",0)
  Knext.robax.rax_2 = Kwait.robax.rax_2
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  N_Action.num = 0 - n_toWait
end

--到等待位置-2
function toWaitYZ()
  N_Action.num = n_toWaitYZ
  SetDO("DO_LIGHT",0)
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  Knext.robax.rax_2 = Kwait.robax.rax_2
  Knext.robax.rax_4 = -90
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  N_Action.num = 0 - n_toWaitYZ
end

--从入口盘抓取空轮
function grabFromIn()
  N_Action.num = n_grabFromIn
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

  if (PR_Tray_Num.num < 1) or (PR_Tray_Num.num > 2) then
    S_Error.str = "N_In num is wrong, should between 1 and 2"
    N_Error.num = n_grabFromIn + 3
    Stop()
  end  
    
  local _z = math.ceil(PR_destackingNum.num / 20)
  local _y = 4 - math.ceil( (PR_destackingNum.num - ((_z - 1) * 20))/5) + 1
  local _x = 5 - (PR_destackingNum.num - (_z - 1) * 20 - (4 - _y) * 5) + 1
  local _xyz = {{N_In1X,N_In1Y,N_In1Z},{N_In2X,N_In2Y,N_In2Z}}
  
  _xyz[PR_Tray_Num.num][1].num = _x
  _xyz[PR_Tray_Num.num][2].num = _y
  _xyz[PR_Tray_Num.num][3].num = _z 
        
  
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
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  
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
  
  local _LB = p_in[PR_Tray_Num.num][1]
  local _LT = p_in[PR_Tray_Num.num][2]
  local _RT = p_in[PR_Tray_Num.num][3]
  local _RB = p_in[PR_Tray_Num.num][4]

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
  
  TPWrite("x:"..Knext.robax.rax_1.."/y:"..Knext.robax.rax_2)
  
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0)
  openGrab()
  
  if N_productHeight.num == 166 then
    Knext.robax.rax_3 = n_grablInHeight - 166 + (3 - _z) * 332 + 166
  else
    Knext.robax.rax_3 = n_grablInHeight - 166 + (3 - _z) * 332
  end
  TPWrite("z:"..Knext.robax.rax_3)
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)
  SetDO("DO_Grabbing",1)
  closeGrab()
  
  Knext.robax.rax_3 = n_safeHeight  
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  if Knext.robax.rax_2 > 1597 then
    Knext.robax.rax_2 = 1597
    MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  end

  N_Action.num = 0 - n_grabFromIn
  
end

--机器视觉拍摄入口盘的4个位置
function visionOnIn()
  N_Action.num = n_visionOnIn
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

  if (PR_Tray_Num.num < 1) or (PR_Tray_Num.num > 2) then
    S_Error.str = "num is wrong : "..PR_Tray_Num.num
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
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  Knext.robax.rax_2 = Kwait.robax.rax_2
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
 
  local _p_v = p_v[PR_Tray_Num.num][N_V_step.num]
  
  Knext = CopyJointTarget(_p_v)
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0)
  SetDO("DO_LIGHT",1)

  MoveAbsJ(_p_v,v_vertical,fine,tool0,wobj0,load0)
  Sleep(500)
  N_V.num = 1
  WaitDO("DO_V1",1,30000,false)
  N_V.num = 0
  local _p = p_[PR_Tray_Num.num][N_V_step.num]
  _p.robax.rax_1 = _p_v.robax.rax_1 - Kconveyor_V.robax.rax_1 + N_VX.num
  _p.robax.rax_2 = _p_v.robax.rax_2 - Kconveyor_V.robax.rax_2 + N_VY.num
  
  N_V_step.num = N_V_step.num + 1
  local _p_v2 = p_v[PR_Tray_Num.num][N_V_step.num]
  MoveAbsJ(_p_v2,v_vertical,fine,tool0,wobj0,load0)
  Sleep(500)
  N_V.num = 1
  WaitDO("DO_V2",1,30000,false)
  N_V.num = 0
  local _p2 = p_[PR_Tray_Num.num][N_V_step.num]
  _p2.robax.rax_1 = _p_v2.robax.rax_1 - Kconveyor_V.robax.rax_1 + N_VX.num
  _p2.robax.rax_2 = _p_v2.robax.rax_2 - Kconveyor_V.robax.rax_2 + N_VY.num
  
  N_V_step.num = N_V_step.num + 1
  local _p_v3 = p_v[PR_Tray_Num.num][N_V_step.num]
  MoveAbsJ(_p_v3,v_vertical,fine,tool0,wobj0,load0)
  Sleep(500)
  N_V.num = 1
  WaitDO("DO_V3",1,30000,false)
  N_V.num = 0
  local _p3 = p_[PR_Tray_Num.num][N_V_step.num]
  _p3.robax.rax_1 = _p_v3.robax.rax_1 - Kconveyor_V.robax.rax_1 + N_VX.num
  _p3.robax.rax_2 = _p_v3.robax.rax_2 - Kconveyor_V.robax.rax_2 + N_VY.num
  
  N_V_step.num = N_V_step.num + 1
  local _p_v4 = p_v[PR_Tray_Num.num][N_V_step.num]
  MoveAbsJ(_p_v4,v_vertical,fine,tool0,wobj0,load0)
  Sleep(500)
  N_V.num = 1
  WaitDO("DO_V4",1,30000,false)
  N_V.num = 0
  local _p4 = p_[PR_Tray_Num.num][N_V_step.num]
  _p4.robax.rax_1 = _p_v4.robax.rax_1 - Kconveyor_V.robax.rax_1 + N_VX.num
  _p4.robax.rax_2 = _p_v4.robax.rax_2 - Kconveyor_V.robax.rax_2 + N_VY.num
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)  
  Knext.robax.rax_2 = Kwait.robax.rax_2
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)  
  SetDO("DO_LIGHT",0)
  SetDO("DO_V1",0)
  SetDO("DO_V2",0)
  SetDO("DO_V3",0)
  SetDO("DO_V4",0)
  local _table = {{},{},{},{}}
  
  for var=1,4,1 do
    _table[var] = CopyJointTarget(p_[PR_Tray_Num.num][var])
  end
  local str =  pam_json.encode(_table)

 
  local posfile = io.open("/home/controller/usr/Program/pos"..PR_Tray_Num.num..".json","w")
  io.output(posfile)
  io.write(str)
  Sleep(500)
  posfile:close()    
  
  N_V_step.num = 0
  N_Action.num = 0 - n_visionOnIn 
  
end

--机器视觉识别出口盘的4个梯形块
function visionOnOut()
  N_Action.num = n_visionOnOut
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

  if (PR_Tray_Num.num < 3) or (PR_Tray_Num.num > 6) then
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
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  N_V_step.num = 1
  Knext = CopyJointTarget(p_v[PR_Tray_Num.num][N_V_step.num])
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0)
  SetDO("DO_LIGHT",1)
  
  Knext = CopyJointTarget(p_v[PR_Tray_Num.num][N_V_step.num])
  local h_v = Knext.robax.rax_3
  Knext.robax.rax_3 = h_v - (PR_layers.num - 1) * N_productHeight.num
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  
  Sleep(500)
  N_V.num = 1
  WaitDO("DO_V1",1,30000,false)
  N_V.num = 0
  N_V_step.num = N_V_step.num + 1
  
  Knext = CopyJointTarget(p_v[PR_Tray_Num.num][N_V_step.num])
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  Sleep(500)
  N_V.num = 1
  WaitDO("DO_V2",1,30000,false)
  N_V.num = 0
  N_V_step.num = N_V_step.num + 1
  
  Knext = CopyJointTarget(p_v[PR_Tray_Num.num][N_V_step.num])
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  Sleep(500)
  N_V.num = 1
  WaitDO("DO_V3",1,30000,false)
  N_V.num = 0
  N_V_step.num = N_V_step.num + 1
  
  Knext = CopyJointTarget(p_v[PR_Tray_Num.num][N_V_step.num])
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  Sleep(500)
  N_V.num = 1
  WaitDO("DO_V4",1,30000,false)
  N_V.num = 0

  local offset = 0
  if PR_Tray_Num.num == 4 then
    offset = 1185
  end
  if PR_Tray_Num.num == 5 then
    offset = 1185 + 1550
  end  
  if PR_Tray_Num.num == 6 then
    offset = 1185 + 1550 + 1185
  end    
  local p__ = out_poses[PR_Tray_Num.num]
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
  
  local ret = 1
  local angle = angleBetweenPoints(p__[1].robax.rax_1,p__[1].robax.rax_2,p__[10].robax.rax_1,p__[10].robax.rax_2)
  if ((angle>-89.5) or (angle<-90.5)) then
    S_Error.str = "tray has rotation : "..angle
    N_Error.num = n_visionOnOut + 4
    TPWrite("angle:"..angle)
    ret = 0
  end
  
  local str = pam_json.encode(p__)
  local posfile = io.open("/home/controller/usr/Program/pos"..PR_Tray_Num.num..".json","w")
  io.output(posfile)
  io.write(str)
  Sleep(500)
  posfile:close()  
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)  
  Knext.robax.rax_2 = Kwait.robax.rax_2
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)  
  SetDO("DO_LIGHT",0)  
  SetDO("DO_V1",0)
  SetDO("DO_V2",0)
  SetDO("DO_V3",0)
  SetDO("DO_V4",0)
  N_V_step.num =0

  
  return ret
  
end

function getDistanceByK(K1,K2)
  local _x = math.abs(K1.robax.rax_1 - K2.robax.rax_1)
  local _y = math.abs(K1.robax.rax_2 - K2.robax.rax_2)
  local _z = math.abs(K1.robax.rax_3 - K2.robax.rax_3)
  
  local distance = (_x^2 + _y^2 + _z^2 + 0.0001)^0.5
  return distance
end

--从硬盘读取保存的机器视觉偏移量
function getConfig()
  local p_ = {{K1LB,K1LT,K1RT,K1RB},{K2LB,K2LT,K2RT,K2RB}}
  for var=1,2,1 do

    local readfile = io.open("/home/controller/usr/Program/pos"..var..".json","r")
    local readf = readfile:read("*a")
    readfile:close()
    local posistions = pam_json.decode(readf)

    local var2=0

    for var2=1,4,1 do
      p_[var][var2].robax.rax_1 = posistions[var2].robax.rax_1
      p_[var][var2].robax.rax_2 = posistions[var2].robax.rax_2
    end
  end 
    
  for var=3,6,1 do

    local readfile = io.open("/home/controller/usr/Program/pos"..var..".json","r")
    local readf = readfile:read("*a")
    readfile:close()
    local posistions = pam_json.decode(readf)
    out_poses[var] = posistions;
    TPWrite("x:"..out_poses[var][1].robax.rax_1.."/y:"..out_poses[var][1].robax.rax_2)
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
SetDO("DO_UP",1)


getConfig()
     
while true do
  Sleep(10)
  WaitDO("DO_PgReset",1)
  Sleep(PLC_DELAY)
  
  while ((PR_Pro_Num.num ~= 2) and (PR_Pro_Num.num ~= 3) and (PR_Pro_Num.num ~= 4) and (PR_Pro_Num.num ~= 8) and (PR_Pro_Num.num ~= 9)) do
    Sleep(100)
  end
  SetDO("DO_PgReset",0)
  if (PR_ProductCategory.num == 1) or (PR_ProductCategory.num == 3) then
    N_productHeight.num = 166
  elseif (PR_ProductCategory.num == 2) or (PR_ProductCategory.num == 4) then
    N_productHeight.num = 332        
  end
  
  if PR_Pro_Num.num == 2 then
    visionOnConveyor()
    SetDO("DO_PgReset",0)
    WaitDO("DO_AllowCrawl",1)
    grabFromConveyor()
    WaitDO("DO_AllowCrawl",0)
    Sleep(PLC_DELAY)
    while (PR_Tray_Num.num == 0) do
      Sleep(100)
    end
    if PR_Tray_Num.num <= 6 and PR_Tray_Num.num >= 3 then
      grabToOut()
    elseif PR_Tray_Num.num == 7 then
      grabToCart()
    elseif PR_Tray_Num.num == 13 then
      grabToCache()
    end
  elseif PR_Pro_Num.num == 3 then

    WaitDO("DO_AllowCrawl",1)
    grabFromIn()
    SetDO("DO_PgReset",0)
    WaitDO("DO_AllowCrawl",0)
    Sleep(PLC_DELAY)
    grabToRGV()
  elseif PR_Pro_Num.num == 4 then

    WaitDO("DO_AllowCrawl",1)
    grabFromCache()
    SetDO("DO_PgReset",0)
    WaitDO("DO_AllowCrawl",0)
    Sleep(PLC_DELAY)
    grabToOut()

  elseif PR_Pro_Num.num == 8 then
    WaitDO("DO_AllowCrawl",1)
    suckPartition()
    SetDO("DO_PgReset",0)
    WaitDO("DO_AllowCrawl",0)
    Sleep(PLC_DELAY)
    placePartition()
  elseif PR_Pro_Num.num == 9 then
    while ((PR_Tray_Num.num < 1) or (PR_Tray_Num.num > 6)) do
      Sleep(100)
    end
    if PR_Tray_Num.num <= 2 then
      visionOnIn()
    elseif (PR_Tray_Num.num >=3) and (PR_Tray_Num.num <= 6) then
      while visionOnOut()==0 do
        Stop()
      end
       N_Action.num = 0 - n_visionOnOut 
    end
    SetDO("DO_PgReset",0)
    Sleep(PLC_DELAY)
    toWaitYZ()
  end
  SetDO("DO_PgReset",0)
end


local function GLOBALDATA_DEFINE()
SPEEDDATA("v50",50.000,500.000,50.000,70.000)
SPEEDDATA("v250",250.000,500.000,250.000,70.000)
SPEEDDATA("v300",300.000,500.000,300.000,70.000)
SPEEDDATA("v400",400.000,500.000,400.000,70.000)
SPEEDDATA("v600",600.000,500.000,600.000,70.000)
SPEEDDATA("v800",800.000,500.000,800.000,70.000)

NUMDATA("N_CacheX",1)
NUMDATA("N_CacheY",1)
NUMDATA("N_CartX",1)
NUMDATA("N_CartY",2)
NUMDATA("N_CartZ",2)
NUMDATA("N_Color",2)

NUMDATA("N_In1X",1)
NUMDATA("N_In1Y",1)
NUMDATA("N_In1Z",3)
NUMDATA("N_In2X",1)
NUMDATA("N_In2Y",2)
NUMDATA("N_In2Z",3)
NUMDATA("N_Out3I",6)
NUMDATA("N_Out3Z",1)
NUMDATA("N_Out4I",1)
NUMDATA("N_Out4Z",2)
NUMDATA("N_Out5I",12)
NUMDATA("N_Out5Z",1)
NUMDATA("N_Out6I",1)
NUMDATA("N_Out6Z",2)
NUMDATA("N_RGV",0)
NUMDATA("N_V",0)
NUMDATA("N_VX",-1321)
NUMDATA("N_VX1",-5226)
NUMDATA("N_VX10",-5230)
NUMDATA("N_VX11",-4970)
NUMDATA("N_VX12",-4711)
NUMDATA("N_VX2",-4966)
NUMDATA("N_VX3",-4706)
NUMDATA("N_VX4",-5226)
NUMDATA("N_VX5",-4967)
NUMDATA("N_VX6",-4708)
NUMDATA("N_VX7",-5228)
NUMDATA("N_VX8",-4969)
NUMDATA("N_VX9",-4709)
NUMDATA("N_VY",226)
NUMDATA("N_VY1",1681)
NUMDATA("N_VY10",896)
NUMDATA("N_VY11",896)
NUMDATA("N_VY12",894)
NUMDATA("N_VY2",1677)
NUMDATA("N_VY3",1676)
NUMDATA("N_VY4",1418)
NUMDATA("N_VY5",1416)
NUMDATA("N_VY6",1414)
NUMDATA("N_VY7",1156)
NUMDATA("N_VY8",1155)
NUMDATA("N_VY9",1154)
NUMDATA("N_V_step",1)
NUMDATA("N_conveyorR",-44)
NUMDATA("N_productHeight",166)
NUMDATA("PR_Buffer_Num",1)
NUMDATA("PR_PgReset",0)
NUMDATA("PR_Pro_Num",3)
NUMDATA("PR_ProductCategory",1)
NUMDATA("PR_Rob_pos_put",1)
NUMDATA("PR_Tray_Num",2)
NUMDATA("PR_destackingNum",54)
NUMDATA("PR_layers",6)
JOINTTARGET("K1LB",{-9727.010,1712.370,-765.417,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1LBV",{-9903.640,1705.240,-1044.960,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1LT",{-9721.760,838.815,-760.058,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1LTV",{-9896.770,833.095,-1044.950,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1RB",{-8524.500,1713.230,-758.983,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1RBV",{-8700.420,1706.800,-1044.960,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1RT",{-8522.530,840.578,-759.956,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1RTV",{-8697.210,845.078,-1044.990,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2LB",{-17913.801,1713.690,-758.815,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
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
JOINTTARGET("K4_V1",{-4096.510,1337.200,-189.079,-90.002,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V2",{-3416.520,1339.350,-189.110,-89.995,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V3",{-4087.870,840.521,-189.081,-90.004,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V4",{-3402.150,840.521,-189.087,-89.996,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V1",{-2546.510,1337.200,-189.079,-90.002,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V2",{-1866.520,1339.350,-189.110,-89.995,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V3",{-2537.870,840.521,-189.081,-90.004,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V4",{-1852.140,840.521,-189.087,-89.996,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6RT",{-773.941,881.847,-80.254,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V1",{-1361.510,1337.200,-189.079,-90.002,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V2",{-681.520,1339.350,-189.110,-89.995,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V3",{-1352.870,840.521,-189.081,-90.004,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V4",{-667.140,840.521,-189.087,-89.996,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP3",{-5051.230,1279.610,-137.190,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP3U",{-5051.230,1279.610,-950.190,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP4",{-3868.040,1294.850,-137.842,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP4U",{-3868.040,1294.850,-950.842,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP5",{-2314.530,1279.590,-145.796,-179.432,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP5U",{-2326.280,1279.610,-950.842,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP6",{-1138.400,1277.440,-137.201,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP6U",{-1138.400,1277.440,-950.201,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV1",{-5826.130,1359.440,-99.000,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV1U",{-5826.130,1359.440,-1297.000,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV2",{-5828.520,1042.400,-97.353,-90.010,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV2U",{-5828.520,1042.400,-1212.570,-90.010,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV3",{-5831.770,719.762,-98.921,-90.008,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV3U",{-5829.070,712.820,-1297.000,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV4",{-5833.760,402.316,-92.541,-89.995,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV4U",{-5833.770,398.240,-1297.000,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV5",{-5836.220,79.901,-98.554,-89.996,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV5U",{-5836.210,79.904,-1171.080,-89.996,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcacheCorner",{-8706.230,57.436,-184.931,-90.014,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcacheCornerU",{-8706.230,57.434,-1297.000,-90.014,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcartCorner",{-9759.480,21.7,-190.537,-178.075,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcartCorner_U",{-9759.480,21.7,-1297.000,-178.075,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Kconveyor",{-1319.660,227.076,-111.054,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KconveyorU",{-1506.900,181.091,-626.322,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Kconveyor_V",{-1506.900,181.091,-246.322,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})

JOINTTARGET("Knext",{0.000,0.000,0.000,0.000,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Ksuck",{-23.582,1225.050,-175.355,-179.097,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KsuckOffset_U",{-23.584,1173.020,-755.609,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Ksuck_U",{-23.582,1225.050,-755.615,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Kwait",{-5716.540,350.441,-1297.000,-90.331,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
ROBTARGET("Psuck",{-23.580,1225.050,-175.360},{0.007874,0.000000,0.000000,-0.999969},{-2,0,0,0},{0.000,0.000,0.000,0.000,0.000,0.000,0.000},0.000)
ROBTARGET("Psuck_D",{-23.581,1225.050,-409.835},{0.007874,0.000000,0.000000,-0.999969},{-2,0,0,0},{0.000,0.000,0.000,0.000,0.000,0.000,0.000},0.000)
ROBTARGET("Psuck_U",{-23.580,1225.050,-755.620},{0.007874,0.000000,0.000000,-0.999969},{-2,0,0,0},{0.000,0.000,0.000,0.000,0.000,0.000,0.000},0.000)
STRINGDATA("S_Code","0")

end
print("The end!")