local cjson = require "cjson"
local pam_json = cjson.new()

--程序执行号
local n_grabFromIn=100
local n_carryToCache=200
local n_grabFromCache=300
local n_carryToCart=400
local n_toWait=500
local n_visionOnConveyor=600
local n_grabFromConveyor=700
local n_carrayToOut=800
local n_carryToRGV=900
local n_suckPartition=1000
local n_placePartition=1100
local n_visionOnIn=1200
local n_visionOnOut=1300
local n_visionOnPartition=1400
local n_correctPartition=1500
local n_toWaitYZ=1600
local n_getConfig=1700
local n_function=1800
local n_laserOnCart=1900
--在安全高度层运行
local n_safeHeight=-1297
--单抓矮轮第六层时的高度
local n_grablInHeight = -765
--吸隔板运动到刷子附近时高度,需要额外处理,要降速
local n_suckUpSlowly = -569.56
local n_cacheOffsetX=300
local n_cacheOffsetY=330
local n_cartOffsetX=300
local n_cartOffsetY=270
local n_putOutH = -80.254
local n_conveyor = -111.054
local n_cameraToCenter = 170

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

function angleBetweenPoints(Ax, Ay, Bx, By)
    local dx = Bx - Ax
    local dy = By - Ay
    return math.deg(math.atan2(dy, dx))
end

--打开爪子
function openGrab()
  SetDO("DO_Grabbing",0)
  SetDO("DO_OPEN",1)
  SetDO("DO_CLOSE",0)
  WaitDI("DI_CLOSE",0)
  Sleep(500)
  WaitDI("DI_OPEN",1)  
end

--关闭爪子
function closeGrab()
  WaitDI("DI_UNDER",1)  
  SetDO("DO_OPEN",0)
  SetDO("DO_CLOSE",1)
  WaitDI("DI_OPEN",0)
  Sleep(500)
  WaitDI("DI_CLOSE",1)
  SetDO("DO_Grabbing",1)
end

--隔板吸关闭
function stopSuck()
  SetDO("DO_SUCK",0)
  Sleep(2000)
  WaitDI("DI_AIR_LEFT",1)
  WaitDI("DI_AIR_RIGHT",1)  
  SetDO("DO_Grabbing",0)
end

--从缓存台抓轮盘
function grabFromCache()
  N_Action.num = n_grabFromCache
  WaitDI("DI_UNDER",0)  
  while ((PR_Buffer_Num.num < 1) or (PR_Buffer_Num.num > 18))  do
    S_Error.str = "PR_Buffer_Num should between 1 and 18"
    N_Error.num =  n_carryToCache + 2
    TPWrite(S_Error.str)
    Sleep(1000)
  end  
  local x = PR_Buffer_Num.num
  local y = 1  
  if (x > 9) then
      y = 2
      x = x - 9 
  end
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)  
  local offset_x = (x - 1) * n_cacheOffsetX
  local offset_y = (y - 1) * n_cacheOffsetY
  Knext = CopyJointTarget(KcacheCorner)
  Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
  Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y
  Knext.robax.rax_3 = n_safeHeight  
  TPWrite("X:"..Knext.robax.rax_1.."/Y:"..Knext.robax.rax_2.."/Z:"..Knext.robax.rax_3)
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0)
  openGrab()
  Knext.robax.rax_3 = KcacheCorner.robax.rax_3 + 166 - N_productHeight.num - 70
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = KcacheCorner.robax.rax_3 + 166 - N_productHeight.num
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)
  closeGrab()  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0) 
  N_Action.num = 0 - n_grabFromCache
end

--满盘抓取从滚筒末端到缓存区
function carryToCache()
  N_Action.num = n_carryToCache
  WaitDI("DI_UNDER",1)  
  while ((PR_Buffer_Num.num < 1) or (PR_Buffer_Num.num > 18))  do
    S_Error.str = "PR_Buffer_Num should between 1 and 18"
    N_Error.num =  n_carryToCache + 2
    TPWrite(S_Error.str)
    Sleep(1000)
  end  
  local x = PR_Buffer_Num.num
  local y = 1  
  if (x > 9) then
      y = 2
      x = x - 9 
  end
  --为了方便调试,手动示教模式下可以快速定位
  if 1>2 then
    MoveAbsJ(CacheCornerU,v_safeHeight,fine,tool0,wobj0,load0)
    MoveAbsJ(CacheCorner,v_safeHeight,fine,tool0,wobj0,load0)
  end
  --升到安全高度
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  local offset_x = (x - 1) * n_cacheOffsetX
  local offset_y = (y - 1) * n_cacheOffsetY
  Knext = CopyJointTarget(KcacheCorner)
  Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
  Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y
  Knext.robax.rax_3 = n_safeHeight  
  TPWrite("X:"..Knext.robax.rax_1.."/Y:"..Knext.robax.rax_2.."/Z:"..Knext.robax.rax_3)  
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = KcacheCorner.robax.rax_3
  if N_productHeight.num == 332 then
    Knext.robax.rax_3 = KcacheCorner.robax.rax_3 - 166
  end
  local h_grab = Knext.robax.rax_3
  Knext.robax.rax_3 = h_grab - 70
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = h_grab
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)
  openGrab()  
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)  
  N_Action.num = 0 - n_carryToCache
end

--满盘抓取从滚筒末端到不良品小车
function carryToCart()
  N_Action.num = n_carryToCart
  WaitDI("DI_UNDER",1)  
  while ((PR_Buffer_Num.num < 1) or (PR_Buffer_Num.num > 12))  do
    S_Error.str = "PR_Buffer_Num wrong:"..PR_Buffer_Num.num
    N_Error.num =  n_carryToCart + 2
    TPWrite(S_Error.str)
    Sleep(1000)
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
  --为了方便调试,手动示教模式下可以快速定位
  if 1>2 then
    MoveAbsJ(KcartCornerU,v_safeHeight,fine,tool0,wobj0,load0)
    MoveAbsJ(KcartCorner,v_safeHeight,fine,tool0,wobj0,load0)
  end
  --当前位置上升到安全高度
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  
  local offset_x = (x - 1) * n_cartOffsetX
  local offset_y = (y - 1) * n_cartOffsetY
  Knext = CopyJointTarget(KcartCorner)
  Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
  Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y  
  Knext.robax.rax_3 = n_safeHeight  
  TPWrite("X:"..Knext.robax.rax_1.."/Y:"..Knext.robax.rax_2.."/Z:"..Knext.robax.rax_3)  
  --高速水平移动到放置点安全高度
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0)
  local h_grab = KcartCorner.robax.rax_3 + 166 - N_productHeight.num * z
  Knext.robax.rax_3 = h_grab - 70
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = KcartCorner.robax.rax_3 + 166 - N_productHeight.num * z
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)
  openGrab()
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  N_Action.num = 0 - n_carryToCart
end

