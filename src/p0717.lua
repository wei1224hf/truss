function openGrab()
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

function suck()
  if GetDI("DI_UNDER") == 0 then
    S_Error.val = "nothing under"
    N_Error.num = N_grabFromCache.num + 1
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
  
end

function stopSuck()
  if GetDI("DI_UNDER") == 0 then
    S_Error.val = "nothing under"
    N_Error.num = N_grabFromCache.num + 1
    Stop()
  end
  
  if WaitDI("DI_AIR_LEFT",0,3000) == true then
    S_Error.val = "-- "
    N_Error.num = N_suckFromShelf.num + 4
    Stop()
  end
  if WaitDI("DI_AIR_RIGHT",0,3000) == true then
    S_Error.val = "--"
    N_Error.num = N_suckFromShelf.num + 5
    Stop()
  end
  SetDO("DO_SUCK",0)
  if WaitDI("DI_AIR_LEFT",1,3000) == true then
    S_Error.val = "--"
    N_Error.num = N_suckFromShelf.num + 6
    Stop()
  end
  if WaitDI("DI_AIR_RIGHT",1,3000) == true then
    S_Error.val = "--"
    N_Error.num = N_suckFromShelf.num + 6
    Stop()
  end
  
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
  Knext.robax.rax_3 = KcacheCorner.robax.rax_3 + 166 - N_productHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(1000)
  closeGrab()
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
 
  N_Action.num = 0 - N_grabFromCache.num
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
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
  local offset_x = (N_CacheX.num - 1) * N_cacheOffsetX.num
  local offset_y = (N_CacheY.num - 1) * N_cacheOffsetY.num
  Knext = CopyJointTarget(KcacheCorner)
  Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
  Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y
  Knext.robax.rax_3 = N_safeHeight.num
  
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
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
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
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
  local offset_x = (N_CartX.num - 1) * N_cartOffsetX.num
  local offset_y = (N_CartY.num - 1) * N_cartOffsetY.num
  Knext = CopyJointTarget(KcartCorner)
  Knext.robax.rax_1 = Knext.robax.rax_1 + offset_x
  Knext.robax.rax_2 = Knext.robax.rax_2 + offset_y
  
  Knext.robax.rax_3 = N_safeHeight.num  
  TPWrite("X:"..Knext.robax.rax_1.."/Y:"..Knext.robax.rax_2.."/Z:"..Knext.robax.rax_3)  
  MoveAbsJ(Knext,v400,fine,tool0,wobj0,load0)
  
  Knext.robax.rax_3 = KcartCorner.robax.rax_3 + 166 - N_productHeight.num * N_CartZ.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(1000)
  openGrab()
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
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
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
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
  

  Knext = CopyJointTarget(KRGV5)
  Knext.robax.rax_1 = Knext.robax.rax_1 + gapX * (5 - N_RGV.num)
  Knext.robax.rax_2 = Knext.robax.rax_2 + gapY * (5 - N_RGV.num)

  
  TPWrite("x:"..Knext.robax.rax_1.."/y:"..Knext.robax.rax_2)

  
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  Sleep(1000)
  Knext.robax.rax_3 = KRGV5.robax.rax_3 + 166 - N_RGVZ.num * N_productHeight.num
  TPWrite("z:"..Knext.robax.rax_3)
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(1000)
  openGrab()
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
  N_RGV.num = N_RGV.num + 1
  N_Action.num = 0 - N_grabToRGV.num
end

function visionOnConveyor()
  if GetDI("DI_UNDER") == 1 then
    S_Error.val = "something under the grab"
    N_Error.num = N_visionOnConveyor.num + 1
    Stop()
  end
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
  Knext = CopyJointTarget(Kconveyor_V)
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v300,fine,tool0,wobj0,load0)
  Sleep(300)  

  Knext.robax.rax_3 = Kconveyor_V.robax.rax_3 + 166 -332
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  Sleep(1000)
  local AI = GetAI("AI10_1")
  TPWrite("AI:"..AI)
  Knext.robax.rax_3 = Kconveyor_V.robax.rax_3 + 166 - N_productHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)  
  SetDO("DO_LIGHT",1)
  N_Action.num = 0 - N_visionOnConveyor.num
  
end

