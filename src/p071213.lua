function openGrab()
  if GetDI("DI_UNDER") == 1 then
    S_Error.val = "Unable to open, something under the grab"
    N_Error.num = N_xxxxGrab.num + 1
    Stop()
  end
  
  SetDO("DO_OPEN",1)
  SetDO("DO_CLOSE",0)
  WaitDI("DI_CLOSE",0)
  Sleep(1000)
  if GetDI("DI_OPEN") == 0 then
    S_Error.val = "Unable to open the grab, check the air pressure"
    N_Error.num = N_xxxxGrab.num + 2
    Stop()
  end
  return 1
end

function releaseGrab()
  if GetDI("DI_UNDER") == 0 then
    S_Error.val = "nothing under the grab"
    N_Error.num = N_xxxxGrab.num + 3
    Stop()
  end
  
  SetDO("DO_OPEN",1)
  SetDO("DO_CLOSE",0)
  WaitDI("DI_CLOSE",0)
  Sleep(1000)
  if GetDI("DI_OPEN") == 0 then
    S_Error.val = "Unable to open the grab, check the air pressure"
    N_Error.num = N_xxxxGrab.num + 4
    Stop()
  end
  return 1
end

function closeGrab()
  if GetDI("DI_UNDER") == 0 then
    S_Error.val = "there is nothing under the grab"
    N_Error.num = N_xxxxGrab.num + 5
    Stop()
  end
  
  SetDO("DO_OPEN",0)
  SetDO("DO_CLOSE",1)
  WaitDI("DI_OPEN",0)
  Sleep(1000)
  if GetDI("DI_CLOSE") == 0 then
    S_Error.val = "Unable to close the grab, check the air pressure"
    N_Error.num = N_xxxxGrab.num + 6
    Stop()
  end
  return 1
end

function grabFromCache()
  if GetDI("DI_UNDER") == 1 then
    S_Error.val = "something under the grab"
    N_Error.num = N_grabFromCache.num + 1
    Stop()
  end
  
  if (N_CacheX.num < 1) or (N_CacheX.num > 9) then
    S_Error.val = "N_CacheX is wrong, should between 1 and 9"
    N_Error.num =  N_grabFromCache.num + 2
    Stop()
  end
  
  if (N_CacheY.num < 1) or (N_CacheY.num > 2) then
    S_Error.val = "N_CacheX is wrong, should between 1 and 2"
    N_Error.num =  N_grabFromCache.num + 3
    Stop()
  end

  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  local offset_x = (N_CacheX.num - 1) * N_cacheOffsetX.num
  local offset_y = (N_CacheY.num - 1) * N_cacheOffsetY.num
  Knext = CopyJointTarget(KcacheCorner)
  Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
  Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y
  Knext.robax.rax_3 = N_safeHeight.num
  
  TPWrite("X:"..Knext.robax.rax_1.."/Y:"..Knext.robax.rax_2.."/Z:"..Knext.robax.rax_3)

  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(1000)
  openGrab()
  Knext.robax.rax_3 = KcacheCorner.robax.rax_3
  if N_productHeight.num == 332 then
    Knext.robax.rax_3 = KcartCorner.robax.rax_3 - 166
  end
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(1000)
  closeGrab()
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
 
  N_Action.num = 0 - N_grabToCache.num
end