--空盘抓取放置到小车
function carryToRGV()
  N_Action.num = n_carryToRGV
  --判断爪子下有没有轮子
  WaitDI("DI_UNDER",1)  
  
  --上升到安全高度
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  --验证PLC数据准确性
  while ((PR_Rob_pos_put.num ~= 1) and (PR_Rob_pos_put.num ~= 3) and (PR_Rob_pos_put.num ~= 5) and (PR_Rob_pos_put.num ~= 7) and (PR_Rob_pos_put.num ~= 9)) do
    S_Error.str = "PR_Rob_pos_put is wrong:"..PR_Rob_pos_put.num
    N_Error.num = n_carryToRGV + 2
    TPWrite(S_Error.str)
    Sleep(1000)
  end  
  
  if PR_Rob_pos_put.num == 1 then
    MoveAbsJ(KRGV1U,v_safeHeight,fine,tool0,wobj0,load0)
    if N_productHeight.num == 166 then      
      MoveAbsJ(KRGV1S,v_vertical,fine,tool0,wobj0,load0)
      MoveAbsJ(KRGV1,v_grab,fine,tool0,wobj0,load0)    
      openGrab()      
    elseif N_productHeight.num == 332 then
      MoveAbsJ(KRGVH1S,v_vertical,fine,tool0,wobj0,load0)
      MoveAbsJ(KRGVH1,v_grab,fine,tool0,wobj0,load0)    
      openGrab()
    else
      Stop()
    end
    MoveAbsJ(KRGV1U,v_vertical,fine,tool0,wobj0,load0)
  elseif PR_Rob_pos_put.num == 3 then
    MoveAbsJ(KRGV2U,v_safeHeight,fine,tool0,wobj0,load0)
    if N_productHeight.num == 166 then      
      MoveAbsJ(KRGV2S,v_vertical,fine,tool0,wobj0,load0)
      MoveAbsJ(KRGV2,v_grab,fine,tool0,wobj0,load0)    
      openGrab()      
    elseif N_productHeight.num == 332 then
      MoveAbsJ(KRGVH2S,v_vertical,fine,tool0,wobj0,load0)
      MoveAbsJ(KRGVH2,v_grab,fine,tool0,wobj0,load0)    
      openGrab()
    else
      Stop()
    end
    MoveAbsJ(KRGV2U,v_vertical,fine,tool0,wobj0,load0)
  elseif PR_Rob_pos_put.num == 5 then
    MoveAbsJ(KRGV3U,v_safeHeight,fine,tool0,wobj0,load0)
    if N_productHeight.num == 166 then      
      MoveAbsJ(KRGV3S,v_vertical,fine,tool0,wobj0,load0)
      MoveAbsJ(KRGV3,v_grab,fine,tool0,wobj0,load0)    
      openGrab()      
    elseif N_productHeight.num == 332 then
      MoveAbsJ(KRGVH3S,v_vertical,fine,tool0,wobj0,load0)
      MoveAbsJ(KRGVH3,v_grab,fine,tool0,wobj0,load0)    
      openGrab()
    else
      Stop()
    end
    MoveAbsJ(KRGV3U,v_vertical,fine,tool0,wobj0,load0)
  elseif PR_Rob_pos_put.num == 7 then
    MoveAbsJ(KRGV4U,v_safeHeight,fine,tool0,wobj0,load0)
    if N_productHeight.num == 166 then      
      MoveAbsJ(KRGV4S,v_vertical,fine,tool0,wobj0,load0)
      MoveAbsJ(KRGV4,v_grab,fine,tool0,wobj0,load0)    
      openGrab()      
    elseif N_productHeight.num == 332 then
      MoveAbsJ(KRGVH4S,v_vertical,fine,tool0,wobj0,load0)
      MoveAbsJ(KRGVH4,v_grab,fine,tool0,wobj0,load0)    
      openGrab()
    else
      Stop()
    end
    MoveAbsJ(KRGV4U,v_vertical,fine,tool0,wobj0,load0)
  elseif PR_Rob_pos_put.num == 9 then
    MoveAbsJ(KRGV5U,v_safeHeight,fine,tool0,wobj0,load0)
    if N_productHeight.num == 166 then      
      MoveAbsJ(KRGV5S,v_vertical,fine,tool0,wobj0,load0)
      MoveAbsJ(KRGV5,v_grab,fine,tool0,wobj0,load0)    
      openGrab()      
    elseif N_productHeight.num == 332 then
      MoveAbsJ(KRGVH5S,v_vertical,fine,tool0,wobj0,load0)
      MoveAbsJ(KRGVH5,v_grab,fine,tool0,wobj0,load0)    
      openGrab()
    else
      Stop()
    end
    MoveAbsJ(KRGV5U,v_vertical,fine,tool0,wobj0,load0)
  else
    Stop()
  end
  
  N_Action.num = 0 - n_carryToRGV
end

--视觉识别滚筒末端
function visionOnConveyor()
  N_Action.num = n_visionOnConveyor
  WaitDI("DI_UNDER",0)
  --当前位置上升到安全高度
  S_Vision.str = "000025#0111@0009&0004,0,0;0000#"
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  MoveAbsJ(KconveyorVU,v_safeHeight,fine,tool0,wobj0,load0)
  SetDO("DO_LIGHT",1)
  if N_productHeight.num == 166 then
    MoveAbsJ(KconveyorV,v_vertical,fine,tool0,wobj0,load0)  
  elseif N_productHeight.num == 332 then
    MoveAbsJ(KconveyorVH,v_vertical,fine,tool0,wobj0,load0)  
  else 
    Stop()
  end   
  Sleep(800)
  N_VX.num = 0
  N_VY.num = 0
  N_conveyorR.num = 361
  while ((N_VX.num == 0) or (N_VY.num == 0)  or (N_conveyorR.num == 361)) do
    Sleep(100)
  end  
  N_Action.num = 0 - n_visionOnConveyor  
end

--从滚筒末端抓取
function grabFromConveyor()
  --如果上一个动作不是  拍滚筒线末端  ,就报错
  if N_Action.num ~= (0 - n_visionOnConveyor) then
    Stop()
  end
  N_Action.num = n_grabFromConveyor
  SetDO("DO_LIGHT",0)
  SetDO("DO_UP",1)  
  --当前位置做旋转,旋转值来自 视觉拍照 计算出的 N_conveyorR + 45 
  --之所以加45是为了跟卡扣有夹角
  local current = GetJointTarget("Xyzw")
  Kconveyor.robax.rax_4 = N_conveyorR.num + 45
  --桁架的转角只支持 -180 到 180 
  if Kconveyor.robax.rax_4 > 180 then
    Kconveyor.robax.rax_4 = Kconveyor.robax.rax_4 - 360
  end
  if Kconveyor.robax.rax_4 < -180 then
    Kconveyor.robax.rax_4 = Kconveyor.robax.rax_4 + 360
  end
  Kconveyor.robax.rax_3 = current.robax.rax_3
  --X Y的坐标来自视觉
  Kconveyor.robax.rax_1 = N_VX.num
  Kconveyor.robax.rax_2 = N_VY.num  
  MoveAbsJ(Kconveyor,v_grab,fine,tool0,wobj0,load0)
  --打开爪子准备抓轮子
  openGrab()
  if N_productHeight.num == 166 then
    Kconveyor.robax.rax_3 = n_conveyor
  elseif N_productHeight.num == 332 then
    Kconveyor.robax.rax_3 = n_conveyor - 166
  end
  MoveAbsJ(Kconveyor,v_grab,fine,tool0,wobj0,load0)
  closeGrab()
  Kconveyor.robax.rax_3 = current.robax.rax_3
  MoveAbsJ(Kconveyor,v_grab,fine,tool0,wobj0,load0)
  MoveAbsJ(KconveyorVU,v_vertical,fine,tool0,wobj0,load0)
  N_Action.num = 0 - n_grabFromConveyor