function grabFromConveyor()
  SetDO("DO_LIGHT",0)
  SetDO("DO_UP",1)
  
  local _current = GetJointTarget("Xyzw")
  local _Kconveyor_V = CopyJointTarget(Kconveyor_V)
  _Kconveyor_V.robax.rax_3 = _Kconveyor_V.robax.rax_3  + 166 - N_productHeight.num
  local distance = getDistanceByK(_Kconveyor_V,_current)
  
  if distance > 10 then
    S_Error.val = "current position is not suitable"
    N_Error.num = N_grabFromConveyor.num + 1
    --Stop()
  end
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = _Kconveyor_V.robax.rax_3 - 0
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  Knext = CopyJointTarget(Kconveyor)
  Knext.robax.rax_1 = Knext.robax.rax_1 + N_conveyorOffsetX.num
  Knext.robax.rax_2 = Knext.robax.rax_2 + N_conveyorOffsetY.num
  Knext.robax.rax_3 = _Kconveyor_V.robax.rax_3 - 0
  Knext.robax.rax_4 = Knext.robax.rax_4 + N_conveyorOffsetR.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  openGrab()
  Knext.robax.rax_3 = Kconveyor.robax.rax_3 + 166 - N_productHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  closeGrab()
  
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  N_Action.num = 0 - N_grabFromConveyor.num
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
  
  if (_i.num < 1 or _i.num > 12) then
    S_Error.val = "index num is wrong, should between 1 and 12"
    N_Error.num = N_grabToOut.num + 72
    Stop()
  end  
  
  local _K_LT3 = CopyJointTarget( K3LT )
  local _K_LB3 = CopyJointTarget( K3LB )
  local _K_RT3 = CopyJointTarget( K3RT )
  local _K_RB3 = CopyJointTarget( K3RB )
  local _K_LT4 = CopyJointTarget( K4LT )
  local _K_LB4 = CopyJointTarget( K4LB )
  local _K_RT4 = CopyJointTarget( K4RT )
  local _K_RB4 = CopyJointTarget( K4RB )
  local _K_LT5 = CopyJointTarget( K5LT )
  local _K_LB5 = CopyJointTarget( K5LB )
  local _K_RT5 = CopyJointTarget( K5RT )
  local _K_RB5 = CopyJointTarget( K5RB )
  local _K_LT6 = CopyJointTarget( K6LT )
  local _K_LB6 = CopyJointTarget( K6LB )
  local _K_RT6 = CopyJointTarget( K6RT )
  local _K_RB6 = CopyJointTarget( K6RB )
  
  _K_LT3.robax.rax_1 = _K_LT3.robax.rax_1 + N3LTX_offset.num
  _K_LB3.robax.rax_1 = _K_LB3.robax.rax_1 + N3LBX_offset.num
  _K_RT3.robax.rax_1 = _K_RT3.robax.rax_1 + N3RTX_offset.num
  _K_RB3.robax.rax_1 = _K_RB3.robax.rax_1 + N3RBX_offset.num
  _K_LT4.robax.rax_1 = _K_LT4.robax.rax_1 + N4LTX_offset.num
  _K_LB4.robax.rax_1 = _K_LB4.robax.rax_1 + N4LBX_offset.num
  _K_RT4.robax.rax_1 = _K_RT4.robax.rax_1 + N4RTX_offset.num
  _K_RB4.robax.rax_1 = _K_RB4.robax.rax_1 + N4RBX_offset.num
  _K_LT5.robax.rax_1 = _K_LT5.robax.rax_1 + N5LTX_offset.num
  _K_LB5.robax.rax_1 = _K_LB5.robax.rax_1 + N5LBX_offset.num
  _K_RT5.robax.rax_1 = _K_RT5.robax.rax_1 + N5RTX_offset.num
  _K_RB5.robax.rax_1 = _K_RB5.robax.rax_1 + N5RBX_offset.num
  _K_LT6.robax.rax_1 = _K_LT6.robax.rax_1 + N6LTX_offset.num
  _K_LB6.robax.rax_1 = _K_LB6.robax.rax_1 + N6LBX_offset.num
  _K_RT6.robax.rax_1 = _K_RT6.robax.rax_1 + N6RTX_offset.num
  _K_RB6.robax.rax_1 = _K_RB6.robax.rax_1 + N6RBX_offset.num
  
  _K_LT3.robax.rax_2 = _K_LT3.robax.rax_2 + N3LTY_offset.num
  _K_LB3.robax.rax_2 = _K_LB3.robax.rax_2 + N3LBY_offset.num
  _K_RT3.robax.rax_2 = _K_RT3.robax.rax_2 + N3RTY_offset.num
  _K_RB3.robax.rax_2 = _K_RB3.robax.rax_2 + N3RBY_offset.num
  _K_LT4.robax.rax_2 = _K_LT4.robax.rax_2 + N4LTY_offset.num
  _K_LB4.robax.rax_2 = _K_LB4.robax.rax_2 + N4LBY_offset.num
  _K_RT4.robax.rax_2 = _K_RT4.robax.rax_2 + N4RTY_offset.num
  _K_RB4.robax.rax_2 = _K_RB4.robax.rax_2 + N4RBY_offset.num
  _K_LT5.robax.rax_2 = _K_LT5.robax.rax_2 + N5LTY_offset.num
  _K_LB5.robax.rax_2 = _K_LB5.robax.rax_2 + N5LBY_offset.num
  _K_RT5.robax.rax_2 = _K_RT5.robax.rax_2 + N5RTY_offset.num
  _K_RB5.robax.rax_2 = _K_RB5.robax.rax_2 + N5RBY_offset.num
  _K_LT6.robax.rax_2 = _K_LT6.robax.rax_2 + N6LTY_offset.num
  _K_LB6.robax.rax_2 = _K_LB6.robax.rax_2 + N6LBY_offset.num
  _K_RT6.robax.rax_2 = _K_RT6.robax.rax_2 + N6RTY_offset.num
  _K_RB6.robax.rax_2 = _K_RB6.robax.rax_2 + N6RBY_offset.num

  local positions = {{},{},{_K_LB3,_K_LT3,_K_RT3,_K_RB3},{_K_LB4,_K_LT4,_K_RT4,_K_RB4},{_K_LB5,_K_LT5,_K_RT5,_K_RB5},{_K_LB6,_K_LT6,_K_RT6,_K_RB6}}

  local _LB = positions[N_Out.num][1]
  _LB.robax.rax_4 = 0
  local _LT = positions[N_Out.num][2]
  _LT.robax.rax_4 = -90
  local _RT = positions[N_Out.num][3]
  _RT.robax.rax_4 = -90
  local _RB = positions[N_Out.num][4]
  _RB.robax.rax_4 = -90
  
  local _p_2 = CopyJointTarget( _LB )
  _p_2.robax.rax_1 = (_LB.robax.rax_1 + _RB.robax.rax_1) / 2
  _p_2.robax.rax_2 = (_LB.robax.rax_2 + _RB.robax.rax_2) / 2
  _p_2.robax.rax_4 = 0
  
  local _p_11 = CopyJointTarget( _LB )
  _p_11.robax.rax_1 = (_LT.robax.rax_1 + _RT.robax.rax_1) / 2
  _p_11.robax.rax_2 = (_LT.robax.rax_2 + _RT.robax.rax_2) / 2
  _p_11.robax.rax_4 = -90
  
  local gap_LTLB_x = (_LB.robax.rax_1 - _LT.robax.rax_1) / 3
  local gap_LTLB_y = (_LB.robax.rax_2 - _LT.robax.rax_2) / 3
  
  local _p_4 = CopyJointTarget( _LB )
  _p_4.robax.rax_1 = _LT.robax.rax_1 + gap_LTLB_x * 2
  _p_4.robax.rax_2 = _LT.robax.rax_2 + gap_LTLB_y * 2
  _p_4.robax.rax_4 = 0
  
  local _p_7 = CopyJointTarget( _LB )
  _p_7.robax.rax_1 = _LT.robax.rax_1 + gap_LTLB_x * 1
  _p_7.robax.rax_2 = _LT.robax.rax_2 + gap_LTLB_y * 1
  _p_7.robax.rax_4 = 0
  
  local gap_RTRB_x = (_RB.robax.rax_1 - _RT.robax.rax_1) / 3
  local gap_RTRB_y = (_RB.robax.rax_2 - _RT.robax.rax_2) / 3
  
  local _p_6 = CopyJointTarget( _LB )
  _p_6.robax.rax_1 = _RT.robax.rax_1 + gap_RTRB_x * 2
  _p_6.robax.rax_2 = _RT.robax.rax_2 + gap_RTRB_y * 2
  _p_6.robax.rax_4 = -90
  
  local _p_9 = CopyJointTarget( _LB )
  _p_9.robax.rax_1 = _RT.robax.rax_1 + gap_RTRB_x * 1
  _p_9.robax.rax_2 = _RT.robax.rax_2 + gap_RTRB_y * 1
  _p_9.robax.rax_4 = -90
  
  local _p_5 = CopyJointTarget( _LB )
  _p_5.robax.rax_1 = (_p_4.robax.rax_1 + _p_6.robax.rax_1) / 2
  _p_5.robax.rax_2 = (_p_4.robax.rax_2 + _p_6.robax.rax_2) / 2
  _p_5.robax.rax_4 = 0
  
  local _p_8 = CopyJointTarget( _LB )
  _p_8.robax.rax_1 = (_p_7.robax.rax_1 + _p_9.robax.rax_1) / 2
  _p_8.robax.rax_2 = (_p_7.robax.rax_2 + _p_9.robax.rax_2) / 2
  _p_8.robax.rax_4 = -90

  Knext = GetJointTarget ("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  TPWrite("i:".._i.num)
  local _p_1_12 = {_p_8,_p_5,_p_2,_RB,_p_6,_p_9,_RT,_p_11,_LT,_p_7,_p_4,_LB}
  Knext = _p_1_12[_i.num]

  Knext.robax.rax_3 = N_safeHeight.num
  TPWrite("x:"..Knext.robax.rax_1.."/y:"..Knext.robax.rax_2)  
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  Knext.robax.rax_3 = K6LB.robax.rax_3 + 166 - _z.num * N_productHeight.num
  TPWrite("z:"..Knext.robax.rax_3)  
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  Sleep(1000)
  openGrab()
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)

  _i.num = _i.num + 1

  N_Action.num = 0 - N_grabToOut.num