function grabToCache()
  if GetDI("DI_UNDER") == 0 then
    S_Error.val = "Unable to grab toward cache, nothing under the grab"
    N_Error.num = N_grabToCache.num + 1
    Stop()
  end
  
  if (N_CacheX.num < 1) or (N_CacheX.num > 9) then
    S_Error.val = "N_CacheX is wrong, should between 1 and 9"
    N_Error.num =  N_grabToCache.num + 2
    Stop()
  end
  
  if (N_CacheY.num < 1) or (N_CacheY.num > 2) then
    S_Error.val = "N_CacheX is wrong, should between 1 and 2"
    N_Error.num =  N_grabToCache.num + 3
    Stop()
  end

  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v250,fine,tool0,wobj0,load0)
  
  local offset_x = (N_CacheX.num - 1) * N_cacheOffsetX.num
  local offset_y = (N_CacheY.num - 1) * N_cacheOffsetY.num
  Knext = CopyJointTarget(KcacheCorner)
  Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
  Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y

  Knext.robax.rax_3 = N_safeHeight.num
  
  TPWrite("X:"..Knext.robax.rax_1.."/Y:"..Knext.robax.rax_2.."/Z:"..Knext.robax.rax_3)

  MoveAbsJ(Knext,v250,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = KcacheCorner.robax.rax_3
  if N_productHeight.num == 332 then
    Knext.robax.rax_3 = KcartCorner.robax.rax_3 - 166
  end
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
      N_Error.num =  N_grabToCache.num + 4
    end
  end
  N_Action.num = 0 - N_grabToCache.num
end

function grabToCart()
  if GetDI("DI_UNDER") == 0 then
    S_Error.val = "nothing under the grab"
    N_Error.num = N_grabToCart.num + 1
    Stop()
  end
  
  if (N_CartX.num < 1) or (N_CartX.num > 3) then
    S_Error.val = "N_CartX is wrong, should between 1 and 3"
    N_Error.num = N_grabToCart.num + 2
    Stop()
  end
  
  if (N_CartY.num < 1) or (N_CartY.num > 2) then
    S_Error.val = "N_CartY is wrong, should between 1 and 2"
    N_Error.num = N_grabToCart.num + 3
    Stop()
  end
  
  if (N_CartZ.num < 1) or (N_CartZ.num > 2) then
    S_Error.val = "N_CartZ is wrong, should between 1 and 2"
    N_Error.num = N_grabToCart.num + 4
    Stop()
  end
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  local offset_x = (N_CartX.num - 1) * N_cartOffsetX.num
  local offset_y = (N_CartY.num - 1) * N_cartOffsetY.num
  Knext = CopyJointTarget(KcartCorner)
  Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
  Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y
  
  Knext.robax.rax_3 = N_safeHeight.num  
  TPWrite("X:"..Knext.robax.rax_1.."/Y:"..Knext.robax.rax_2.."/Z:"..Knext.robax.rax_3)  
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  Knext.robax.rax_3 = KcartCorner.robax.rax_3
  if N_productHeight.num == 332 then
    Knext.robax.rax_3 = KcartCorner.robax.rax_3 - 166
  end
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(1000)
  releaseGrab()
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  N_Action.num = 0 - N_grabToCart.num
end

function grabToRGV()
  if GetDI("DI_UNDER") == 0 then
    S_Error.val = "nothing under the grab"
    N_Error.num = N_grabToRGV.num + 1
    Stop()
  end
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v250,fine,tool0,wobj0,load0)
  Sleep(1000)

  if (N_RGV.num < 1) or (N_RGV.num > 5) then
    S_Error.val = "N_RGV is wrong, should between 1 and 5"
    N_Error.num = N_grabToRGV.num + 2
    Stop()
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
  MoveAbsJ(Knext,v250,fine,tool0,wobj0,load0)
  Sleep(1000)
  Knext.robax.rax_3 = _height
  TPWrite("z:"..Knext.robax.rax_3)
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(1000)
  releaseGrab()
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v250,fine,tool0,wobj0,load0)
  
  N_RGV.num = N_RGV.num + 1
  N_Action.num = 0 - N_grabToRGV.num
end

function grabFromConveyor()
  if GetDI("DI_UNDER") == 1 then
    S_Error.val = "something under the grab"
    N_Error.num = N_grabFromConveyor.num + 1
    Stop()
  end
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v250,fine,tool0,wobj0,load0)
  
  Knext = CopyJointTarget(Kconveyor_V)
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v250,fine,tool0,wobj0,load0)
  Sleep(1000)  
  Knext.robax.rax_3 = Kconveyor_V.robax.rax_3
  if N_productHeight.num == 332 then
    Knext.robax.rax_3 = Knext.robax.rax_3 - 166
  end
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  SetDO("DO_LIGHT",1)
  N_Action.num = 0 - N_grabFromConveyor.num
  
end

function upFromConveyor()
  SetDO("DO_LIGHT",0)
  
  Knext = GetJointTarget("Xyzw")
  if (math.abs(Knext.robax.rax_1 - Kconveyor_V.robax.rax_1) > 5) or (math.abs(Knext.robax.rax_2 - Kconveyor_V.robax.rax_2) > 5) or (math.abs(Knext.robax.rax_3 - Kconveyor_V.robax.rax_3) > 5) then
    S_Error.val = "current position is not suitable"
    N_Error.num = 1
    Stop()
  end
  
  Knext = CopyJointTarget(Kconveyor)
  Knext.robax.rax_1 = Knext.robax.rax_1 + N_conveyorOffsetX.num
  Knext.robax.rax_2 = Knext.robax.rax_2 + N_conveyorOffsetY.num
  Knext.robax.rax_3 = Kconveyor_V.robax.rax_3
  Knext.robax.rax_4 = Knext.robax.rax_4 + N_conveyorOffsetR.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  openGrab()
  Knext.robax.rax_3 = Kconveyor.robax.rax_3
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  closeGrab()
  
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v250,fine,tool0,wobj0,load0)
  N_Action.num = 0 - N_upFromConveyor.num
end