end

--装箱位放置
function carryToOut()
  N_Action.num = n_carrayToOut
  SetDO("DO_LIGHT",0)
  WaitDI("DI_UNDER",1)
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    SetDO("DO_UP",1)  
    Sleep(3000)
  end
  WaitDI("DI_AIR_UP",1)
  WaitDI("DI_AIR_DOWN",0)
  while ((PR_Tray_Num.num < 3) or (PR_Tray_Num.num > 6)) do
    S_Error.str = "N_Tray num is wrong:"..PR_Tray_Num.num 
    N_Error.num =  n_carrayToOut + 3
    TPWrite(S_Error.str)
    Sleep(1000)
  end    
  local PR_layers_max = 3
  local PR_Rob_pos_put_max = 36
  if N_productHeight.num == 166 then
    PR_Rob_pos_put_max = 72
    PR_layers_max = 6
  end
  while ((PR_layers.num <1) or (PR_layers.num > PR_layers_max )) do
    S_Error.str = "PR_layers is wrong :"..PR_layers.num
    N_Error.num =  n_carrayToOut + 4
    TPWrite(S_Error.str)
    Sleep(1000)
  end
  while ((PR_Rob_pos_put.num <1) or (PR_Rob_pos_put.num > PR_Rob_pos_put_max ) ) do
    S_Error.str = "PR_Rob_pos_put num is wrong:"..PR_Rob_pos_put.num
    N_Error.num =  n_carrayToOut + 5
    TPWrite(S_Error.str)
    Sleep(1000)
  end  
  local idx = PR_Rob_pos_put.num - (PR_layers.num - 1) * 12
  if idx < 1 then
    S_Error.str = "PR_Rob_pos_put or PR_layers is wrong:"..PR_Rob_pos_put.num.."/"..PR_layers.num
    N_Error.num =  n_carrayToOut + 5
    TPWrite(S_Error.str)
    Stop()
  end
  
  --上升到安全高度
  Knext = GetJointTarget ("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)

  local poses = out_poses[PR_Tray_Num.num]
  --摆放顺序,是从中间开始摆放的
  local _p_1_12 = {poses[8],poses[5],poses[7],poses[6],poses[4],poses[9],poses[1],poses[12],poses[2],poses[11],poses[3],poses[10]}

  --为了让所有卡扣都朝内,12个位置的摆放角度都是不同的
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
 
  --水平移动到装箱位的安全高度,水平坐标要根据摆放坐标,向外侧偏移15毫米,避免跟已经摆放好的轮子相撞
  Knext = _p_1_12[idx]
  Knext.robax.rax_3 = n_safeHeight 
  --先记住正确的位置
  local x = Knext.robax.rax_1
  local y = Knext.robax.rax_2
  local _x = x
  local _y = y
  local diff = 18
  if idx == 1 then
    _x = x 
    _y = y
  elseif idx == 2 then
    _x = x 
    _y = y + diff
  elseif idx == 3 then
    _x = x - diff
    _y = y
  elseif idx == 4 then
    _x = x + diff
    _y = y
  elseif idx == 5 then
    _x = x - diff 
    _y = y + diff
  elseif idx == 6 then
    _x = x + diff
    _y = y - diff
  elseif idx == 7 then
    _x = x 
    _y = y + diff
  elseif idx == 8 then
    _x = x 
    _y = y - diff
  elseif idx == 9 then
    _x = x + diff
    _y = y + diff
  elseif idx == 10 then
    _x = x - diff
    _y = y - diff
  elseif idx == 11 then
    _x = x + diff 
    _y = y + diff
  elseif idx == 12 then
    _x = x - diff
    _y = y - diff
  end
  Knext.robax.rax_1 = _x
  Knext.robax.rax_2 = _y
  TPWrite("x:"..Knext.robax.rax_1.."/y:"..Knext.robax.rax_2.."/idx:"..idx)  
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0)  
  local putHeight = n_putOutH + 166 - PR_layers.num * N_productHeight.num  
  --垂直向下运动到放置位上方70毫米处
  Knext.robax.rax_3 = putHeight - 70
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0) 
  --向内水平移动一下 
  Knext.robax.rax_1 = x
  Knext.robax.rax_2 = y
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)
  --放好
  Knext.robax.rax_3 = putHeight  
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)
  openGrab()
  --打开爪子然后升起来到安全高度
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  --水平移动到纵向安全位置,相机方向朝外
  local current = GetJointTarget ("Xyzw")
  current.robax.rax_2 = Kwait.robax.rax_2
  current.robax.rax_4 = -90
  MoveAbsJ(current,v_vertical,fine,tool0,wobj0,load0)

  N_Action.num = 0 - n_carrayToOut
end

--放置隔板
function placePartition()
  N_Action.num = n_placePartition
  WaitDI("DI_UNDER",1)  
  while ((PR_Tray_Num.num < 3) or (PR_Tray_Num.num > 6)) do
    S_Error.str = "PR_Tray_Num is wrong:"..PR_Tray_Num.num
    N_Error.num = n_placePartition + 2
    TPWrite(S_Error.str)
    Sleep(1000)
  end  
  while ((PR_layers.num < 2) or (PR_layers.num > 6)) do
    S_Error.str = "PR_layers is wrong:"..PR_layers.num
    N_Error.num = n_placePartition + 3
    TPWrite(S_Error.str)
    Sleep(1000)
  end 
  
  Knext = GetJointTarget ("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)  
  
  --将视觉拍隔板识别出来的12个点的1号跟12号的坐标的中间点,作为隔板放置中心点
  local poses12 = out_poses[PR_Tray_Num.num]
  local center_x = (poses12[1].robax.rax_1 + poses12[12].robax.rax_1)/2
  local center_y = (poses12[1].robax.rax_2 + poses12[12].robax.rax_2)/2
  --水平移动到放隔板的安全高度
  Knext.robax.rax_1 = center_x - 98.374 -2
  Knext.robax.rax_2 = center_y - 2.183 + 5
  Knext.robax.rax_3 = n_safeHeight
  Knext.robax.rax_4 = -179.098
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0) 
  WaitDI("DI_UNDER",1)
  local h_grab = -137.190 + 166 - (PR_layers.num   - 1) * N_productHeight.num
  Knext.robax.rax_3 = h_grab - 80
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)    
  Knext.robax.rax_3 = h_grab
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)  
  stopSuck()
  Knext.robax.rax_3 = Knext.robax.rax_3 - 80
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)    
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)  
  SetDO("DO_UP",1)
  Knext.robax.rax_2 = Kwait.robax.rax_2
  Knext.robax.rax_4 = -90
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0)
  
  N_Action.num = 0 - n_placePartition
end

