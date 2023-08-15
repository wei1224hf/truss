function openGrab()
  if GetDI("DI_UNDER") == 1 then
    S_Error.val = "Unable to open, something under the grab"
    N_Error.num = 1
    Stop()
    return 0
  end
  
  SetDO("DO_OPEN",1)
  SetDO("DO_CLOSE",0)
  WaitDI("DI_CLOSE",0)
  Sleep(2000)
  if GetDI("DI_OPEN") == 0 then
    S_Error.val = "Unable to open the grab, check the air pressure"
    N_Error.num = 2
    Stop()
    return 0
  end
  return 1
end

function releaseGrab()
  if GetDI("DI_UNDER") == 0 then
    S_Error.val = "nothing under the grab"
    N_Error.num = 1
    Stop()
    return 0
  end
  
  SetDO("DO_OPEN",1)
  SetDO("DO_CLOSE",0)
  WaitDI("DI_CLOSE",0)
  Sleep(2000)
  if GetDI("DI_OPEN") == 0 then
    S_Error.val = "Unable to open the grab, check the air pressure"
    N_Error.num = 2
    Stop()
    return 0
  end
  return 1
end

function closeGrab()
  if GetDI("DI_UNDER") == 0 then
    S_Error.val = "there is nothing under the grab"
    N_Error.num = 3
    Stop()
    return 0
  end
  
  SetDO("DO_OPEN",0)
  SetDO("DO_CLOSE",1)
  WaitDI("DI_OPEN",0)
  Sleep(2000)
  if GetDI("DI_CLOSE") == 0 then
    S_Error.val = "Unable to close the grab, check the air pressure"
    N_Error.num = 4
    Stop()
    return 0
  end
  return 1
end

function grabToCache()

  if GetDI("DI_UNDER") == 0 then
    S_Error.val = "Unable to grab toward cache, nothing under the grab"
    N_Error.num = 5
    Stop()
    return 0
  end
  
  if (N_CacheX.num < 1) or (N_CacheX.num > 9) then
    S_Error.val = "N_CacheX is wrong, should between 1 and 9"
    N_Error.num = 1
    Stop()
    return 0
  end
  
  if (N_CacheY.num < 1) or (N_CacheY.num > 2) then
    S_Error.val = "N_CacheX is wrong, should between 1 and 2"
    N_Error.num = 1
    Stop()
    return 0
  end

  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  local offset_x = (N_CacheX.num - 1) * N_cacheOffsetX.num
  local offset_y = (N_CacheY.num - 1) * N_cacheOffsetY.num
  Knext = CopyJointTarget(KcacheCorner)
  Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
  Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y
  local _height = Knext.robax.rax_3
  Knext.robax.rax_3 = N_safeHeight.num
  
  TPWrite("X:"..Knext.robax.rax_1.."/Y:"..Knext.robax.rax_2.."/Z:"..Knext.robax.rax_3)

  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = _height
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(2000)
  releaseGrab()
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  N_CacheX.num = N_CacheX.num + 1
  if N_CacheX.num > 9 then
    N_CacheY.num = N_CacheY.num + 1
    if N_CacheY.num > 2 then
      S_Error.val = "cache is full"
      N_Error.num = 1
      return 0
    end
  end
  N_Action.num = 0
end

function grabToCart()
  if GetDI("DI_UNDER") == 0 then
    S_Error.val = "nothing under the grab"
    N_Error.num = 1
    Stop()
    return 0
  end
  
  if (N_CartX.num < 1) or (N_CartX.num > 3) then
    S_Error.val = "N_CartX is wrong, should between 1 and 3"
    N_Error.num = 1
    Stop()
    return 0
  end
  
  if (N_CartY.num < 1) or (N_CartY.num > 2) then
    S_Error.val = "N_CartY is wrong, should between 1 and 2"
    N_Error.num = 1
    Stop()
    return 0
  end
  
  if (N_CartZ.num < 1) or (N_CartZ.num > 2) then
    S_Error.val = "N_CartZ is wrong, should between 1 and 2"
    N_Error.num = 1
    Stop()
    return 0
  end
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  local offset_x = (N_CartX.num - 1) * N_cartOffsetX.num
  local offset_y = (N_CartY.num - 1) * N_cartOffsetY.num
  Knext = CopyJointTarget(KcartCorner)
  Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
  Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y
  local _height = Knext.robax.rax_3
  Knext.robax.rax_3 = N_safeHeight.num
  
  TPWrite("X:"..Knext.robax.rax_1.."/Y:"..Knext.robax.rax_2.."/Z:"..Knext.robax.rax_3)
  
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = _height
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(2000)
  releaseGrab()
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  N_CartX.num = N_CartX.num  + 1
  if N_CartX.num > 3 then
    N_CartX.num = 1
    N_CartY.num = N_CartY.num + 1
    if N_CartY.num > 2 then
      S_Error.val = "cart is full"
      N_Error.num = 1
      return 0
    end
  end
  N_Action.num = 0