end

function placePartition()
  if GetDI("DI_UNDER") == 0 then
    S_Error.val = "Partition dropped "
    N_Error.num = N_placePartition.num + 1
    Stop()
  end
  
  if (N_Out.num < 3) or (N_Out.num > 6) then
    S_Error.val = "N_Out num is wrong, should between 3 and 6"
    N_Error.num = N_placePartition.num + 2
    Stop()
  end  

  local _z_ = {0,0,N_Out3Z,N_Out4Z,N_Out5Z,N_Out6Z}
  local _z = _z_[N_Out.num]
  
  Knext = GetJointTarget ("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)  
  
  local _KP3 = CopyJointTarget( KP3 )
  _KP3.robax.rax_1 = _KP3.robax.rax_1 + N3PX_offset.num
  _KP3.robax.rax_2 = _KP3.robax.rax_2 + N3PY_offset.num
  local _KP4 = CopyJointTarget( KP4 )
  _KP4.robax.rax_1 = _KP4.robax.rax_1 + N4PX_offset.num
  _KP4.robax.rax_2 = _KP4.robax.rax_2 + N4PY_offset.num
  local _KP5 = CopyJointTarget( KP5 )
  _KP5.robax.rax_1 = _KP5.robax.rax_1 + N5PX_offset.num
  _KP5.robax.rax_2 = _KP5.robax.rax_2 + N5PY_offset.num
  local _KP6 = CopyJointTarget( KP6 )
  _KP6.robax.rax_1 = _KP6.robax.rax_1 + N6PX_offset.num
  _KP6.robax.rax_2 = _KP6.robax.rax_2 + N6PY_offset.num
  local _ps = {0,0,_KP3,_KP4,_KP5,_KP6}
  
  local _p = _ps[N_Out.num]
  Knext = CopyJointTarget( _p )
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v400,fine,tool0,wobj0,load0) 
  if GetDI("DI_UNDER") == 0 then
    S_Error.val = "Partition dropped while arrriving"
    N_Error.num = N_placePartition.num + 1
    Stop()
  end
  
  Knext.robax.rax_3 = _p.robax.rax_3 + 166 - _z.num * N_productHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)  
  stopSuck()
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)  
  
  N_Action.num = 0 - N_placePartition.num