--吸取隔板
function suckPartition()
  N_Action.num = n_suckPartition
  WaitDI("DI_UNDER",0)
  SetDO("DO_LIGHT",0)
  --放下吸板
  SetDO("DO_UP",0)
  SetDO("DO_SUCK",0)
  --上升到安全位置
  Knext = GetJointTarget ("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)  
  --水平移动到隔板收纳槽
  Knext = CopyJointTarget( KsuckOffset_U )
  Knext.robax.rax_3 = n_safeHeight
  TPWrite("x:"..Knext.robax.rax_1.."/y:"..Knext.robax.rax_2)
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0)  
  MoveAbsJ(KsuckOffset_U,v_vertical,fine,tool0,wobj0,load0)
  --TODO,按何工建议使用测距仪做高度检测,等光源支架安装好后再做
  MoveAbsJ(Ksuck_U,v_vertical,fine,tool0,wobj0,load0)
  WaitDI("DI_AIR_UP",0)
  WaitDI("DI_AIR_DOWN",1)
  --左右两个吸压板要有吸力
  WaitDI("DI_AIR_LEFT",1)
  WaitDI("DI_AIR_RIGHT",1)
  --慢速下降,同时检测爪子下的漫反射开关是否被触发
  local ret = SearchL("DI_UNDER",1,Psuck_D,Psuck,v_grab,tool0,wobj0)
  if ret == true then 
    --如果爪子下的漫反射被触发,就以当前位置下压 152 毫米   
    local current = GetJointTarget("Xyzw")
    current.robax.rax_3 = current.robax.rax_3 + 152.14
    MoveAbsJ(current,v_suckUpSlowly,fine,tool0,wobj0,load0)
    SetDO("DO_SUCK",1)
    Sleep(500)
    if GetDI("DI_AIR_LEFT")==1 then
      local databody = GetRobTarget("Xyzw", tool0, wobj0)    
      local ret2 = SearchL("DI_AIR_LEFT",0,databody,Psuck,v_suckUpSlowly,tool0,wobj0)
    end    
    --保持吸板4秒
    Sleep(3000)
  else
    S_Error.str = "Partition not found "
    N_Error.num = n_suckPartition + 1
    TPWrite(S_Error.str)
    return 0
  end
  --慢慢上抬到 刷子 区域
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_suckUpSlowly
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)
  --很慢的速度上抬
  Knext.robax.rax_3 = n_suckUpSlowly - 166  
  MoveAbsJ(Knext,v_suckUpSlowly,fine,tool0,wobj0,load0)
  --快速上抬到安全高度
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  --判断板子有没有掉
  if GetDI("DI_UNDER") == 0 then
    S_Error.str = "Partition dropped "
    N_Error.num = n_suckPartition + 1
    TPWrite(S_Error.str)
    return 0
  end
  
  return 1
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
  WaitDI("DI_UNDER",0)  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    SetDO("DO_UP",1)  
    Sleep(3000)
  end  
  WaitDI("DI_AIR_UP",1)
  WaitDI("DI_AIR_DOWN",0)

  while ((PR_Tray_Num.num < 1) or (PR_Tray_Num.num > 2)) do
    S_Error.str = "PR_Tray_Num is wrong:"..PR_Tray_Num.num
    N_Error.num = n_grabFromIn + 3
    TPWrite(S_Error.str)
    Sleep(1000)
  end  
  while ((PR_layers.num <1) or (PR_layers.num > 3 )) do
    S_Error.str = "PR_layers is wrong :"..PR_layers.num
    N_Error.num =  grabFromIn + 5
    TPWrite(S_Error.str)
    Sleep(1000)
  end
  while ((PR_destackingNum.num < 1) or (PR_destackingNum.num > 60)) do
    S_Error.str = "PR_destackingNum is wrong:"..PR_destackingNum.num
    N_Error.num = n_grabFromIn + 4
    TPWrite(S_Error.str)
    Sleep(1000)
  end 
  local index = PR_destackingNum.num - (PR_layers.num -1 ) * 20        
  if index < 1 then
    S_Error.str = "PR_destackingNum or PR_layers is wrong:"..PR_destackingNum.num.."/"..PR_layers.num
    N_Error.num =  n_grabFromIn + 6
    TPWrite(S_Error.str)
    --逻辑故障,直接暂停
    Stop()
  end
  
  SetDO("DO_LIGHT",0)
  
  --当前位置上升到安全高度
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  
  local _LB = K1LB
  local _LT = K1LT
  local _RT = K1RT
  local _RB = K1RB
  if PR_Tray_Num.num == 2 then
    _LB = K2LB
    _LT = K2LT
    _RT = K2RT
    _RB = K2RB
  end
  
  --横向X,纵向Y
  local _x = 1
  local _y = 1
  if (index > 15) and (index <= 20) then 
    _y = 4
  elseif (index > 10) and (index <= 15) then 
    _y = 3
  elseif (index > 5) and (index <= 10) then 
    _y = 2
  end
  _x = index - (_y - 1) * 5
     
  local offset_x = 0
  local offset_y = 0
  local gap_x = 0
  local gap_y = 0
  if (index >= 1) and (index <= 5) then
    local LB_x = _LB.robax.rax_1
    local LB_y = _LB.robax.rax_2    
    local RB_x = _RB.robax.rax_1
    local RB_y = _RB.robax.rax_2    
    gap_x = (RB_x - LB_x)/4
    gap_y = (RB_y - LB_y)/4    
    offset_x = (_x - 1) * gap_x
    offset_y = (_x - 1) * gap_y
    Knext = CopyJointTarget( _LB )
    Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
    Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y 
  elseif (index >= 16) and (index <= 20) then
    local LT_x = _LT.robax.rax_1
    local LT_y = _LT.robax.rax_2    
    local RT_x = _RT.robax.rax_1
    local RT_y = _RT.robax.rax_2    
    gap_x = (RT_x - LT_x)/4
    gap_y = (RT_y - LT_y)/4 
    offset_x = (_x - 1) * gap_x
    offset_y = (_x - 1) * gap_y
    Knext = CopyJointTarget( _LT )
    Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
    Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y 
  elseif (index == 6) or (index == 11) then
    local LT_x = _LT.robax.rax_1
    local LT_y = _LT.robax.rax_2    
    local LB_x = _LB.robax.rax_1
    local LB_y = _LB.robax.rax_2    
    gap_x = (LB_x - LT_x)/3
    gap_y = (LB_y - LT_y)/3    
    if index == 11 then    
      Knext = CopyJointTarget( _LT )
      Knext.robax.rax_1 = Knext.robax.rax_1 + gap_x
      Knext.robax.rax_2 = Knext.robax.rax_2 + gap_y  
    elseif index == 6 then    
      Knext = CopyJointTarget( _LB )
      Knext.robax.rax_1 = Knext.robax.rax_1 - gap_x
      Knext.robax.rax_2 = Knext.robax.rax_2 - gap_y  
    end
  elseif (index == 10) or (index == 15) then
    local RT_x = _RT.robax.rax_1
    local RT_y = _RT.robax.rax_2    
    local RB_x = _RB.robax.rax_1
    local RB_y = _RB.robax.rax_2    
    gap_x = (RB_x - RT_x)/3
    gap_y = (RB_y - RT_y)/3    
    if index == 15 then    
      Knext = CopyJointTarget( _RT )
      Knext.robax.rax_1 = Knext.robax.rax_1 + gap_x
      Knext.robax.rax_2 = Knext.robax.rax_2 + gap_y  
    elseif index == 10 then    
      Knext = CopyJointTarget( _RB )
      Knext.robax.rax_1 = Knext.robax.rax_1 - gap_x
      Knext.robax.rax_2 = Knext.robax.rax_2 - gap_y  
    end    
  elseif (index == 7) or (index == 8) or (index == 9) or (index == 12) or (index == 13) or (index == 14) then
    Knext = CopyJointTarget( _RT )
    local center_x = (_RT.robax.rax_1 + _LT.robax.rax_1 + _RB.robax.rax_1 + _LB.robax.rax_1)/4
    local center_y = (_RT.robax.rax_2 + _LT.robax.rax_2 + _RB.robax.rax_2 + _LB.robax.rax_2)/4    
    gap_x = ((_RT.robax.rax_1 - _LT.robax.rax_1) + (_RB.robax.rax_1 - _LB.robax.rax_1))/2/4
    gap_y = ((_RB.robax.rax_2 - _RT.robax.rax_2) + (_LB.robax.rax_2 - _LT.robax.rax_2))/2/3    
    Knext.robax.rax_1 = center_x + (_x - 3) * gap_x
    Knext.robax.rax_2 = center_y - (_y - 2.5) * gap_y    
  end 
  
  TPWrite("x,y,_x,_y,ox,oy,idx:"..Knext.robax.rax_1..","..Knext.robax.rax_2..",".._x..",".._y..","..offset_x..","..offset_y..","..index)  
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_safeHeight,fine,tool0,wobj0,load0)
  openGrab()
  
  if N_productHeight.num == 166 then
    Knext.robax.rax_3 = n_grablInHeight - 166 + (3 - PR_layers.num) * 332 + 166
  else
    Knext.robax.rax_3 = n_grablInHeight - 166 + (3 - PR_layers.num) * 332
  end
  TPWrite("z:"..Knext.robax.rax_3)
  MoveAbsJ(Knext,v_grab,fine,tool0,wobj0,load0)
  closeGrab()
  
  --抓紧爪子然后升起来到安全高度
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  if _y == 1 then
    Knext.robax.rax_2 = 1500
    MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  end
  Knext.robax.rax_4 = -90
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)

  N_Action.num = 0 - n_grabFromIn
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