end

function grabToRGV()
  if GetDI("DI_UNDER") == 0 then
    S_Error.val = "nothing under the grab"
    N_Error.num = 1
    Stop()
    return 0
  end
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(1000)

  if (N_RGV.num < 1) or (N_RGV.num > 5) then
    S_Error.val = "N_RGV is wrong, should between 1 and 5"
    N_Error.num = 1
    Stop()
    return 0
  end  
  
  local x_1 = KRGV1.robax.rax_1
  local y_1 = KRGV1.robax.rax_2
  
  local x_5 = KRGV5.robax.rax_1
  local y_5 = KRGV5.robax.rax_2
  
  local gapX = (x_1 - x_5)/4
  local gapY = (y_1 - y_5)/4
  TPWrite("gapX:"..gapX.."/gapY:"..gapY)
  
  if N_RGV.num == 3 then
    Knext = CopyJointTarget(KRGV1)
    Knext.robax.rax_1 = (x_1 + x_5)/2
    Knext.robax.rax_2 = (y_1 + y_5)/2
  elseif N_RGV.num <=2 then
    Knext = CopyJointTarget(KRGV1)
    Knext.robax.rax_1 = Knext.robax.rax_1 - gapX * (N_RGV.num - 1)
    Knext.robax.rax_2 = Knext.robax.rax_2 - gapY * (N_RGV.num - 1)
  elseif N_RGV.num >=4 then
    Knext = CopyJointTarget(KRGV5)
    Knext.robax.rax_1 = Knext.robax.rax_1 + gapX * (5 - N_RGV.num)
    Knext.robax.rax_2 = Knext.robax.rax_2 + gapY * (5 - N_RGV.num)
  end
  
  TPWrite("x:"..Knext.robax.rax_1.."/y:"..Knext.robax.rax_2)

  local _height = Knext.robax.rax_3
  
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(1000)
  Knext.robax.rax_3 = _height
  TPWrite("z:"..Knext.robax.rax_3)
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(1000)
  releaseGrab()
  Sleep(1000)
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  N_RGV.num = N_RGV.num + 1
  N_Action.num = 0
end

function grabFromConveyor()
  if GetDI("DI_UNDER") == 1 then
    S_Error.val = "something under the grab"
    N_Error.num = 1
    Stop()
    return 0
  end
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  Knext = CopyJointTarget(Kconveyor_V)
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(1000)  
  Knext.robax.rax_3 = Kconveyor_V.robax.rax_3
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  SetDO("DO_LIGHT",1)
  Sleep(2000)  
  SetDO("DO_LIGHT",0)
  
  Knext = CopyJointTarget(Kconveyor)
  Knext.robax.rax_3 = Kconveyor_V.robax.rax_3
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  openGrab()
  Knext.robax.rax_3 = Kconveyor.robax.rax_3
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  closeGrab()
  
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  N_Action.num = 0  
end

function grabToOut()
  if N_Out.num == 4 then
  
    Knext = GetJointTarget ("Xyzw")
    Knext.robax.rax_3 = N_safeHeight.num
    MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)

    local corner_x = KpalletCorner4.robax.rax_1
    local corner_y = KpalletCorner4.robax.rax_2
    
    
    local origin_x = KpalletOrigin4.robax.rax_1
    local origin_y = KpalletOrigin4.robax.rax_2
    
    local gap_x = (corner_x - origin_x)/2
    local gap_y = (corner_y - origin_y)/3
     
    local offset_x = (N_Out4X.num - 1) * gap_x
    local offset_y = (N_Out4Y.num - 1) * gap_y
    
    Knext = CopyJointTarget( KpalletOrigin4 )
    Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
    Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y
    local out4hz = Knext.robax.rax_3 - (N_Out4Z.num - 1) * productHeight
    Knext.robax.rax_3 = N_safeHeight.num
    
    MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
    Sleep(1000)
    Knext.robax.rax_3 = out4hz
    MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
    Sleep(2000)
    openGrab()
    
    Knext.robax.rax_3 = N_safeHeight.num
    MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
    
    N_Out.num = 0
    
    N_Out4X.num = N_Out4X.num + 1
    if N_Out4X.num > 3 then
      N_Out4X.num = 1
      N_Out4Y.num = N_Out4Y.num + 1
      if N_Out4Y.num > 4 then
        N_Out4Y.num = 1
        N_Out4Z.num =  N_Out4Z.num + 1
        if N_Out4Z.num > 6 then
        end
      end
    end    
  end
  N_Action.num = 0
