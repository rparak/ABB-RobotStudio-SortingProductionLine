MODULE Module1
    ! ## =========================================================================== ## 
    ! MIT License
    ! Copyright (c) 2021 Roman Parak
    ! Permission is hereby granted, free of charge, to any person obtaining a copy
    ! of this software and associated documentation files (the "Software"), to deal
    ! in the Software without restriction, including without limitation the rights
    ! to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    ! copies of the Software, and to permit persons to whom the Software is
    ! furnished to do so, subject to the following conditions:
    ! The above copyright notice and this permission notice shall be included in all
    ! copies or substantial portions of the Software.
    ! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    ! IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    ! FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    ! AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    ! LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    ! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    ! SOFTWARE.
    ! ## =========================================================================== ## 
    ! Author   : Roman Parak
    ! Email    : Roman.Parak@outlook.com
    ! Github   : https://github.com/rparak
    ! File Name: T_ROB2/Module1.mod
    ! ## =========================================================================== ## 

    ! Robot Parameters Structure
    RECORD robot_param
        speeddata speed;
        zonedata zone;
    ENDRECORD
    ! Robot Control Structure
    RECORD robot_ctrl_str
        num actual_state;
        robot_param r_param;
    ENDRECORD
    ! Call Main Structure
    VAR robot_ctrl_str r_str;
    
    ! Main waypoints (targets) for robot control
    CONST robtarget Target_BOX_H:=[[294.921429625,-2692.462825645,94.5],[0,-0.707106781,0.707106781,0],[-1,1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_INIT_H:=[[728.447086618,-2888.527825645,14.5],[0,-0.707106781,0.707106781,0],[-1,-3,2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_TAB_BOX:=[[294.486429625,-2691.952825645,94.264],[0,0,1,0],[0,0,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_TAB_CONV:=[[-445.993570375,-3008.629825645,185.426],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    ! ################################## Sorting Machine (Robot 2) - Main Cycle ################################## !
    PROC main()
        TEST r_str.actual_state
            CASE 0:
                ! ******************** INITIALIZATION STATE ******************** !
                ! Initialize the parameters
                INIT_PARAM;
                ! Restore the environment
                RESET_ENV;
                ! Move -> Home position
                MoveAbsJ [[0,0,0,0,90,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs,r_str.r_param.speed,r_str.r_param.zone,Servo\WObj:=wobj0;
                ! Change state -> {Wait for the signal}
                r_str.actual_state := 1;   
            CASE 1:
                ! ******************** WAIT STATE ******************** !
                ! Wait for the digital input from the simulation logic and/or T_ROB1
                ! -> until the command from the conveyor sensor is issued (the TAB. is in position)
                WaitDI DI_CONV_IN_POS, 1;
                ! Change state -> {P&P (Conveyor Tab. -> BOX)}
                r_str.actual_state := 2;  
            CASE 2:
                ! ******************** Pick&Place TAB. STATE ******************** !
                ! Call function for the P&P trajectory (from the position of the holder to the box | use fingers on the gripper (SG -> Smart gripper))
                PP_TAB_CONV;
                ! Change state -> {P&P (Holder -> BOX)}
                r_str.actual_state := 3;
            CASE 3:
                ! ******************** Pick&Place TAB. Holder STATE ******************** !
                ! Call function for the P&P trajectory (from the position of the holder to the box | use a vacuum gripper (SG -> Smart gripper))
                PP_TAB_H;
                ! Change state -> {Back to Home}
                r_str.actual_state := 4;
            CASE 4:
                ! ******************** Back to Home STATE ******************** !
                ! Move -> Home position
                MoveAbsJ [[0,0,0,0,90,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs,r_str.r_param.speed,r_str.r_param.zone,Servo\WObj:=wobj0;
                ! Change state -> {empty}
                r_str.actual_state := 5;
            CASE 5:
                ! ******************** EMPTY STATE ******************** !
		Stop;
        ENDTEST
    ENDPROC
    
    ! ################################## P&P FUNCTION (TAB -> BOX) ################################## !
    PROC PP_TAB_CONV()
        ! ====== Pick Trajectory ====== !
        MoveL Offs(Target_TAB_CONV,0,0,200),r_str.r_param.speed,r_str.r_param.zone,Servo\WObj:=wobj0;
        MoveL Offs(Target_TAB_CONV,0,0,0),v100,fine,Servo\WObj:=wobj0;
        ! Signal -> Move the position of the fingers (SyncePose): Gripp the object
        WaitTime 0.25;
        PulseDO DO_SG_P;
        ! Signal -> Attach the object (Table - Type AB): The location of the object is on the conveyor.
        PulseDO DO_ATT_TTAB;
        WaitTime 0.25;
        MoveL Offs(Target_TAB_CONV,0,0,200),r_str.r_param.speed,r_str.r_param.zone,Servo\WObj:=wobj0;
        ! ====== Place Trajectory ====== !
        MoveJ Offs(Target_TAB_BOX,0,0,100),r_str.r_param.speed,r_str.r_param.zone,Servo\WObj:=wobj0;
        MoveL Offs(Target_TAB_BOX,0,0,0),v100,fine,Servo\WObj:=wobj0;
        ! Signal -> Move the position of the fingers (HomePose): Release the object
        PulseDO DO_SG_R;
        WaitTime 0.25;
        ! Signal -> Detach the object (Table - Type AB): The location of the object is on the BOX.
        PulseDO DO_DET_TTAB;
        WaitTime 0.25;
        MoveL Offs(Target_TAB_BOX,0,0,100),r_str.r_param.speed,r_str.r_param.zone,Servo\WObj:=wobj0;
    ENDPROC
    
    ! ################################## P&P FUNCTION (HOLDER -> BOX) ################################## !
    PROC PP_TAB_H()
        ! ====== Pick Trajectory ====== !
        MoveJ Offs(Target_INIT_H,0,0,100),r_str.r_param.speed,r_str.r_param.zone,VaccumOne\WObj:=wobj0;
        MoveL Offs(Target_INIT_H,0,0,0),v100,fine,VaccumOne\WObj:=wobj0;
        ! Signal -> Attach the object (Box Holder): The location of the object is on the robotic Table.
        WaitTime 0.25;
        PulseDO DO_ATT_BH;
        MoveL Offs(Target_INIT_H,0,0,100),r_str.r_param.speed,r_str.r_param.zone,VaccumOne\WObj:=wobj0;
        ! ====== Place Trajectory ====== !
        MoveJ Offs(Target_BOX_H,0,0,100),r_str.r_param.speed,r_str.r_param.zone,VaccumOne\WObj:=wobj0;
        MoveL Offs(Target_BOX_H,0,0,0),v100,fine,VaccumOne\WObj:=wobj0;
        ! Signal -> Detach the object (Box Holder): The location of the object is on the BOX.
        PulseDO DO_DET_BH;
        WaitTime 0.25;
        MoveL Offs(Target_BOX_H,0,0,100),r_str.r_param.speed,r_str.r_param.zone,VaccumOne\WObj:=wobj0;
    ENDPROC
    
    ! ################################## INIT PARAMETERS ################################## !
    PROC INIT_PARAM()
        ! Intitialization parameters of the robot
        ! Speed
        r_str.r_param.speed := [300, 300, 300, 300];
        ! Zone
        r_str.r_param.zone  := z50;
    ENDPROC
    ! ################################## RESET ENVIRONMENT ################################## !
    PROC RESET_ENV()
        ! Reset DO (Digital Output)
        ! Detacher {BOX Holder}
        PulseDO DO_DET_BH;
        ! Detacher {Table - Type AB)}
        PulseDO DO_DET_TTAB;
        ! Smart Gripper -> Release
        PulseDO DO_SG_R;
    ENDPROC
    ! ################################## TEST TARGETS ################################## !
    PROC Path_Targets_Test()
        MoveL Target_INIT_H,v100,fine,VaccumOne\WObj:=wobj0;
        MoveL Target_BOX_H,v1000,z100,VaccumOne\WObj:=wobj0;
        MoveL Target_TAB_CONV,v1000,z100,Servo\WObj:=wobj0;
        MoveL Target_TAB_BOX,v1000,z100,Servo\WObj:=wobj0;
    ENDPROC
ENDMODULE