end

function suckPartition()
  if GetDI("DI_UNDER") == 1 then
    S_Error.val = "something under the grab"
    N_Error.num = N_suckPartition.num + 1
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
  MoveAbsJ(Knext,v400,fine,tool0,wobj0,load0)  
  
  if WaitDI("DI_AIR_UP",1,5000) == true then
    S_Error.val = "Abnormal cylinder lifting, no up signal detected "
    N_Error.num = N_suckPartition.num + 2
    Stop()
  end
  if WaitDI("DI_AIR_DOWN",0,5000) == true then
    S_Error.val = "Abnormal cylinder lifting, the down signal is still there "
    N_Error.num = N_suckPartition.num + 3
    Stop()
  end

  Knext = CopyJointTarget( KsuckOffset_U )
  Knext.robax.rax_3 = N_safeHeight.num
  TPWrite("x:"..Knext.robax.rax_1.."/y:"..Knext.robax.rax_2)
  MoveAbsJ(Knext,v400,fine,tool0,wobj0,load0)  
  SetDO("DO_UP",0)
  MoveAbsJ(KsuckOffset_U,v200,fine,tool0,wobj0,load0)
  if GetDI("DI_UNDER") == 1 then
    S_Error.val = "there is a partition stuck on the shelf, remove it"
    N_Error.num = N_suckPartition.num + 6
    Stop()
  end  
  MoveAbsJ(Ksuck_U,v100,fine,tool0,wobj0,load0)
  if WaitDI("DI_AIR_UP",0,3000) == true then
    S_Error.val = "cylidner shoud be down, but the up signal is still there"
    N_Error.num = N_suckPartition.num + 2
    Stop()
  end
  if WaitDI("DI_AIR_DOWN",1,3000) == true then
    S_Error.val = "no cylidner down signal detected "
    N_Error.num = N_suckPartition.num + 3
    Stop()
  end
  
  local ret = SearchL("DI_UNDER",1,Psuck_D,Psuck,v100,tool0,wobj0)
  if ret == true then 
    local littleLow = GetJointTarget("Xyzw")
    littleLow.robax.rax_3 = littleLow.robax.rax_3 + 135
    MoveAbsJ(littleLow,v200,fine,tool0,wobj0,load0)
    suck()
  else
    S_Error.val = "Partition not found "
    N_Error.num = N_suckPartition.num + 1
  end
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
  if GetDI("DI_UNDER") == 0 then
    S_Error.val = "Partition dropped "
    N_Error.num = N_suckPartition.num + 1
    Stop()
  end
  
  N_Action.num = 0 - N_suckPartition.num