--机器视觉拍摄入口盘的4个位置
function visionOnIn()
  N_Action.num = n_visionOnIn
  WaitDI("DI_UNDER",0)
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    SetDO("DO_UP",1)  
  end
  
  WaitDI("DI_AIR_UP",1)
  WaitDI("DI_AIR_DOWN",0)

  while ((PR_Tray_Num.num < 1) or (PR_Tray_Num.num > 2)) do
    S_Error.str = "PR_Tray_Num is wrong : "..PR_Tray_Num.num
    N_Error.num = n_visionOnIn + 3
    TPWrite(S_Error.str)
    Sleep(1000)
  end 
  SetDO("DO_V1",0)

  --当前位置上升到安全高度
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)

  --移动到托盘的左下角的安全高度位置
  if PR_Tray_Num.num == 1 then
    MoveAbsJ(K1LBVU,v_safeHeight,fine,tool0,wobj0,load0)
  elseif PR_Tray_Num.num == 2 then
    MoveAbsJ(K2LBVU,v_safeHeight,fine,tool0,wobj0,load0)
  end
  SetDO("DO_LIGHT",1)  
  S_Vision.str = "000025#0111@0009&0004,0,0;0000#"
  
  --到托盘的4个角拍照,计算出那4个角的托盘的中心点坐标
  for var=1,4,1 do
    if PR_Tray_Num.num == 1 then
      if var == 1 then
        MoveAbsJ(K1LBV,v_vertical,fine,tool0,wobj0,load0)
      elseif var == 2 then
        MoveAbsJ(K1LTV,v_vertical,fine,tool0,wobj0,load0)
      elseif var == 3 then
        MoveAbsJ(K1RTV,v_vertical,fine,tool0,wobj0,load0)
      elseif var == 4 then
        MoveAbsJ(K1RBV,v_vertical,fine,tool0,wobj0,load0)
      end
    elseif PR_Tray_Num.num == 2 then
      if var == 1 then
        MoveAbsJ(K2LBV,v_vertical,fine,tool0,wobj0,load0)
      elseif var == 2 then
        MoveAbsJ(K2LTV,v_vertical,fine,tool0,wobj0,load0)
      elseif var == 3 then
        MoveAbsJ(K2RTV,v_vertical,fine,tool0,wobj0,load0)
      elseif var == 4 then
        MoveAbsJ(K2RBV,v_vertical,fine,tool0,wobj0,load0)
      end
    end
    --通过上位机触发视觉拍照,上位机程序会把拍照反馈的结果赋值到 N_VX 跟 N_VY 
    Sleep(800)
    N_VX.num = 0
    N_VY.num = 0
    while ((N_VX.num == 0) or (N_VY.num == 0)) do
      Sleep(100)
    end 
    --更新托盘位置的坐标
    if PR_Tray_Num.num == 1 then
      if var == 1 then
        K1LB.robax.rax_1 = K1LBV.robax.rax_1 - KconveyorV.robax.rax_1 + N_VX.num
        K1LB.robax.rax_2 = K1LBV.robax.rax_2 - KconveyorV.robax.rax_2 + N_VY.num
      elseif var == 2 then
        K1LT.robax.rax_1 = K1LTV.robax.rax_1 - KconveyorV.robax.rax_1 + N_VX.num
        K1LT.robax.rax_2 = K1LTV.robax.rax_2 - KconveyorV.robax.rax_2 + N_VY.num
      elseif var == 3 then
        K1RT.robax.rax_1 = K1RTV.robax.rax_1 - KconveyorV.robax.rax_1 + N_VX.num
        K1RT.robax.rax_2 = K1RTV.robax.rax_2 - KconveyorV.robax.rax_2 + N_VY.num
      elseif var == 4 then
        K1RB.robax.rax_1 = K1RBV.robax.rax_1 - KconveyorV.robax.rax_1 + N_VX.num
        K1RB.robax.rax_2 = K1RBV.robax.rax_2 - KconveyorV.robax.rax_2 + N_VY.num
      end
    elseif PR_Tray_Num.num == 2 then
      if var == 1 then
        K2LB.robax.rax_1 = K2LBV.robax.rax_1 - KconveyorV.robax.rax_1 + N_VX.num
        K2LB.robax.rax_2 = K2LBV.robax.rax_2 - KconveyorV.robax.rax_2 + N_VY.num
      elseif var == 2 then
        K2LT.robax.rax_1 = K2LTV.robax.rax_1 - KconveyorV.robax.rax_1 + N_VX.num
        K2LT.robax.rax_2 = K2LTV.robax.rax_2 - KconveyorV.robax.rax_2 + N_VY.num
      elseif var == 3 then
        K2RT.robax.rax_1 = K2RTV.robax.rax_1 - KconveyorV.robax.rax_1 + N_VX.num
        K2RT.robax.rax_2 = K2RTV.robax.rax_2 - KconveyorV.robax.rax_2 + N_VY.num
      elseif var == 4 then
        K2RB.robax.rax_1 = K2RBV.robax.rax_1 - KconveyorV.robax.rax_1 + N_VX.num
        K2RB.robax.rax_2 = K2RBV.robax.rax_2 - KconveyorV.robax.rax_2 + N_VY.num
      end
    end
  end
  
  --拍照结束,爪手上升到安全高度
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)  
  --爪手再移动到纵向安全位置
  Knext.robax.rax_2 = Kwait.robax.rax_2
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)  
  SetDO("DO_LIGHT",0)
  
  --将拍照后得到的数据保存到控制器硬盘文件上
  local _table = {{},{},{},{}}
  if PR_Tray_Num.num == 1 then
     _table = {CopyJointTarget(K1LB),CopyJointTarget(K1LT),CopyJointTarget(K1RT),CopyJointTarget(K1RB)} 
  elseif PR_Tray_Num.num == 2 then
    _table = {CopyJointTarget(K2LB),CopyJointTarget(K2LT),CopyJointTarget(K2RT),CopyJointTarget(K2RB)} 
  end
  local str =  pam_json.encode(_table)
  local posfile = io.open("/home/controller/usr/Program/pos"..PR_Tray_Num.num..".json","w")
  io.output(posfile)
  io.write(str)
  Sleep(500)
  posfile:close()    

  N_Action.num = 0 - n_visionOnIn 