function grabToOut()

  SetDO("DO_LIGHT",0)
  if GetDI("DI_UNDER") == 0 then
    S_Error.val = "nothing under the grab"
    N_Error.num = 1
    Stop()
  end
  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    SetDO("DO_UP",1)  
    Sleep(3000)
  end
  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    S_Error.val = "the sucker should be up, not be down"
    N_Error.num = 1
    Stop()
  end

  if (N_Out.num < 3) or (N_Out.num > 6) then
    S_Error.val = "N_Out num is wrong, should between 3 and 6"
    N_Error.num = 1
    Stop()
  end  

  local _z_ = {0,0,N_Out3Z,N_Out4Z,N_Out5Z,N_Out6Z}
  local _i_ = {0,0,N_Out3I,N_Out4I,N_Out5I,N_Out6I}

  local _z = _z_[N_Out.num]
  local _i = _i_[N_Out.num]

  local p_out = {{},{},{K3_5,K3_8},{K4_5,K4_8},{K5_5,K5_8},{K6_5,K6_8}}
  local offset_out = {{},{},
  {{N_3_5_OffsetX,N_3_5_OffsetY},{N_3_8_OffsetX,N_3_8_OffsetY}},
  {{N_4_5_OffsetX,N_4_5_OffsetY},{N_4_8_OffsetX,N_4_8_OffsetY}},
  {{N_5_5_OffsetX,N_5_5_OffsetY},{N_5_8_OffsetX,N_5_8_OffsetY}},
  {{N_6_5_OffsetX,N_6_5_OffsetY},{N_6_8_OffsetX,N_6_8_OffsetY}},
  }

  local p_5 = p_out[N_Out.num][1]
  local p_8 = p_out[N_Out.num][2]
  
  local _p_5 = CopyJointTarget( p_5 )
  _p_5.robax.rax_1 = _p_5.robax.rax_1 + offset_out[N_Out.num][1][1].num
  _p_5.robax.rax_2 = _p_5.robax.rax_2 + offset_out[N_Out.num][1][2].num
  
  local _p_8 = CopyJointTarget( p_8 )
  _p_8.robax.rax_1 = _p_8.robax.rax_1 + offset_out[N_Out.num][2][1].num
  _p_8.robax.rax_2 = _p_8.robax.rax_2 + offset_out[N_Out.num][2][2].num
  
  local _p_2 = CopyJointTarget( _p_5 )
  _p_2.robax.rax_1 = 2 * _p_5.robax.rax_1 - _p_8.robax.rax_1
  _p_2.robax.rax_2 = 2 * _p_5.robax.rax_2 - _p_8.robax.rax_2
  TPWrite("x:".._p_2.robax.rax_1.."/y:".._p_2.robax.rax_2)  
  Sleep(500)
  local _p_11 = CopyJointTarget( _p_5 )
  _p_11.robax.rax_1 = 2 * _p_8.robax.rax_1 - _p_5.robax.rax_1
  _p_11.robax.rax_2 = 2 * _p_8.robax.rax_2 - _p_5.robax.rax_2
  TPWrite("x:".._p_11.robax.rax_1.."/y:".._p_11.robax.rax_2)  
  Sleep(500)
  local _p_4 = CopyJointTarget( _p_5 )
  local t4 = doRotate(_p_5.robax.rax_1,_p_5.robax.rax_2,_p_8.robax.rax_1,_p_8.robax.rax_2,-90)
  _p_4.robax.rax_1 = t4[1]
  _p_4.robax.rax_2 = t4[2]
  
  local _p_6 = CopyJointTarget( _p_5 )
  local t6 = doRotate(_p_5.robax.rax_1,_p_5.robax.rax_2,_p_8.robax.rax_1,_p_8.robax.rax_2,90)
  _p_6.robax.rax_1 = t6[1]
  _p_6.robax.rax_2 = t6[2]
  
  local _p_7 = CopyJointTarget( _p_5 )
  local t7 = doRotate(_p_8.robax.rax_1,_p_8.robax.rax_2,_p_5.robax.rax_1,_p_5.robax.rax_2,90)
  _p_7.robax.rax_1 = t7[1]
  _p_7.robax.rax_2 = t7[2]
  Sleep(500)
  local _p_9 = CopyJointTarget( _p_5 )
  local t9 = doRotate(_p_8.robax.rax_1,_p_8.robax.rax_2,_p_5.robax.rax_1,_p_5.robax.rax_2,-90)
  _p_9.robax.rax_1 = t9[1]
  _p_9.robax.rax_2 = t9[2]
  TPWrite("x:".._p_9.robax.rax_1.."/y:".._p_9.robax.rax_2)  
  local _p_10 = CopyJointTarget( _p_5 )
  _p_10.robax.rax_1 = 2 * _p_8.robax.rax_1 - _p_6.robax.rax_1
  _p_10.robax.rax_2 = 2 * _p_8.robax.rax_2 - _p_6.robax.rax_2
  
  local _p_12 = CopyJointTarget( _p_5 )
  _p_12.robax.rax_1 = 2 * _p_8.robax.rax_1 - _p_4.robax.rax_1
  _p_12.robax.rax_2 = 2 * _p_8.robax.rax_2 - _p_4.robax.rax_2
  
  local _p_1 = CopyJointTarget( _p_5 )
  _p_1.robax.rax_1 = 2 * _p_5.robax.rax_1 - _p_9.robax.rax_1
  _p_1.robax.rax_2 = 2 * _p_5.robax.rax_2 - _p_9.robax.rax_2
  
  local _p_3 = CopyJointTarget( _p_5 )
  _p_3.robax.rax_1 = 2 * _p_5.robax.rax_1 - _p_7.robax.rax_1
  _p_3.robax.rax_2 = 2 * _p_5.robax.rax_2 - _p_7.robax.rax_2

  Knext = GetJointTarget ("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  TPWrite("i:".._i.num)
  local _p_1_12 = {_p_8,_p_5,_p_2,_p_1,_p_4,_p_7,_p_10,_p_11,_p_12,_p_9,_p_6,_p_3}
  Knext = _p_1_12[_i.num]
  if _i.num > 7 then
    Knext.robax.rax_4 = 30
  end
  Knext.robax.rax_3 = N_safeHeight.num
  TPWrite("x:"..Knext.robax.rax_1.."/y:"..Knext.robax.rax_2)  
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = _p_8.robax.rax_3
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(1000)
  releaseGrab()
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)

  _i.num = _i.num + 1

  N_Action.num = 0