end


function toWait()
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  TPWrite("To safe height")
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  SetDO("DO_LIGHT",0)
  Knext.robax.rax_2 = Kwait.robax.rax_2
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  MoveAbsJ(Kwait,v200,fine,tool0,wobj0,load0)
  N_Action.num = 0 - N_toWait.num
end

function toWaitYZ()
  SetDO("DO_LIGHT",0)
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  TPWrite("To safe height")
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  SetDO("DO_LIGHT",0)
  Knext.robax.rax_2 = Kwait.robax.rax_2
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  N_Action.num = 0 - N_toWaitYZ.num
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
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
  local _K_LB1 = CopyJointTarget( K1LB )
  local _K_RB1 = CopyJointTarget( K1RB )
  local _K_LT1 = CopyJointTarget( K1LT )
  local _K_RT1 = CopyJointTarget( K1RT )
  local _K_LB2 = CopyJointTarget( K2LB )
  local _K_RB2 = CopyJointTarget( K2RB )
  local _K_LT2 = CopyJointTarget( K2LT )
  local _K_RT2 = CopyJointTarget( K2RT )
  
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
  
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
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
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  Knext.robax.rax_2 = Kwait.robax.rax_2
  MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
  
  N_productHeight.num = _productH
  
  local __x = _xyz[N_In.num][1]
  local __y = _xyz[N_In.num][2]
  local __z = _xyz[N_In.num][3]
  
  __x.num = __x.num + 1
  if __x.num > 5 then
    __x.num = 1
    __y.num = __y.num + 1
    if __y.num > 4 then
      __y.num = 1
      __z.num =  __z.num - 1
      if __z.num == 0 then
        S_Error.val = "pallet is empty"
        N_Error.num =  N_grabFromIn.num + 7
      end
    end
  end

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
  
  SetDO("DO_LIGHT",0)
  local p_v = {{K1LBV,K1LTV,K1RTV,K1RBV},{K2LBV,K2LTV,K2RTV,K2RBV}}
  
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
      TPWrite("x:"..current.robax.rax_1.."/y:".._current.robax.rax_1.."/d:"..distance)
      S_Error.val = "current position is unsuitable"
      N_Error.num = N_visionOnIn.num + 5
      Stop()
    end
  end
  
  Knext = CopyJointTarget(p_v[N_In.num][N_V_step.num])
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  SetDO("DO_LIGHT",1)
  N_V_step.num = N_V_step.num + 1
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
    MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
    
    Knext = CopyJointTarget(p_v[N_Out.num][N_V_step.num])
    Knext.robax.rax_3 = N_safeHeight.num
    MoveAbsJ(Knext,v200,fine,tool0,wobj0,load0)
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
  N_V_step.num = N_V_step.num + 1
  N_Action.num = 0 - N_visionOnOut.num 
  
end

function visionOnPartition()
   
  if (N_Out.num < 3) or (N_Out.num > 6) then
    S_Error.val = "N_In num is wrong, should between 3 and 6"
    N_Error.num = N_visionOnOut.num + 3
    Stop()
  end 
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  
  SetDO("DO_LIGHT",1)
  
  N_Action.num = 0 - N_visionOnPartition.num 
end