end

--激光测距判断不良品小车有无杂物
function laserOnCart()
  N_Action.num = n_laserOnCart
  --当前位置上升到安全高度
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  MoveAbsJ(KcartLaser1U,v_safeHeight,fine,tool0,wobj0,load0)
  MoveAbsJ(KcartLaser1,v_vertical,fine,tool0,wobj0,load0)
  local x2 = KcartLaser3.robax.rax_1
  local x1 = KcartLaser1.robax.rax_1
  local y2 = KcartLaser2.robax.rax_2
  local y1 = KcartLaser1.robax.rax_2
  local xGap = (x2 - x1)/5
  local yGap = (y2 - y1)/2
  

  for bar = 1,5,1 do
      local current = GetJointTarget("Xyzw")
      current.robax.rax_1 = current.robax.rax_1 + xGap
      current.robax.rax_2 = KcartLaser1.robax.rax_2
      current.robax.rax_3 = -417.400
      current.robax.rax_4 = 0
      MoveAbsJ(current,v_vertical,fine,tool0,wobj0,load0)
      if GetAI("AI10_1")<1300 then
        S_Error.str = "something in cart, detected: ".. GetAI("AI10_1")
        N_Error.num = n_laserOnCart + 1
        TPWrite(S_Error.str)
        Stop()
      end
  end
  
  for bar = 1,6,1 do
      local current = GetJointTarget("Xyzw")
      if bar > 1 then
        current.robax.rax_1 = current.robax.rax_1 - xGap
      end
      current.robax.rax_2 = KcartLaser1.robax.rax_2 + yGap
      current.robax.rax_3 = -417.400
      current.robax.rax_4 = 0
      MoveAbsJ(current,v_vertical,fine,tool0,wobj0,load0)
      if GetAI("AI10_1")<1300 then
        S_Error.str = "something in cart, detected: ".. GetAI("AI10_1")
        N_Error.num = n_laserOnCart + 1
        TPWrite(S_Error.str)
        Stop()
      end
  end
  
  for bar = 1,6,1 do
      local current = GetJointTarget("Xyzw")
      if bar > 1 then
        current.robax.rax_1 = current.robax.rax_1 + xGap
      end
      current.robax.rax_2 = KcartLaser1.robax.rax_2 + yGap*2
      current.robax.rax_3 = -417.400
      current.robax.rax_4 = 0
      MoveAbsJ(current,v_vertical,fine,tool0,wobj0,load0)
      if GetAI("AI10_1")<1300 then
        S_Error.str = "something in cart, detected: ".. GetAI("AI10_1")
        N_Error.num = n_laserOnCart + 1
        TPWrite(S_Error.str)
        Stop()
      end
  end

  --当前位置上升到安全高度
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)
  
  N_Action.num = 0 - n_laserOnCart
end