end

function suckFromShelf()
  if GetDI("DI_UNDER") == 1 then
    S_Error.val = "something under the grab"
    N_Error.num = 1
    Stop()
    return 0
  end
  
  SetDO("DO_UP",1)
  SetDO("DO_SUCK",0)
  WaitDI("DI_AIR_UP",1)
  WaitDI("DI_AIR_DOWN",0)
  WaitDI("DI_AIR_LEFT",1)
  WaitDI("DI_AIR_RIGHT",1)
  
  Knext = GetJointTarget ("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)  
  
  Knext = CopyJointTarget( KsuckOffset )
  Knext.robax.rax_3 = N_safeHeight.num
  TPWrite("x:"..Knext.robax.rax_1.."/y:"..Knext.robax.rax_2)
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)  
  
  Knext = CopyJointTarget( Ksuck )
  local _height = Knext.robax.rax_3
  Knext.robax.rax_3 = N_safeHeight.num
  TPWrite("x:"..Knext.robax.rax_1.."/y:"..Knext.robax.rax_2)
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)  
  
  Knext.robax.rax_3 = _height
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)  
  SetDO("DO_SUCK",1)
  WaitDI("DI_AIR_LEFT",0)
  WaitDI("DI_AIR_RIGHT",0)
  
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)  
  N_Action.num = 0
end

function suckToOut()

end

function toWait()
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  TPWrite("To safe height")
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  MoveAbsJ(Kwait,v100,fine,tool0,wobj0,load0)
  N_Action.num = 0
end