function correctPartition()
    
  if (N_Out.num < 3) or (N_Out.num > 6) then
    S_Error.val = "N_In num is wrong, should between 3 and 6"
    N_Error.num = N_correctPartition.num + 3
    Stop()
  end 
  
  SetDO("DO_LIGHT",0)
  
  Knext = GetJointTarget("Xyzw")
  Knext.robax.rax_3 = N_safeHeight.num
  MoveAbsJ(Knext,v100,fine,tool0,wobj0,load0)
  

  N_Action.num = 0 - N_correctPartition.num 
end

function getDistanceByK(K1,K2)
  local _x = math.abs(K1.robax.rax_1 - K2.robax.rax_1)
  local _y = math.abs(K1.robax.rax_2 - K2.robax.rax_2)
  local _z = math.abs(K1.robax.rax_3 - K2.robax.rax_3)
  
  local distance = (_x^2 + _y^2 + _z^2 + 0.0001)^0.5
  return distance
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
  MoveAbsJ(KRGV1_V,v100,fine,tool0,wobj0,load0)
  MoveAbsJ(KRGV5,v100,fine,tool0,wobj0,load0) 
  MoveAbsJ(KRGV5U,v100,fine,tool0,wobj0,load0)    
  MoveAbsJ(KRGV5_V,v100,fine,tool0,wobj0,load0)  
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