--机器视觉识别出口盘的4个梯形块
function visionOnOut()
  N_Action.num = n_visionOnOut
  WaitDI("DI_UNDER",0)
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    SetDO("DO_UP",1)  
    Sleep(3000)
  end
  WaitDI("DI_AIR_UP",1)
  WaitDI("DI_AIR_DOWN",0)
  SetDO("DO_LIGHT",1)
  N_VX12.num = 0
  N_VY12.num = 0
  
  --当前位置上升到安全高度
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)

  if (PR_Tray_Num.num < 3) or (PR_Tray_Num.num > 6) then
    S_Error.str = "PR_Tray_Num is wrong:"..PR_Tray_Num.num
    N_Error.num = n_visionOnOut + 3
    TPWrite(S_Error.str)
    Sleep(500)
  end 
  
  --移动到隔板左下角梯形块的安全高度
  if PR_Tray_Num.num == 3 then
    MoveAbsJ(K3_V1_U,v_safeHeight,fine,tool0,wobj0,load0)
  elseif PR_Tray_Num.num == 4 then
    MoveAbsJ(K4_V1_U,v_safeHeight,fine,tool0,wobj0,load0)
  elseif PR_Tray_Num.num == 5 then
    MoveAbsJ(K5_V1_U,v_safeHeight,fine,tool0,wobj0,load0)
  elseif PR_Tray_Num.num == 6 then
    MoveAbsJ(K6_V1_U,v_safeHeight,fine,tool0,wobj0,load0)
  end
  
  --拍隔板的4个位置
  for var=1,4,1 do
    if var == 1 then
      S_Vision.str = "000025#0111@0009&0004,1,0;0000#"
    elseif var == 2 then
      S_Vision.str = "000025#0111@0009&0004,1,1;0000#"    
    elseif var == 3 then
      S_Vision.str = "000025#0111@0009&0004,1,2;0000#"
    elseif var == 4 then
      S_Vision.str = "000025#0111@0009&0004,1,3;0000#"
    end
    if PR_Tray_Num.num == 3 then
      if var == 1 then
        MoveAbsJ(K3_V1,v_vertical,fine,tool0,wobj0,load0)
      elseif var == 2 then
        MoveAbsJ(K3_V2,v_vertical,fine,tool0,wobj0,load0)
      elseif var == 3 then
        MoveAbsJ(K3_V3,v_vertical,fine,tool0,wobj0,load0)
      elseif var == 4 then
        MoveAbsJ(K3_V4,v_vertical,fine,tool0,wobj0,load0)
      end
    elseif PR_Tray_Num.num == 4 then
      if var == 1 then
        MoveAbsJ(K4_V1,v_vertical,fine,tool0,wobj0,load0)
      elseif var == 2 then
        MoveAbsJ(K4_V2,v_vertical,fine,tool0,wobj0,load0)
      elseif var == 3 then
        MoveAbsJ(K4_V3,v_vertical,fine,tool0,wobj0,load0)
      elseif var == 4 then
        MoveAbsJ(K4_V4,v_vertical,fine,tool0,wobj0,load0)
      end
    elseif PR_Tray_Num.num == 5 then
      if var == 1 then
        MoveAbsJ(K5_V1,v_vertical,fine,tool0,wobj0,load0)
      elseif var == 2 then
        MoveAbsJ(K5_V2,v_vertical,fine,tool0,wobj0,load0)
      elseif var == 3 then
        MoveAbsJ(K5_V3,v_vertical,fine,tool0,wobj0,load0)
      elseif var == 4 then
        MoveAbsJ(K5_V4,v_vertical,fine,tool0,wobj0,load0)
      end
    elseif PR_Tray_Num.num == 6 then
      if var == 1 then
        MoveAbsJ(K6_V1,v_vertical,fine,tool0,wobj0,load0)
      elseif var == 2 then
        MoveAbsJ(K6_V2,v_vertical,fine,tool0,wobj0,load0)
      elseif var == 3 then
        MoveAbsJ(K6_V3,v_vertical,fine,tool0,wobj0,load0)
      elseif var == 4 then
        MoveAbsJ(K6_V4,v_vertical,fine,tool0,wobj0,load0)
      end
    end
    Sleep(800)
    N_VX.num = 0
    while N_VX.num == 0 do
      Sleep(100)
    end
  end
  
  while ((N_VX12.num == 0) or (N_VY12.num == 0)) do
    Sleep(500)
  end 
  
  --拍照结束,爪手上升到安全高度
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = n_safeHeight
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)  
  --爪手再移动到纵向安全位置
  Knext.robax.rax_2 = Kwait.robax.rax_2
  MoveAbsJ(Knext,v_vertical,fine,tool0,wobj0,load0)  
  SetDO("DO_LIGHT",0)
  
  local offset = 0
  if PR_Tray_Num.num == 4 then
    offset = 1185
  elseif PR_Tray_Num.num == 5 then
    offset = 1185 + 1550
  elseif PR_Tray_Num.num == 6 then
    offset = 1185 + 1550 + 1185
  end   
  offset = offset*1000 
  local p__ = out_poses[PR_Tray_Num.num]
  p__[1].robax.rax_1 = (N_VX1.num + offset)/1000
  p__[2].robax.rax_1 = (N_VX2.num+ offset)/1000
  p__[3].robax.rax_1 = (N_VX3.num+ offset)/1000
  p__[4].robax.rax_1 = (N_VX4.num+ offset)/1000
  p__[5].robax.rax_1 = (N_VX5.num+ offset)/1000
  p__[6].robax.rax_1 = (N_VX6.num+ offset)/1000
  p__[7].robax.rax_1 = (N_VX7.num+ offset)/1000
  p__[8].robax.rax_1 = (N_VX8.num+ offset)/1000
  p__[9].robax.rax_1 = (N_VX9.num+ offset)/1000
  p__[10].robax.rax_1 = (N_VX10.num+ offset)/1000
  p__[11].robax.rax_1 = (N_VX11.num+ offset)/1000
  p__[12].robax.rax_1 = (N_VX12.num+ offset)/1000
  
  p__[1].robax.rax_2 = (N_VY1.num)/1000
  p__[2].robax.rax_2 = (N_VY2.num)/1000
  p__[3].robax.rax_2 = (N_VY3.num)/1000
  p__[4].robax.rax_2 = (N_VY4.num)/1000
  p__[5].robax.rax_2 = (N_VY5.num)/1000
  p__[6].robax.rax_2 = (N_VY6.num)/1000
  p__[7].robax.rax_2 = (N_VY7.num)/1000
  p__[8].robax.rax_2 = (N_VY8.num)/1000
  p__[9].robax.rax_2 = (N_VY9.num)/1000
  p__[10].robax.rax_2 = (N_VY10.num)/1000
  p__[11].robax.rax_2 = (N_VY11.num)/1000
  p__[12].robax.rax_2 = (N_VY12.num)/1000
  
  local ret = 1
  local angle = angleBetweenPoints(p__[1].robax.rax_1,p__[1].robax.rax_2,p__[10].robax.rax_1,p__[10].robax.rax_2)
  if ((angle>-89.5) or (angle<-90.5)) then
    S_Error.str = "tray has rotation : "..angle
    N_Error.num = n_visionOnOut + 4
    TPWrite("angle:"..angle)
    return 0
  end
  
  local str = pam_json.encode(p__)
  local posfile = io.open("/home/controller/usr/Program/pos"..PR_Tray_Num.num..".json","w")
  io.output(posfile)
  io.write(str)
  Sleep(500)
  posfile:close()  

  return 1
end

SetDO("DO_LIGHT",0)
SetDO("DO_UP",1)
getConfig()
     
while true do
  Sleep(10)
  WaitDO("DO_PgReset",1)
  
  while ((PR_Pro_Num.num ~= 2) and (PR_Pro_Num.num ~= 3) and (PR_Pro_Num.num ~= 4) and (PR_Pro_Num.num ~= 8) and (PR_Pro_Num.num ~= 9)) do
    Sleep(100)
  end
  SetDO("DO_PgReset",0)
  while ((PR_ProductCategory.num <1) or (PR_ProductCategory.num >4))  do
    Sleep(100)
  end
  if (PR_ProductCategory.num == 1) or (PR_ProductCategory.num == 3) then
    N_productHeight.num = 166
  elseif (PR_ProductCategory.num == 2) or (PR_ProductCategory.num == 4) then
    N_productHeight.num = 332        
  end
  
  --抓满轮
  if PR_Pro_Num.num == 2 then
    visionOnConveyor()    
    WaitDO("DO_AllowCrawl",1)
    SetDO("DO_PgReset",0)
    grabFromConveyor()
    WaitDO("DO_AllowCrawl",0)
    while ((PR_Tray_Num.num ~= 3) and (PR_Tray_Num.num ~= 4) and (PR_Tray_Num.num ~= 5) and (PR_Tray_Num.num ~= 6) and (PR_Tray_Num.num ~= 7) and (PR_Tray_Num.num ~= 13)) do
      Sleep(100)
    end
    if PR_Tray_Num.num <= 6 and PR_Tray_Num.num >= 3 then
      carryToOut()
    elseif PR_Tray_Num.num == 7 then
      carryToCart()
    elseif PR_Tray_Num.num == 13 then
      carryToCache()
    end
  --抓空轮
  elseif PR_Pro_Num.num == 3 then
    WaitDO("DO_AllowCrawl",1)
    SetDO("DO_PgReset",0)
    grabFromIn()    
    WaitDO("DO_AllowCrawl",0)    
    carryToRGV()
  --抓缓存位
  elseif PR_Pro_Num.num == 4 then
    WaitDO("DO_AllowCrawl",1)
    SetDO("DO_PgReset",0)
    grabFromCache()    
    WaitDO("DO_AllowCrawl",0)    
    grabToOut()
  --抓隔板
  elseif PR_Pro_Num.num == 8 then
    WaitDO("DO_AllowCrawl",1)
    SetDO("DO_PgReset",0)
    while suckPartition()==0 do
      Stop()
    end
    N_Action.num = 0 - n_suckPartition    
    WaitDO("DO_AllowCrawl",0)    
    placePartition()
  --吸隔板
  elseif PR_Pro_Num.num == 9 then
     while ((PR_Tray_Num.num ~= 3) and (PR_Tray_Num.num ~= 4) and (PR_Tray_Num.num ~= 5) and (PR_Tray_Num.num ~= 6) and (PR_Tray_Num.num ~= 7) and (PR_Tray_Num.num ~= 1)and (PR_Tray_Num.num ~= 2)) do
      Sleep(100)
    end
    SetDO("DO_PgReset",0)    
    if PR_Tray_Num.num <= 2 then
      visionOnIn()
    elseif PR_Tray_Num.num == 7 then
      laserOnCart()
    elseif (PR_Tray_Num.num >=3) and (PR_Tray_Num.num <= 6) then
      while visionOnOut()==0 do
        Stop()
      end
      N_Action.num = 0 - n_visionOnOut 
    end    
  end