end

function suckFromShelf()
  if GetDI("DI_UNDER") == 1 then
    S_Error.val = "something under the grab"
    N_Error.num = N_suckFromShelf.num + 1
    Stop()
  end
  
  if (N_Out.num < 3) or (N_Out.num > 6) then
    S_Error.val = "N_Out num is wrong, should between 3 and 6"
    N_Error.num = 1
    Stop()
  end  
  
  SetDO("DO_LIGHT",0)
  SetDO("DO_UP",1)
  SetDO("DO_SUCK",0)
  
  Knext = GetJointTarget ("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)  
  
  if WaitDI("DI_AIR_UP",1,3000) == true then
    S_Error.val = "Abnormal cylinder lifting, no up signal detected "
    N_Error.num = N_suckFromShelf.num + 2
    Stop()
  end
  if WaitDI("DI_AIR_DOWN",0,3000) == true then
    S_Error.val = "Abnormal cylinder lifting, the down signal is still there "
    N_Error.num = N_suckFromShelf.num + 3
    Stop()
  end
  if WaitDI("DI_AIR_LEFT",1,3000) == true then
    S_Error.val = "insufficient left air pressure from vacuum "
    N_Error.num = N_suckFromShelf.num + 4
    Stop()
  end
  if WaitDI("DI_AIR_RIGHT",1,3000) == true then
    S_Error.val = "insufficient right air pressure from vacuum"
    N_Error.num = N_suckFromShelf.num + 5
    Stop()
  end

  Knext = CopyJointTarget( KsuckOffset )
  Knext.robax.rax_3 = N_safeHeight.num
  TPWrite("x:"..Knext.robax.rax_1.."/y:"..Knext.robax.rax_2)
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)  
  SetDO("DO_UP",0)
  MoveAbsJ(KsuckOffset_U,v100,fine,tool0,wobj0,load0)
  if GetDI("DI_UNDER") == 1 then
    S_Error.val = "there is a partition stuck on the shelf, remove it"
    N_Error.num = N_suckFromShelf.num + 6
    Stop()
  end  
  
  Knext = CopyJointTarget( Ksuck )
  Knext.robax.rax_3 = KsuckOffset_U.robax.rax_3
  TPWrite("x:"..Knext.robax.rax_1.."/y:"..Knext.robax.rax_2)
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)  
  if WaitDI("DI_AIR_UP",0,3000) == true then
    S_Error.val = "cylidner shoud be down, but the up signal is still there"
    N_Error.num = N_suckFromShelf.num + 2
    Stop()
  end
  if WaitDI("DI_AIR_DOWN",1,3000) == true then
    S_Error.val = "no cylidner down signal detected "
    N_Error.num = N_suckFromShelf.num + 3
    Stop()
  end
  
  Knext.robax.rax_3 = Ksuck.robax.rax_3
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)  
  
  local _AI = GetAI("AI10_1")
  if (_AI < 1190) or (_AI > 1660) then
    S_Error.val = "Distance detector tells there is no partition under"
    N_Error.num = N_suckFromShelf.num + 6
    Stop()
  end
  
  SetDO("DO_SUCK",1)
  if WaitDI("DI_AIR_LEFT",0,3000) == true then
    S_Error.val = "nothing sucked on left"
    N_Error.num = N_suckFromShelf.num + 6
    Stop()
  end
  if WaitDI("DI_AIR_RIGHT",0,3000) == true then
    S_Error.val = "nothing sucked on right"
    N_Error.num = N_suckFromShelf.num + 6
    Stop()
  end
  
  Knext.robax.rax_3 = KsuckOffset_U.robax.rax_3
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)  
  if WaitDI("DI_AIR_LEFT",0,3000) == true then
    S_Error.val = "nothing sucked on left"
    N_Error.num = N_suckFromShelf.num + 6
    Stop()
  end
  if WaitDI("DI_AIR_RIGHT",0,3000) == true then
    S_Error.val = "nothing sucked on right"
    N_Error.num = N_suckFromShelf.num + 6
    Stop()
  end
  
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)  
  
  local placePositions = {0,0,KplacePartition_3,KplacePartition_4,KplacePartition_5,KplacePartition_6}
  local placePosition = placePositions[N_Out.num]
  Knext = CopyJointTarget( placePosition )
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)  
  Knext.robax.rax_3 = placePosition.robax.rax_3
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)  
  SetDO("DO_SUCK",0)
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)  
  
  N_Action.num = 0 - N_suckFromShelf.num
end



function toWait()
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  TPWrite("To safe height")
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  MoveAbsJ(K_home_1,v100,fine,tool0,wobj0,load0)
  N_Action.num = 0 - N_suckFromShelf.num
end