function _main()
  while true do
    Sleep(10)
    if GetDO("DO_AllowCrawl") == 1 then
      if N_Action.num == N_grabFromIn.num then
        grabFromIn()
      elseif N_Action.num == N_grabFromCache.num then
        grabFromCache()
      elseif N_Action.num == N_grabFromConveyor.num then
        grabFromConveyor()
      elseif N_Action.num == N_suckPartition.num then
        suckPartition()
      end
    else
      if N_Action.num == N_grabToRGV.num then
        grabToRGV()  
      elseif N_Action.num == N_grabToOut.num then
        grabToOut()   
      elseif N_Action.num == N_grabToCache.num then
        grabToCache()              
      elseif N_Action.num == N_grabToCart.num then
        grabToCart() 
      elseif N_Action.num == N_placePartition.num then
        placePartition() 
      end
    end
    if N_Action.num == N_visionOnIn.num then
      visionOnIn()
    elseif N_Action.num == N_visionOnOut.num then
      visionOnOut()
    elseif N_Action.num == N_visionOnConveyor.num then
      visionOnConveyor()
    elseif N_Action.num == N_visionOnPartition.num then
      visionOnPartition()
    elseif N_Action.num == N_toWait.num then
      toWait()    
    elseif N_Action.num == N_toWaitYZ.num then
      toWaitYZ()             
    elseif N_Action.num == N_correctPartition.num then
      correctPartition()       
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
NUMDATA("N3LBX_offset",0)
NUMDATA("N3LBY_offset",0)
NUMDATA("N3LTX_offset",0)
NUMDATA("N3LTY_offset",0)
NUMDATA("N3PX_offset",0)
NUMDATA("N3PY_offset",0)
NUMDATA("N3RBX_offset",0)
NUMDATA("N3RBY_offset",0)
NUMDATA("N3RTX_offset",0)
NUMDATA("N3RTY_offset",0)
NUMDATA("N4LBX_offset",0)
NUMDATA("N4LBY_offset",0)
NUMDATA("N4LTX_offset",0)
NUMDATA("N4LTY_offset",0)
NUMDATA("N4PX_offset",0)
NUMDATA("N4PY_offset",0)
NUMDATA("N4RBX_offset",0)
NUMDATA("N4RBY_offset",0)
NUMDATA("N4RTX_offset",0)
NUMDATA("N4RTY_offset",0)
NUMDATA("N5LBX_offset",0)
NUMDATA("N5LBY_offset",0)
NUMDATA("N5LTX_offset",0)
NUMDATA("N5LTY_offset",0)
NUMDATA("N5PX_offset",0)
NUMDATA("N5PY_offset",0)
NUMDATA("N5RBX_offset",0)
NUMDATA("N5RBY_offset",0)
NUMDATA("N5RTX_offset",0)
NUMDATA("N5RTY_offset",0)
NUMDATA("N6LBX_offset",0)
NUMDATA("N6LBY_offset",0)
NUMDATA("N6LTX_offset",0)
NUMDATA("N6LTY_offset",0)
NUMDATA("N6PX_offset",0)
NUMDATA("N6PY_offset",0)
NUMDATA("N6RBX_offset",0)
NUMDATA("N6RBY_offset",0)
NUMDATA("N6RTX_offset",0)
NUMDATA("N6RTY_offset",0)
NUMDATA("N_Action",1100)
NUMDATA("N_CacheX",3)
NUMDATA("N_CacheY",1)
NUMDATA("N_CacheZ",1)
NUMDATA("N_CartX",1)
NUMDATA("N_CartY",1)
NUMDATA("N_CartZ",1)
NUMDATA("N_Error",1101)
NUMDATA("N_H1",232)
NUMDATA("N_H2",166)
NUMDATA("N_H3",232)
NUMDATA("N_H4",166)
NUMDATA("N_H5",232)
NUMDATA("N_H6",166)
NUMDATA("N_Hshort",166)
NUMDATA("N_In",2)
NUMDATA("N_In10X",5)
NUMDATA("N_In10Y",0)
NUMDATA("N_In10Z",6)
NUMDATA("N_In1X",0)
NUMDATA("N_In1Y",1)
NUMDATA("N_In1Z",2)
NUMDATA("N_In2X",3)
NUMDATA("N_In2Y",1)
NUMDATA("N_In2Z",6)
NUMDATA("N_LB1_V_OffsetX",0)
NUMDATA("N_LB1_V_OffsetY",0)
NUMDATA("N_LB2_V_OffsetX",0)
NUMDATA("N_LB2_V_OffsetY",0)
NUMDATA("N_LT1_V_OffsetX",0)
NUMDATA("N_LT1_V_OffsetY",0)
NUMDATA("N_LT2_V_OffsetX",0)
NUMDATA("N_LT2_V_OffsetY",0)
NUMDATA("N_Out",5)
NUMDATA("N_Out3I",1)
NUMDATA("N_Out3Z",1)
NUMDATA("N_Out4I",1)
NUMDATA("N_Out4Z",1)
NUMDATA("N_Out5I",13)
NUMDATA("N_Out5Z",1)
NUMDATA("N_Out6I",5)
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
NUMDATA("N_RGVZ",1)
NUMDATA("N_RT1_V_OffsetX",0)
NUMDATA("N_RT1_V_OffsetY",0)
NUMDATA("N_RT2_V_OffsetX",0)
NUMDATA("N_RT2_V_OffsetY",0)
NUMDATA("N_V_step",5)
NUMDATA("N_cacheOffsetX",300)
NUMDATA("N_cacheOffsetY",330)
NUMDATA("N_cartOffsetX",310)
NUMDATA("N_cartOffsetY",270)
NUMDATA("N_conveyorOffsetR",45)
NUMDATA("N_conveyorOffsetX",0)
NUMDATA("N_conveyorOffsetY",0)
NUMDATA("N_correctPartition",1500)
NUMDATA("N_diam",200)
NUMDATA("N_grabFromCache",300)
NUMDATA("N_grabFromConveyor",700)
NUMDATA("N_grabFromIn",100)
NUMDATA("N_grabToCache",200)
NUMDATA("N_grabToCart",400)
NUMDATA("N_grabToOut",800)
NUMDATA("N_grabToRGV",900)
NUMDATA("N_grabZ1height",-1192)
NUMDATA("N_grabZoffset",40)
NUMDATA("N_placePartition",1100)
NUMDATA("N_productHeight",166)
NUMDATA("N_safeHeight",-1297)
NUMDATA("N_suckPartition",1000)
NUMDATA("N_toWait",500)
NUMDATA("N_toWaitYZ",1600)
NUMDATA("N_visionOnConveyor",600)
NUMDATA("N_visionOnIn",1200)
NUMDATA("N_visionOnOut",1300)
NUMDATA("N_visionOnPartition",1400)
NUMDATA("N_xxxxGrab",1500)
JOINTTARGET("K10",{-4016.840,1683.210,-82.854,-90.016,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1LB",{-9727.010,1712.370,-765.417,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1LBV",{-9727.010,1629.370,-1009.417,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1LT",{-9721.760,838.815,-760.058,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1LTV",{-9721.760,750.815,-1009.000,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1RB",{-8524.500,1713.230,-758.983,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1RBU",{-8524.500,1713.230,-1297.000,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1RBV",{-8524.500,1629.230,-1009.000,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1RT",{-8522.530,840.578,-759.956,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K1RTV",{-8522.530,750.000,-1009.000,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2LB",{-7913.800,1713.690,-758.815,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2LBV",{-7913.800,1629.690,-1009.815,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2LT",{-7912.870,838.693,-767.534,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2LTV",{-7912.870,750.693,-1009.000,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2RB",{-6715.410,1711.630,-757.582,-90.010,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2RBU",{-6715.410,1711.630,-1297.000,-90.010,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2RBV",{-6715.410,1629.630,-1009.000,-90.010,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2RT",{-6710.940,841.758,-757.090,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K2RTV",{-6710.940,750.000,-1009.000,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3LB",{-5204.290,1647.520,-75.862,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3LT",{-5203.600,866.703,-80.076,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3RB",{-4685.570,1649.010,-83.331,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3RT",{-4683.320,868.720,-82.594,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V1",{-5203.470,1348.090,-189.097,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V2",{-4685.545,1343.380,-189.116,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V3",{-5203.480,840.530,-189.103,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K3_V4",{-4685.552,840.528,-189.110,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4LB",{-4016.840,1683.210,-82.854,-90.016,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4LT",{-4022.640,899.048,-86.283,-90.016,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4RB",{-3495.890,1678.950,-78.910,-90.016,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4RT",{-3500.300,896.897,-84.239,-90.016,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V1",{-4016.470,1348.090,-189.097,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V2",{-3495.545,1343.380,-189.116,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V3",{-4016.480,840.530,-189.103,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K4_V4",{-3495.552,840.528,-189.110,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5LB",{-2480.100,1653.560,-78.816,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5LT",{-2468.630,881.895,-79.093,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5RB",{-1959.830,1663.240,-78.682,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5RT",{-1947.990,888.562,-79.809,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V1",{-2468.470,1348.090,-189.097,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V2",{-1959.545,1343.380,-189.116,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V3",{-2468.480,840.530,-189.103,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K5_V4",{-1959.552,840.528,-189.110,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6LB",{-1292.240,1656.860,-72.942,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6LT",{-1293.840,883.693,-82.526,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6RB",{-770.522,1658.780,-74.073,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6RT",{-773.941,881.847,-82.254,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V1",{-1371.470,1348.090,-189.097,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V2",{-680.545,1343.380,-189.116,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V3",{-1371.480,840.530,-189.103,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K6_V4",{-680.552,840.528,-189.110,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP3",{-5051.230,1279.610,-137.190,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP3U",{-5051.230,1279.610,-950.190,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP4",{-3868.040,1294.850,-137.842,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP4U",{-3868.040,1294.850,-950.842,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP5",{-2314.530,1279.590,-145.796,-179.432,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP5U",{-2326.280,1279.610,-950.842,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP6",{-1138.400,1277.440,-137.201,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KP6U",{-1138.400,1277.440,-950.201,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV1",{-5825.940,1361.160,-272.189,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV1U",{-5825.930,1361.160,-1044.760,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV1_V",{-6834.440,2554.310,-640.882,-94.912,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV5",{-5831.040,83.967,-271.473,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV5U",{-5831.040,83.967,-1297.000,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KRGV5_V",{-6838.390,1279.000,-648.485,-94.912,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("K_home_1",{-6447.070,1539.030,-1534.990,-94.892,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcacheCorner",{-8706.230,57.436,-189.931,-90.014,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcacheCornerU",{-8706.230,57.434,-1297.000,-90.014,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcartCorner",{-9759.480,-0.370,-195.537,-178.075,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KcartCorner_U",{-9759.480,-0.370,-1297.000,-178.075,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Kconveyor",{-1319.660,227.076,-116.054,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KconveyorU",{-1319.660,227.077,-626.525,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Kconveyor_V",{-1319.650,43.808,-254.545,-90.011,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KlineS",{-6852.470,2034.730,-1535.000,-94.925,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KlineSU",{-6852.470,2034.730,-1535.000,-94.925,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Knext",{0.000,0.000,0.000,0.000,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Ksuck",{-23.582,1225.050,-175.355,-179.097,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("KsuckOffset_U",{-23.584,1173.020,-755.609,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Ksuck_U",{-23.582,1225.050,-755.615,-179.098,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
JOINTTARGET("Kwait",{-5716.540,1308.100,-1297.000,-90.331,0.000,0.000,0.000},{0.000,0.000,0.000,0.000,0.000,0.000,0.000})
ROBTARGET("Psuck",{-23.580,1225.050,-175.360},{0.007874,0.000000,0.000000,-0.999969},{-2,0,0,0},{0.000,0.000,0.000,0.000,0.000,0.000,0.000},0.000)
ROBTARGET("Psuck_D",{-23.581,1225.050,-289.273},{0.007874,0.000000,0.000000,-0.999969},{-2,0,0,0},{0.000,0.000,0.000,0.000,0.000,0.000,0.000},0.000)
ROBTARGET("Psuck_U",{-23.580,1225.050,-755.620},{0.007874,0.000000,0.000000,-0.999969},{-2,0,0,0},{0.000,0.000,0.000,0.000,0.000,0.000,0.000},0.000)
STRINGDATA("S_Code","0")
STRINGDATA("S_Error","0")
end
print("The end!")