end

local function GLOBALDATA_DEFINE()
SPEEDDATA("v_grab",100.000,500.000,100.000,70.000)
SPEEDDATA("v_safeHeight",800.000,500.000,800.000,70.000)
SPEEDDATA("v_suckUpSlowly",50.000,500.000,50.000,70.000)
SPEEDDATA("v_vertical",250.000,500.000,250.000,70.000)
JOINTTARGET("KcartLaser1U",{-9932.680,29.011,-1297,0.033,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcartLaser1",{-9932.680,29.011,-417.374,0.033,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcartLaser2",{-10098.200,442.515,-417.369,0.033,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcartLaser3",{-9174.980,442.511,-417.364,0.033,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1LB",{-9727.010,1712.370,-765.417,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1LBV",{-9903.640,1705.240,-1044.960,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1LBVU",{-9903.640,1705.240,-1297.000,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1LT",{-9721.760,838.815,-760.058,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1LTV",{-9896.770,833.095,-1044.950,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1RB",{-8524.500,1713.230,-758.983,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1RBV",{-8700.420,1706.800,-1044.960,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1RT",{-8522.530,840.578,-759.956,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1RTV",{-8697.210,845.078,-1044.990,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})

JOINTTARGET("K2LB",{-17913.801,1713.690,-758.815,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2LBV",{-8090.500,1709.050,-1045.010,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2LBVU",{-8090.500,1709.050,-1297.000,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2LT",{-7912.870,838.693,-767.534,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2LTV",{-8090.040,834.731,-1045.000,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2RB",{-6715.410,1711.630,-757.582,-90.010,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2RBV",{-6893.060,1707.590,-1045.020,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2RT",{-6710.940,841.758,-757.090,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2RTV",{-6888.390,836.301,-1045.000,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})

JOINTTARGET("K3_V1",{-5281.510,1337.200,-189.079,-90.002,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V1_U",{-5281.510,1337.200,-1297.000,-90.002,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V2",{-4601.520,1339.350,-189.110,-89.995,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V3",{-5272.870,840.521,-189.081,-90.004,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V4",{-4587.150,840.521,-189.087,-89.996,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V1",{-4096.510,1337.200,-189.079,-90.002,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V1_U",{-4096.510,1337.200,-1297.000,-90.002,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V2",{-3416.520,1339.350,-189.110,-89.995,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V3",{-4087.870,840.521,-189.081,-90.004,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V4",{-3402.150,840.521,-189.087,-89.996,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V1",{-2546.510,1337.200,-189.079,-90.002,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V1_U",{-2546.510,1337.200,-1297.000,-90.002,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V2",{-1866.520,1339.350,-189.110,-89.995,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V3",{-2537.870,840.521,-189.081,-90.004,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V4",{-1852.140,840.521,-189.087,-89.996,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V1",{-1361.510,1337.200,-189.079,-90.002,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V1_U",{-1361.510,1337.200,-1297.000,-90.002,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V2",{-681.520,1339.350,-189.110,-89.995,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V3",{-1352.870,840.521,-189.081,-90.004,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V4",{-667.140,840.521,-189.087,-89.996,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV1",{-5826.130,1359.440,-99.000,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV1S",{-5826.130,1359.440,-432.000,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV1U",{-5826.130,1359.440,-1297.000,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV2",{-5828.520,1042.400,-97.353,-90.010,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV2S",{-5828.520,1042.400,-432.000,-90.010,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV2U",{-5828.520,1042.400,-1297.000,-90.010,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV3",{-5831.770,719.762,-98.921,-90.008,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV3S",{-5831.770,719.762,-432.000,-90.008,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV3U",{-5831.770,719.762,-1297.000,-90.008,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV4",{-5833.760,402.316,-92.541,-89.995,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV4S",{-5833.760,402.316,-432.000,-89.995,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV4U",{-5833.760,402.316,-1297.000,-89.995,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV5",{-5836.220,79.901,-98.554,-89.996,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV5S",{-5836.220,79.901,-432.000,-89.996,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV5U",{-5836.220,79.901,-1297.000,-89.996,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGVH1",{-5826.130,1359.440,-261.000,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGVH1S",{-5826.130,1359.440,-600.000,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGVH2",{-5828.520,1042.400,-261.000,-90.010,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGVH2S",{-5828.520,1042.400,-600.000,-90.010,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGVH3",{-5831.770,719.762,-261.000,-90.008,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGVH3S",{-5831.770,719.762,-600.000,-90.008,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGVH4",{-5833.760,402.316,-261.000,-89.995,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGVH4S",{-5833.760,402.316,-600.000,-89.995,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGVH5",{-5836.220,79.901,-261.000,-89.996,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGVH5S",{-5836.220,79.901,-600.000,-89.996,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcacheCorner",{-8706.230,57.436,-184.931,-90.014,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcacheCornerU",{-8706.230,57.434,-1297.000,-90.014,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcartCorner",{-9759.480,21.700,-190.537,-178.075,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcartCornerU",{-9759.480,21.700,-1297.000,-178.075,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})

JOINTTARGET("Kconveyor",{-1319.660,227.076,-111.054,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KconveyorH",{-1319.660,227.076,-277.054,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KconveyorV",{-1506.900,181.091,-246.322,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KconveyorVH",{-1506.900,181.091,-412.322,0.003,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KconveyorVU",{-1506.900,181.091,-1297.000,-90.000,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Knext",{0.000,0.000,0.000,0.000,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Ksuck",{-23.582,1225.050,-175.355,-179.097,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KsuckOffset_U",{-23.584,1173.020,-755.609,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Ksuck_U",{-23.582,1225.050,-755.615,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Kwait",{-5716.540,350.441,-1297.000,-90.331,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
ROBTARGET("Psuck",{-23.580,1225.050,-175.360},{0.007874,0.000000,0.000000,-0.999969},{-2,0,0,0},{0.000,0.000,0.000,0.000,0.000,0.000,0.000},0.000)
ROBTARGET("Psuck_D",{-23.581,1225.050,-409.835},{0.007874,0.000000,0.000000,-0.999969},{-2,0,0,0},{0.000,0.000,0.000,0.000,0.000,0.000,0.000},0.000)
ROBTARGET("Psuck_U",{-23.580,1225.050,-755.620},{0.007874,0.000000,0.000000,-0.999969},{-2,0,0,0},{0.000,0.000,0.000,0.000,0.000,0.000,0.000},0.000)
end
print("The end!")