function grabFromIn()
  if GetDI("DI_UNDER") == 1 then
    S_Error.val = "Unable to grab, something under the grab"
    N_Error.num = 1
    Stop()
    return 0
  end
  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    SetDO("DO_UP",1)  
    Sleep(3000)
  end
  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    S_Error.val = "the sucker should be up, not be down"
    N_Error.num = 1
    Stop()
    return 0
  end

  if (N_In.num < 1) or (N_In.num > 2) then
    S_Error.val = "N_In num is wrong, should between 1 and 2"
    N_Error.num = 1
    Stop()
    return 0
  end  
  
  local _x = 0
  local _y = 0
  local _z = 0
  
  if N_In.num == 2 then
    _x = N_In2X.num
    _y = N_In2Y.num
    _z = N_In2Z.num
  end   
  
  if N_In.num == 1 then
    _x = N_In1X.num
    _y = N_In1Y.num
    _z = N_In1Z.num
  end   
  
  if (_x < 1) or (_x > 5) then
    S_Error.val = "X is wrong, should between 1 and 5"
    N_Error.num = 1
    Stop()
    return 0
  end
  
  if (_y < 1) or (_y > 4) then
    S_Error.val = "Y num is wrong, should between 1 and 4"
    N_Error.num = 1
    Stop()
    return 0
  end
  
  if (_z < 1) or (_z > 6) then
    S_Error.val = "Z is wrong, should between 1 and 6"
    N_Error.num = 1
    Stop()
    return 0
  end
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  local p_in = {{K_LB1,K_LT1,K_RT1,K_RB1},{K_LB2,K_LT2,K_RT2,K_RB2}}
  local pHeights = {N_H1.num,N_H2.num}
  
  local index = _x + (_y-1)*5
  
  local _LB = p_in[N_In.num][1]
  local _LT = p_in[N_In.num][2]
  local _RT = p_in[N_In.num][3]
  local _RB = p_in[N_In.num][4]
  local _productH = pHeights[N_In.num]
  
  if (index >= 1) and (index <= 5) then
    local LB_x = _LB.robax.rax_1
    local LB_y = _LB.robax.rax_2
    
    local RB_x = _RB.robax.rax_1
    local RB_y = _RB.robax.rax_2
    
    if (_x == 3) then
      Knext = CopyJointTarget( _LB )
      Knext.robax.rax_1 = (LB_x + RB_x) / 2
      Knext.robax.rax_2 = (LB_y + RB_y) / 2
    end
    
    local gap_x = (RB_x - LB_x)/4
    local gap_y = (RB_y - LB_y)/4
    
    if (_x <= 2) then      
      local offset_x = (_x - 1) * gap_x
      local offset_y = (_x - 1) * gap_y
      Knext = CopyJointTarget( _LB )
      Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
      Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y 
    end
    
    if (_x >= 4) then
      local offset_x = (5 - _x) * gap_x
      local offset_y = (5 - _x) * gap_y
      Knext = CopyJointTarget( _RB )
      Knext.robax.rax_1 = Knext.robax.rax_1 - offset_x
      Knext.robax.rax_2 = Knext.robax.rax_2 - offset_y 
    end
 
  end 
  
  if (index >= 16) and (index <= 20) then
    local LT_x = _LT.robax.rax_1
    local LT_y = _LT.robax.rax_2
    
    local RT_x = _RT.robax.rax_1
    local RT_y = _RT.robax.rax_2
    
    if (_x == 3) then
      Knext = CopyJointTarget( _LT )
      Knext.robax.rax_1 = (LT_x + RT_x) / 2
      Knext.robax.rax_2 = (LT_y + RT_y) / 2
    end
    
    local gap_x = (RT_x - LT_x)/4
    local gap_y = (RT_y - LT_y)/4
    
    if (_x <= 2) then      
      local offset_x = (_x - 1) * gap_x
      local offset_y = (_x - 1) * gap_y
      Knext = CopyJointTarget( _LT )
      Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
      Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y 
    end
    
    if (_x >= 4) then
      local offset_x = (5 - _x) * gap_x
      local offset_y = (5 - _x) * gap_y
      Knext = CopyJointTarget( _RT )
      Knext.robax.rax_1 = Knext.robax.rax_1 - offset_x
      Knext.robax.rax_2 = Knext.robax.rax_2 - offset_y 
    end 
   
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
  
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(2000)
  openGrab()
  
  if _productH == 166 then
    Knext.robax.rax_3 = _height - N_Hshort.num + (6 - _z) * _productH
  else
    Knext.robax.rax_3 = _height - N_Hshort.num + (3 - _z) * _productH
  end
  TPWrite("z:"..Knext.robax.rax_3)
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(2000)
  closeGrab()
  
  Knext.robax.rax_3 = N_safeHeight.num  
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Knext.robax.rax_2 = Kmiddle.robax.rax_2
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  N_currentH.num = _productH
  
  if N_In.num == 2 then
    N_In2X.num = N_In2X.num + 1
    if N_In2X.num > 5 then
      N_In2X.num = 1
      N_In2Y.num = N_In2Y.num + 1
      if N_In2Y.num > 4 then
        N_In2Y.num = 1
        N_In2Z.num =  N_In2Z.num - 1
        if N_In2Z.num == 0 then
          S_Error.val = "pallet 2 is empty"
          N_Error.num = 1
          Stop()
          return 0
        end
      end
    end
  elseif N_In.num == 1 then
    N_In1X.num = N_In1X.num + 1
    if N_In1X.num > 5 then
      N_In1X.num = 1
      N_In1Y.num = N_In1Y.num + 1
      if N_In1Y.num > 4 then
        N_In1Y.num = 1
        N_In1Z.num =  N_In1Z.num - 1
        if N_In1Z.num == 0 then
          S_Error.val = "pallet 1 is empty"
          N_Error.num = 1
          Stop()
          return 0
        end
      end
    end
  end

  N_Action.num = 0
  
end

function visionOnIn()
end

function visionOnOut()
end

function visionOnRGV()
end