function grabFromIn()
  if GetDI("DI_UNDER") == 1 then
    S_Error.val = "Unable to grab, something under the grab"
    N_Error.num = N_grabFromIn.num + 1
    Stop()
  end
  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    SetDO("DO_UP",1)  
    Sleep(3000)
  end
  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    S_Error.val = "the sucker should be up, not be down"
    N_Error.num = N_grabFromIn.num + 2
    Stop()
  end

  if (N_In.num < 1) or (N_In.num > 2) then
    S_Error.val = "N_In num is wrong, should between 1 and 2"
    N_Error.num = N_grabFromIn.num + 3
    Stop()
  end  
    
  local _xyz = {{N_In1X,N_In1Y,N_In1Z},{N_In2X,N_In2Y,N_In2Z}}
  
  local _x = _xyz[N_In.num][1].num
  local _y = _xyz[N_In.num][2].num
  local _z = _xyz[N_In.num][3].num
  
  
  if (_x < 1) or (_x > 5) then
    S_Error.val = "X is wrong, should between 1 and 5"
    N_Error.num = N_grabFromIn.num + 4
    Stop()
  end
  
  if (_y < 1) or (_y > 4) then
    S_Error.val = "Y num is wrong, should between 1 and 4"
    N_Error.num = N_grabFromIn.num + 5
    Stop()
  end
  
  if (_z < 1) or (_z > 6) then
    S_Error.val = "Z is wrong, should between 1 and 6"
    N_Error.num = N_grabFromIn.num + 6
    Stop()
  end
  SetDO("DO_LIGHT",0)
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v250,fine,tool0,wobj0,load0)
  
  local _K_LB1 = CopyJointTarget( K_LB1 )
  local _K_RB1 = CopyJointTarget( K_RB1 )
  local _K_LT1 = CopyJointTarget( K_LT1 )
  local _K_RT1 = CopyJointTarget( K_RT1 )
  local _K_LB2 = CopyJointTarget( K_LB2 )
  local _K_RB2 = CopyJointTarget( K_RB2 )
  local _K_LT2 = CopyJointTarget( K_LT2 )
  local _K_RT2 = CopyJointTarget( K_RT2 )
  
  _K_LB1.robax.rax_1 = _K_LB1.robax.rax_1 + N_LB1_V_OffsetX.num
  _K_LB1.robax.rax_2 = _K_LB1.robax.rax_2 + N_LB1_V_OffsetY.num
  _K_RB1.robax.rax_1 = _K_RB1.robax.rax_1 + N_LB1_V_OffsetX.num
  _K_RB1.robax.rax_2 = _K_RB1.robax.rax_2 + N_LB1_V_OffsetY.num
  _K_LT1.robax.rax_1 = _K_LT1.robax.rax_1 + N_LB1_V_OffsetX.num
  _K_LT1.robax.rax_2 = _K_LT1.robax.rax_2 + N_LB1_V_OffsetY.num
  _K_RT1.robax.rax_1 = _K_RT1.robax.rax_1 + N_LB1_V_OffsetX.num
  _K_RT1.robax.rax_2 = _K_RT1.robax.rax_2 + N_LB1_V_OffsetY.num
  
  _K_LB2.robax.rax_1 = _K_LB2.robax.rax_1 + N_LB1_V_OffsetX.num
  _K_LB2.robax.rax_2 = _K_LB2.robax.rax_2 + N_LB1_V_OffsetY.num
  _K_RB2.robax.rax_1 = _K_RB2.robax.rax_1 + N_LB1_V_OffsetX.num
  _K_RB2.robax.rax_2 = _K_RB2.robax.rax_2 + N_LB1_V_OffsetY.num
  _K_LT2.robax.rax_1 = _K_LT2.robax.rax_1 + N_LB1_V_OffsetX.num
  _K_LT2.robax.rax_2 = _K_LT2.robax.rax_2 + N_LB1_V_OffsetY.num
  _K_RT2.robax.rax_1 = _K_RT2.robax.rax_1 + N_LB1_V_OffsetX.num
  _K_RT2.robax.rax_2 = _K_RT2.robax.rax_2 + N_LB1_V_OffsetY.num
  
  local p_in = {{_K_LB1,_K_LT1,_K_RT1,_K_RB1},{_K_LB2,_K_LT2,_K_RT2,_K_RB2}}
  local pHeights = {N_H1.num,N_H2.num}
  
  local index = _x + (_y - 1) * 5
  
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
  MoveAbsJ(Knext,v250,fine,tool0,wobj0,load0)
  Sleep(500)
  openGrab()
  
  if _productH == 166 then
    Knext.robax.rax_3 = _height - N_Hshort.num + (6 - _z) * _productH
  else
    Knext.robax.rax_3 = _height - N_Hshort.num + (3 - _z) * _productH
  end
  TPWrite("z:"..Knext.robax.rax_3)
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(500)
  closeGrab()
  
  Knext.robax.rax_3 = N_safeHeight.num  
  MoveAbsJ(Knext,v250,fine,tool0,wobj0,load0)
  Knext.robax.rax_2 = Kmiddle.robax.rax_2
  MoveAbsJ(Knext,v250,fine,tool0,wobj0,load0)
  
  N_productHeight.num = _productH

  N_Action.num = 0 - N_grabFromIn.num
  
end

function visionOnIn()
  if GetDI("DI_UNDER") == 1 then
    S_Error.val = "Unable to grab, something under the grab"
    N_Error.num = N_visionOnIn.num + 1
    Stop()
  end
  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    SetDO("DO_UP",1)  
    Sleep(3000)
  end
  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    S_Error.val = "the sucker should be up"
    N_Error.num = N_visionOnIn.num + 2
    Stop()
  end

  if (N_In.num < 1) or (N_In.num > 2) then
    S_Error.val = "N_In num is wrong, should between 1 and 2"
    N_Error.num = N_visionOnIn.num + 3
    Stop()
  end 
  
  if (N_V_step.num > 4) or  (N_V_step.num < 1) then
    S_Error.val = "vision step is wrong"
    N_Error.num = N_visionOnIn.num + 4
    Stop()
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
  
  local __z = 6
  if N_productHeight.num == 332 then
    __z = 3
  end
  
  if (_z ~= __z) or (_x ~= 1) or (_y ~= 1) then
    S_Error.val = "pallet is not full"
    N_Error.num = N_visionOnIn.num + 5
    Stop()
  end
  
  SetDO("DO_LIGHT",0)
  local p_v = {{K_LB1_V,K_LT1_V,K_RT1_V,K_RB1_V},{K_LB2_V,K_LT2_V,K_RT2_V,K_RB2_V}}
  
  if N_V_step.num == 1 then
    Knext = GetJointTarget("Xyzw")
    Knext.robax.rax_3 = N_safeHeight.num
    MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
    
    Knext = CopyJointTarget(p_v[N_In.num][N_V_step.num])
    Knext.robax.rax_3 = N_safeHeight.num
    MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  else
    local current = CopyJointTarget(p_v[N_In.num][N_V_step.num  - 1])
    local _current = GetJointTarget("Xyzw")
    local distance = getDistanceByK(_current,current)
    if distance > 10 then
      S_Error.val = "current position is unsuitable"
      N_Error.num = N_visionOnIn.num + 5
      Stop()
    end
  end
  
  Knext = CopyJointTarget(p_v[N_In.num][N_V_step.num])
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  SetDO("DO_LIGHT",1)
  N_Action.num = 0 - N_visionOnIn.num 
  
end

function visionOnOut()
  if GetDI("DI_UNDER") == 1 then
    S_Error.val = "Unable to grab, something under the grab"
    N_Error.num = N_visionOnOut.num + 1
    Stop()
  end
  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    SetDO("DO_UP",1)  
    Sleep(3000)
  end
  
  if (GetDI("DI_AIR_UP") == 0) or (GetDI("DI_AIR_DOWN") == 1) then
    S_Error.val = "the sucker should be up"
    N_Error.num = N_visionOnOut.num + 2
    Stop()
  end

  if (N_Out.num < 3) or (N_Out.num > 6) then
    S_Error.val = "N_In num is wrong, should between 3 and 6"
    N_Error.num = N_visionOnOut.num + 3
    Stop()
  end 
  
  if (N_V_step.num > 4) or  (N_V_step.num < 1) then
    S_Error.val = "vision step is wrong"
    N_Error.num = N_visionOnOut.num + 4
    Stop()
  end
  
  SetDO("DO_LIGHT",0)
  local p_v = {{0,0,0,0},{0,0,0,0},{K3_V1,K3_V3 ,K3_V4,K3_V2 },{K4_V1,K4_V3 ,K4_V4,K4_V2},{K5_V1,K5_V3 ,K5_V4,K5_V2},{K6_V1,K6_V3 ,K6_V4, K6_V2}}
  
  if N_V_step.num == 1 then
    Knext = GetJointTarget("Xyzw")
    Knext.robax.rax_3 = N_safeHeight.num
    MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
    
    Knext = CopyJointTarget(p_v[N_Out.num][N_V_step.num])
    Knext.robax.rax_3 = N_safeHeight.num
    MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  else
    local current = CopyJointTarget(p_v[N_Out.num][N_V_step.num  - 1])
    local _current = GetJointTarget("Xyzw")
    local distance = getDistanceByK(_current,current)
    if distance > 10 then
      S_Error.val = "current position is unsuitable"
      N_Error.num = N_visionOnOut.num + 5
      Stop()
    end
  end
  
  Knext = CopyJointTarget(p_v[N_Out.num][N_V_step.num])
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  SetDO("DO_LIGHT",1)
  N_Action.num = 0 - N_visionOnOut.num 
  
end

function visionOnRGV()
end

function getDistanceByK(K1,K2)
  local _x = math.abs(K1.robax.rax_1 - K2.robax.rax_1)
  local _y = math.abs(K1.robax.rax_1 - K2.robax.rax_1)
  local _z = math.abs(K1.robax.rax_1 - K2.robax.rax_1)
  
  local distance = (_x^2 + _y^2 + _z^2)^0.5
end

function doRotate(xc,yc,xp,yp,angle)
  if angle == 90 then
    return {yp-yc + xc,xc-xp + yc}
  elseif angle == -90 then
    return {xc+yc-yp,yc-xc+xp}
  end
  return {0,0}