function forTest()
  MoveAbsJ(Kwait,v100,fine,tool0,wobj0,load0)
  
  MoveAbsJ(Ksuck,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(KsuckU,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(KsuckOffset,v100,fine,tool0,wobj0,load0)
  
  MoveAbsJ(KlineS,v100,fine,tool0,wobj0,load0)  
  MoveAbsJ(KlineSU,v100,fine,tool0,wobj0,load0) 

  MoveAbsJ(K_LT1,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K_LB1,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K_RB1,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K_RT1,v100,fine,tool0,wobj0,load0)  
  MoveAbsJ(K_LT2,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K_LB2,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K_RT2,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K_RB2,v100,fine,tool0,wobj0,load0)  
  MoveAbsJ(K_LT1_V,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K_LB1_V,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K_RB1_V,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K_RT1_V,v100,fine,tool0,wobj0,load0)  
  MoveAbsJ(K_LT2_V,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K_LB2_V,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K_RT2_V,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K_RB2_V,v100,fine,tool0,wobj0,load0)
  
  MoveAbsJ(K3_5,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K3_8,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K4_5,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K4_8,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K5_5,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K5_8,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K6_5,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K6_8,v100,fine,tool0,wobj0,load0)

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
  MoveAbsJ(KRGV1_V,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(KRGV5,v100,fine,tool0,wobj0,load0) 
  MoveAbsJ(KRGV5U,v100,fine,tool0,wobj0,load0)    
  MoveAbsJ(KRGV5_V,v100,fine,tool0,wobj0,load0)  
  MoveAbsJ(Kconveyor,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(Kconveyor_V,v100,fine,tool0,wobj0,load0)  
  MoveAbsJ(KconveyorU,v100,fine,tool0,wobj0,load0)  
end

function _main()
  if N_Action.num == 2 then
    grabFromIn()
  elseif N_Action.num == 3 then
    grabToCache()
  elseif N_Action.num == 4 then
    grabToCart()
  elseif N_Action.num == 5 then
    toWait()
  elseif N_Action.num == 6 then
    grabFromConveyor()
  elseif N_Action.num == 7 then
    grabToOut()
  elseif N_Action.num == 8 then
    grabToRGV()
  elseif N_Action.num == 9 then
    suckFromShelf()
  elseif N_Action.num == 10 then
    suckToOut()
  elseif N_Action.num == 11 then
    visionOnIn()
  elseif N_Action.num == 12 then
    visionOnOut()
  elseif N_Action.num == 13 then
    visionOnRGV()
  elseif N_Action.num == 14 then
  
  end
end

local function GLOBALDATA_DEFINE()
NUMDATA("N_Error",1)
NUMDATA("N_H1",232)
NUMDATA("N_H2",166)
NUMDATA("N_H3",232)
NUMDATA("N_H4",166)
NUMDATA("N_H5",232)
NUMDATA("N_H6",166)
NUMDATA("N_Hshort",166)
NUMDATA("N_LB1_V_OffsetX",0)
NUMDATA("N_LB1_V_OffsetY",0)
NUMDATA("N_LB2_V_OffsetX",0)
NUMDATA("N_LB2_V_OffsetY",0)
NUMDATA("N_LT1_V_OffsetX",0)
NUMDATA("N_LT1_V_OffsetY",0)
NUMDATA("N_LT2_V_OffsetX",0)
NUMDATA("N_LT2_V_OffsetY",0)
NUMDATA("N_RB1_V_OffsetX",0)
NUMDATA("N_RB1_V_OffsetY",0)
NUMDATA("N_RB2_V_OffsetX",0)
NUMDATA("N_RB2_V_OffsetY",0)
NUMDATA("N_RGV1_V_OffsetX",0)
NUMDATA("N_RGV1_V_OffsetY",0)
NUMDATA("N_RGV5_V_OffsetX",0)
NUMDATA("N_RGV5_V_OffsetY",0)
NUMDATA("N_RT1_V_OffsetX",0)
NUMDATA("N_RT1_V_OffsetY",0)
NUMDATA("N_RT2_V_OffsetX",0)
NUMDATA("N_RT2_V_OffsetY",0)
NUMDATA("N_cacheOffsetX",300)
NUMDATA("N_cacheOffsetY",330)
NUMDATA("N_cartOffsetX",310)
NUMDATA("N_cartOffsetY",270)
NUMDATA("N_conveyorOffsetR",0)
NUMDATA("N_conveyorOffsetX",0)
NUMDATA("N_conveyorOffsetY",0)
NUMDATA("N_diam",200)
NUMDATA("N_grabZ1height",-1192)
NUMDATA("N_grabZoffset",40)
NUMDATA("N_outOffsetX",257)
NUMDATA("N_outOffsetY",257)
NUMDATA("N_productHeight",166)
NUMDATA("N_safeHeight",-1535)
JOINTTARGET("K3_5",{-4711.270,2342.280,-480.952,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_8",{-4705.810,2597.900,-482.454,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V1",{-4711.270,2342.280,-480.952,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V2",{-4711.270,2342.280,-480.952,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V3",{-4711.270,2342.280,-480.952,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V4",{-4711.270,2342.280,-480.952,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_5",{-4711.270,2342.280,-480.952,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_8",{-4705.810,2597.900,-482.454,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V1",{-4878.570,2724.900,-406.261,-221.821,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V2",{-4588.660,2703.990,-406.223,28.595,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V3",{-4891.390,2204.680,-406.226,-221.821,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V4",{-4610.120,2191.140,-406.216,28.595,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_5",{-4711.270,2342.280,-480.952,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_8",{-4705.810,2597.900,-482.454,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V1",{-4711.270,2342.280,-480.952,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V2",{-4711.270,2342.280,-480.952,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V3",{-4711.270,2342.280,-480.952,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V4",{-4711.270,2342.280,-480.952,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_5",{-2019.740,2346.080,-489.547,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_8",{-2021.230,2602.930,-486.077,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V1",{-2186.890,2724.890,-406.246,-221.780,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V2",{-1879.950,2719.610,-406.210,29.833,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V3",{-2176.630,2195.370,-406.231,-221.739,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V4",{-1875.710,2195.360,-406.217,29.833,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV1",{-6834.440,2554.310,-640.882,-94.912,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV1U",{-6834.440,2554.290,-1485.990,-94.896,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV1_V",{-6834.440,2554.310,-640.882,-94.912,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV5",{-6838.390,1279.000,-648.485,-94.912,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV5U",{-6838.390,1279.000,-1378.610,-94.912,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV5_V",{-6838.390,1279.000,-648.485,-94.912,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K_LB1",{-10736.200,2907.460,-1000.740,-94.925,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K_LB1_V",{-10742.200,2719.850,-1403.930,-94.468,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K_LB2",{-8923.680,2911.300,-1003.610,-94.925,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K_LB2_V",{-8929.960,2713.990,-1403.940,-94.468,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K_LT1",{-10728.600,2033.820,-1006.640,-94.925,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K_LT1_V",{-10736.900,1843.750,-1403.910,-94.468,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K_LT2",{-8919.830,2032.990,-1010.190,-94.925,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K_LT2_V",{-8929.740,1843.760,-1403.890,-94.451,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K_RB1",{-9532.450,2909.460,-1007.190,-94.925,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K_RB1_V",{-9540.680,2719.860,-1403.940,-94.468,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K_RB2",{-7721.680,2911.520,-1005.140,-94.925,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K_RB2_V",{-7726.460,2709.640,-1403.950,-94.468,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K_RT1",{-9529.480,2033.870,-1004.530,-94.907,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K_RT1_V",{-9535.180,1843.750,-1403.900,-94.468,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K_RT2",{-7718.320,2035.250,-1011.040,-94.907,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K_RT2_V",{-7726.440,1843.760,-1403.880,-94.451,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcacheCorner",{-9707.350,1254.110,-423.632,-94.893,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcacheCornerU",{-9707.350,1254.110,-423.632,-94.893,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcartCorner",{-10767.600,1223.110,-426.545,-221.851,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcartCornerU",{-10767.600,1223.110,-426.545,-221.851,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Kconveyor",{-2325.570,1420.260,-358.826,-94.553,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Kconveyor_V",{-2136.540,1419.440,-606.029,-221.340,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KconveyorU",{-2367.760,1408.570,-368.877,-51.302,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KlineS",{-6852.470,2034.730,-1535.000,-94.925,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KlineSU",{-6852.470,2034.730,-1535.000,-94.925,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Kmiddle",{-7721.680,2600.160,-1534.990,-94.925,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Knext",{0.000,0.000,0.000,0.000,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Ksuck",{-1012.290,2419.740,-457.074,-219.568,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KsuckOffset",{-1012.290,2358.060,-536.669,-219.527,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KsuckOffsetU",{-1012.290,2358.060,-536.669,-219.527,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KsuckU",{-1012.290,2419.740,-457.074,-219.568,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Kwait",{-5727.610,1506.720,-1534.980,-94.586,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
STRINGDATA("S_Error","0")
end
print("The end!")