end

function forManual()
  MoveAbsJ(Kwait,v100,fine,tool0,wobj0,load0)
  
MoveAbsJ(K10,v100,fine,tool0,wobj0,load0)
MoveAbsJ(K20,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(Ksuck,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(Ksuck_U,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(KsuckOffset,v100,fine,tool0,wobj0,load0)
  
  MoveAbsJ(KsuckOffset_U,v100,fine,tool0,wobj0,load0)
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
  
  MoveAbsJ(K3_5_U,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K3_8_U,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K4_5_U,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K4_8_U,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K5_5_U,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K5_8_U,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K6_5_U,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(K6_8_U,v100,fine,tool0,wobj0,load0)

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

--MoveAbsJ(K_home_1,v100,fine,tool0,wobj0,load0)
function _main()
  while true do
    Sleep(10)
    if N_Action.num == N_grabFromIn.num then
      grabFromIn()
    elseif N_Action.num == N_grabToCache.num then
      grabToCache()
    elseif N_Action.num == N_grabFromCache.num then
      grabFromCache()
    elseif N_Action.num == N_grabToCart.num then
      grabToCart()
    elseif N_Action.num == N_toWait.num then
      toWait()
    elseif N_Action.num == N_grabFromConveyor.num then
      grabFromConveyor()
    elseif N_Action.num == N_upFromConveyor.num then
      upFromConveyor()
    elseif N_Action.num == N_grabToOut.num then
      grabToOut()
    elseif N_Action.num == N_grabToRGV.num then
      grabToRGV()
    elseif N_Action.num == N_suckFromShelf.num then
      suckFromShelf()
    elseif N_Action.num == N_visionOnIn.num then
      visionOnIn()
    elseif N_Action.num == N_visionOnOut.num then
      visionOnOut()
    elseif N_Action.num == N_visionOnRGV.num then
      visionOnRGV()
    end
  end
  
end
_main()

local function GLOBALDATA_DEFINE()
NUMDATA("N_3_5_OffsetX",0)
NUMDATA("N_3_5_OffsetY",0)
NUMDATA("N_3_8_OffsetX",0)
NUMDATA("N_3_8_OffsetY",0)
NUMDATA("N_4_5_OffsetX",0)
NUMDATA("N_4_5_OffsetY",0)
NUMDATA("N_4_8_OffsetX",0)
NUMDATA("N_4_8_OffsetY",0)
NUMDATA("N_5_5_OffsetX",0)
NUMDATA("N_5_5_OffsetY",0)
NUMDATA("N_5_8_OffsetX",0)
NUMDATA("N_5_8_OffsetY",0)
NUMDATA("N_6_5_OffsetX",0)
NUMDATA("N_6_5_OffsetY",0)
NUMDATA("N_6_8_OffsetX",0)
NUMDATA("N_6_8_OffsetY",0)
NUMDATA("N_Action",1000)
NUMDATA("N_CacheX",1)
NUMDATA("N_CacheY",1)
NUMDATA("N_CacheZ",1)
NUMDATA("N_CartX",1)
NUMDATA("N_CartY",1)
NUMDATA("N_CartZ",1)
NUMDATA("N_Error",1006)
NUMDATA("N_H1",232)
NUMDATA("N_H2",166)
NUMDATA("N_H3",232)
NUMDATA("N_H4",166)
NUMDATA("N_H5",232)
NUMDATA("N_H6",166)
NUMDATA("N_Hshort",166)
NUMDATA("N_In",2)
NUMDATA("N_In1X",0)
NUMDATA("N_In1Y",1)
NUMDATA("N_In1Z",2)
NUMDATA("N_In2X",3)
NUMDATA("N_In2Y",3)
NUMDATA("N_In2Z",5)
NUMDATA("N_LB1_V_OffsetX",0)
NUMDATA("N_LB1_V_OffsetY",0)
NUMDATA("N_LB2_V_OffsetX",0)
NUMDATA("N_LB2_V_OffsetY",0)
NUMDATA("N_LT1_V_OffsetX",0)
NUMDATA("N_LT1_V_OffsetY",0)
NUMDATA("N_LT2_V_OffsetX",0)
NUMDATA("N_LT2_V_OffsetY",0)
NUMDATA("N_Out",4)
NUMDATA("N_Out3I",1)
NUMDATA("N_Out3Z",1)
NUMDATA("N_Out4I",13)
NUMDATA("N_Out4Z",1)
NUMDATA("N_Out5I",1)
NUMDATA("N_Out5Z",1)
NUMDATA("N_Out6I",1)
NUMDATA("N_Out6Z",1)
NUMDATA("N_RB1_V_OffsetX",0)
NUMDATA("N_RB1_V_OffsetY",0)
NUMDATA("N_RB2_V_OffsetX",0)
NUMDATA("N_RB2_V_OffsetY",0)
NUMDATA("N_RGV",1)
NUMDATA("N_RGV1_V_OffsetX",0)
NUMDATA("N_RGV1_V_OffsetY",0)
NUMDATA("N_RGV5_V_OffsetX",0)
NUMDATA("N_RGV5_V_OffsetY",0)
NUMDATA("N_RT1_V_OffsetX",0)
NUMDATA("N_RT1_V_OffsetY",0)
NUMDATA("N_RT2_V_OffsetX",0)
NUMDATA("N_RT2_V_OffsetY",0)
NUMDATA("N_V_step",1)
NUMDATA("N_cacheOffsetX",300)
NUMDATA("N_cacheOffsetY",330)
NUMDATA("N_cartOffsetX",310)
NUMDATA("N_cartOffsetY",270)
NUMDATA("N_conveyorOffsetR",0)
NUMDATA("N_conveyorOffsetX",0)
NUMDATA("N_conveyorOffsetY",0)
NUMDATA("N_diam",200)
NUMDATA("N_grabFromCache",300)
NUMDATA("N_grabFromConveyor",600)
NUMDATA("N_grabFromIn",100)
NUMDATA("N_grabToCache",200)
NUMDATA("N_grabToCart",400)
NUMDATA("N_grabToOut",800)
NUMDATA("N_grabToRGV",900)
NUMDATA("N_grabZ1height",-1192)
NUMDATA("N_grabZoffset",40)
NUMDATA("N_productHeight",166)
NUMDATA("N_safeHeight",-1535)
NUMDATA("N_suckFromShelf",1000)
NUMDATA("N_suckToOut",1100)
NUMDATA("N_toWait",500)
NUMDATA("N_upFromConveyor",700)
NUMDATA("N_visionOnIn",1200)
NUMDATA("N_visionOnOut",1300)
NUMDATA("N_visionOnRGV",1400)
NUMDATA("N_xxxxGrab",100)
JOINTTARGET("KplacePartition_3",{-4852.980,2466.790,-387.963,-219.525,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KplacePartitionUp_3",{-4852.980,2466.790,-1348.120,-219.525,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KplacePartition_4",{-4852.980,2466.790,-387.963,-219.525,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KplacePartitionUp_4",{-4852.980,2466.790,-1348.120,-219.525,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KplacePartition_5",{-4852.980,2466.790,-387.963,-219.525,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KplacePartitionUp_5",{-4852.980,2466.790,-1348.120,-219.525,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KplacePartition_6",{-4852.980,2466.790,-387.963,-219.525,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KplacePartitionUp_6",{-4852.980,2466.790,-1348.120,-219.525,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_5",{-4711.270,2342.280,-480.952,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_8",{-4705.810,2597.900,-482.454,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V1",{-4878.570,2724.900,-406.261,-221.821,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V2",{-4588.660,2703.990,-406.223,28.595,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V3",{-4891.390,2204.680,-406.226,-221.821,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V4",{-4610.120,2191.140,-406.216,28.595,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_5",{-4776.210,2578.350,-337.185,-219.334,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_5_U",{-4776.210,2578.340,-1203.520,-219.334,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_8",{-4780.090,2317.250,-335.893,-94.877,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_8_U",{-4780.100,2317.250,-1264.780,-94.877,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V1",{-4878.570,2724.900,-406.261,-221.821,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V2",{-4588.660,2703.990,-406.223,28.595,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V3",{-4891.390,2204.680,-406.226,-221.821,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V4",{-4610.120,2191.140,-406.216,28.595,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_5",{-4711.270,2342.280,-480.952,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_8",{-4705.810,2597.900,-482.454,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V1",{-2186.890,2724.890,-406.246,-221.780,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V2",{-1879.950,2719.610,-406.210,29.833,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V3",{-2176.630,2195.370,-406.231,-221.739,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V4",{-1875.710,2195.360,-406.217,29.833,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_5",{-2021.230,2602.930,-486.077,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_5_U",{-2021.230,2602.930,-900.000,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_8",{-2019.740,2346.080,-489.547,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_8_U",{-2019.740,2346.080,-900.000,-94.911,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
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
JOINTTARGET("K_home_1",{-6447.070,1539.030,-1534.990,-94.892,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcacheCorner",{-9707.350,1254.110,-423.632,-94.893,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcacheCornerU",{-9707.350,1254.110,-423.632,-94.893,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcartCorner",{-10767.600,1223.110,-426.545,-221.851,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcartCornerU",{-10767.600,1223.110,-426.545,-221.851,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Kconveyor",{-2324.330,1422.000,-356.105,-94.517,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KconveyorU",{-2324.340,1415.760,-606.079,-94.517,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Kconveyor_V",{-2324.340,1232.960,-606.085,-94.517,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KlineS",{-6852.470,2034.730,-1535.000,-94.925,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KlineSU",{-6852.470,2034.730,-1535.000,-94.925,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Kmiddle",{-7721.680,2600.160,-1534.990,-94.925,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Knext",{0.000,0.000,0.000,0.000,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Ksuck",{-1012.290,2419.740,-457.074,-219.568,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KsuckOffset",{-1012.290,2358.060,-536.669,-219.527,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KsuckOffset_U",{-1012.310,2358.040,-899.583,-219.486,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Ksuck_U",{-1012.300,2420.410,-1366.650,-219.525,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Kwait",{-5727.610,1506.720,-1534.980,-94.586,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
STRINGDATA("S_Code","0")
STRINGDATA("S_Error","0")
end
print("The end!")