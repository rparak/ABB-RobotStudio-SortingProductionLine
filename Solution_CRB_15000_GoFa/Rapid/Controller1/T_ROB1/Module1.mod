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
    ! File Name: T_ROB1/Module1.mod
    ! ## =========================================================================== ## 
    
    ! Environment Parameters Structure
    RECORD environment_param_str
        num tAB_offset_x; 
        num tAB_offset_y; 
        num tC_AB_offset_x;
    ENDRECORD
    ! Robot Parameters Structure
    RECORD robot_param
        speeddata speed;
        zonedata zone;
    ENDRECORD
    ! Robot Control Structure
    RECORD robot_ctrl_str
        num actual_state;
        num tAB_actual_counter;
        num objec_type;
        robot_param r_param; 
        environment_param_str env_param;
    ENDRECORD
    ! Call Main Structure
    VAR robot_ctrl_str r_str;

    ! Main waypoints (targets) for robot control
    CONST robtarget Target_TAB_CONV:=[[293.704,-598.479,173.926],[0,1,0,0],[-1,0,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_CONV_PR:=[[206.204,-598.479,163.182],[0,1,0,0],[-1,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_TAB:=[[149.017,611.162,36],[0,1,0,0],[0,0,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_INIT_AP1:=[[428.805,60.124,25.5],[0,1,0,0],[0,0,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget Target_HOME:=[[768.076436353,100.004,739.281532303],[0.5,0,0.866025404,0],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];

    ! ################################## Sorting Machine (Robot 2) - Main Cycle ################################## !
    PROC main()
        TEST r_str.actual_state
            CASE 0:
                ! ******************** INITIALIZATION STATE ******************** !
                ! Initialize the parameters
                INIT_PARAM;        
                ! Set object type (1 -> Orange, 2 -> Blue, 3 -> Red)
                r_str.objec_type := 3;
                ! Restore the environment
                RESET_ENV;
                ! Move -> Home position
                MoveAbsJ [[0,0,0,0,90,0],[0,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs,r_str.r_param.speed,r_str.r_param.zone,smc_gripper\WObj:=wobj0;
    
                ! check -> object selected?
                IF r_str.objec_type > 0 THEN
                    ! Change state -> {P&P (Tab. -> Conveyor)}
                    r_str.actual_state := 1;
                ENDIF
            
            CASE 1:
                ! ******************** Pick&Place TAB. STATE ******************** !
                ! Call function for the P&P trajectory (from the position of the robotic table to the conveyor | use smc vacuum gripper)
                PP_TAB_CONV;
                ! Change state -> {P&P (Tab. Obj. -> Conveyor Tab.)}
                r_str.actual_state := 2;
            CASE 2:
                ! ******************** Pick&Place TAB. OBJ. STATE ******************** !
                ! Call function for the P&P trajectory (from the position of the robotic table (objects holder) to the conveyor (Main. Tab.) | use smc vacuum gripper)
                ! Input parameters -> see function description below
                PP_TP_AB r_str.objec_type, r_str.tAB_actual_counter, (r_str.objec_type - 1)*r_str.env_param.tAB_offset_x, r_str.tAB_actual_counter*r_str.env_param.tAB_offset_y, r_str.tAB_actual_counter*r_str.env_param.tC_AB_offset_x;
                
                ! increase the counter (+1) -> P&P with another object in the same type of class
                r_str.tAB_actual_counter := r_str.tAB_actual_counter + 1;
                
                IF r_str.tAB_actual_counter > 1 THEN
                    ! Change state -> {Back to Home}
                    r_str.actual_state := 4;
                ENDIF
            CASE 4:
                ! ******************** Back to Home STATE ******************** !
                ! Attach objects of the same type in the Main Tab. (move multiple objects along the conveyor)
                IF r_str.objec_type = 1 THEN
                    ! Objects (Orange A1 + Orange B1)
                    PulseDO DO_ATT_AB1;
                ELSEIF r_str.objec_type = 2 THEN
                    ! Objects (Blue A2 + Blue B2)
                    PulseDO DO_ATT_AB2;
                ELSEIF r_str.objec_type = 3 THEN
                    ! Objects (Red A3 + Red B3)
                    PulseDO DO_ATT_AB3;
                ENDIF
                
                ! Move -> Home position
                MoveAbsJ [[0,0,0,0,90,0],[0,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs,r_str.r_param.speed,r_str.r_param.zone,smc_gripper\WObj:=wobj0;
                ! Change state -> {Start the conveyor}
                r_str.actual_state := 5;
            CASE 5:
                ! ******************** Start the conveyor ******************** !
                ! Digital Output -> Start the conveyor (Simulation Logic)
                SetDO DO_ENABLE_CONV, 1;
                ! Change state -> {Conveyor check state}
                r_str.actual_state := 6;
            CASE 6:
                ! ******************** Conveyor State ******************** !
                ! Check the condition of the conveyor (In position or Not)
                IF DI_CONV_IN_POS = 1 THEN
                    ! Reset digital output (Conveyor stopped)
                    SetDO DO_ENABLE_CONV, 0;
                    ! Change state -> {empty}
                    r_str.actual_state := 7;
                ENDIF
            CASE 7:
                ! ******************** EMPTY STATE ******************** !
                Stop;

        ENDTEST
    ENDPROC
    
    ! ################################## P&P FUNCTION (TAB -> CONVEYOR) ################################## !
    PROC PP_TAB_CONV()
        ! ====== Pick Trajectory ====== !
        MoveJ Offs(Target_TAB,0,0,200),r_str.r_param.speed,r_str.r_param.zone,smc_gripper;
        MoveL Offs(Target_TAB,0,0,0),v100,fine,smc_gripper;
        ! Signal -> Attach the object (Main Table): The location of the object is on the robotic table.
        PulseDO DO_ATT_TAB;
        WaitTime 0.25;
        MoveL Offs(Target_TAB,0,0,200),r_str.r_param.speed,r_str.r_param.zone,smc_gripper;
        ! ====== Place Trajectory ====== !
        MoveJ Offs(Target_TAB_CONV,0,0,100),r_str.r_param.speed,r_str.r_param.zone,smc_gripper;
        MoveL Offs(Target_TAB_CONV,0,0,0),v100,fine,smc_gripper;
        ! Signal -> Detach the object (Main Table): The location of the object is on the conveyor.
        PulseDO DO_DET_TAB;
        WaitTime 0.25;
        MoveL Offs(Target_TAB_CONV,0,0,100),r_str.r_param.speed,r_str.r_param.zone,smc_gripper;
    ENDPROC
    ! ################################## P&P FUNCTION (OBJ. H. -> MAIN TAB. CONVEYOR) ################################## !
    PROC PP_TP_AB(num obj_t, num obj_p, num offset_T_x, num offset_T_y, num offset_C_x)
        ! ========================================================== !
        ! Description: Simple function for the creation of the trajectory (P&P Task with DO selection).
        !
        ! IN:
        ! [1] obj_t: Type of the object (Color - 1, 2, 3)
        ! [2] obj_p: Type of the P&P operation (0 -> Attach, 1 -> Detach)
        ! [3] offset_T_x: Offset of the object -> Robotic table holder (x position)
        ! [4] offset_T_y: Offset of the object -> Robotic table holder (y position)
        ! [5] offset_C_y: Offset of the object -> Conveyor Main. Tab. (y position)
        ! ========================================================== !
        
        ! ====== Pick Trajectory ====== !
        MoveJ Offs(Target_INIT_AP1,0 + offset_T_x,0 + offset_T_y,200),r_str.r_param.speed,r_str.r_param.zone,smc_gripper;
        MoveL Offs(Target_INIT_AP1,0 + offset_T_x,0 + offset_T_y,0),v300,fine,smc_gripper;
        ! Signal -> Attach the object (Main Table): The location of the object is on the robotic table (objects holder).
        ! Call function to select the correct digital output (Attacher)
        OBJECT_MANIP obj_t, 0, obj_p;
        WaitTime 0.25;
        MoveL Offs(Target_INIT_AP1,0 + offset_T_x,0 + offset_T_y,200),r_str.r_param.speed,r_str.r_param.zone,smc_gripper;
        ! ====== Place Trajectory ====== !
        MoveJ Offs(Target_CONV_PR,0 + offset_C_x,0,200),r_str.r_param.speed,r_str.r_param.zone,smc_gripper;
        MoveL Offs(Target_CONV_PR,0 + offset_C_x,0,0),v300,fine,smc_gripper;
        ! Signal -> Detach the object (Main Table): The location of the object is on the conveyor (Main. Tab.)
        ! Call function to select the correct digital output (Detacher)
        OBJECT_MANIP obj_t, 1, obj_p;
        WaitTime 0.25;
        MoveL Offs(Target_CONV_PR,0 + offset_C_x,0,200),r_str.r_param.speed,r_str.r_param.zone,smc_gripper;
    ENDPROC
    
    PROC OBJECT_MANIP(num object_type, num pp_type, num pp_pos)
        ! ========================================================== !
        ! Description: Simple function for selection of the correct digital output.
        !
        ! IN:
        ! [1] object_type: Type of the object (Color - 1, 2, 3)
        ! [2] pp_type: Type of the P&P operation (0 -> Attach, 1 -> Detach)
        ! [3] pp_pos: Position of the object in the holder (0, 1).
        ! ========================================================== !
        
        TEST object_type
            CASE 1:
                ! ***** Type (1) Orange ***** !
                ! Object Position (Type A)
                IF pp_type = 0 AND pp_pos = 0 THEN
                    PulseDO DO_ATT_AP1;
                ELSEIF pp_type = 1 AND pp_pos = 0 THEN
                    PulseDO DO_DET_AP1;
                ENDIF
                ! Object Position (Type B)
                IF pp_type = 0 AND pp_pos = 1 THEN
                    PulseDO DO_ATT_BP1;
                ELSEIF pp_type = 1 AND pp_pos = 1 THEN
                    PulseDO DO_DET_BP1;
                ENDIF
            CASE 2:
                ! ***** Type (2) Blue ***** !
                ! Object Position (Type A)
                IF pp_type = 0 AND pp_pos = 0 THEN
                    PulseDO DO_ATT_AP2;
                ELSEIF pp_type = 1 AND pp_pos = 0 THEN
                    PulseDO DO_DET_AP2;
                ENDIF
                ! Object Position (Type B)
                IF pp_type = 0 AND pp_pos = 1 THEN
                    PulseDO DO_ATT_BP2;
                ELSEIF pp_type = 1 AND pp_pos = 1 THEN
                    PulseDO DO_DET_BP2;
                ENDIF
            CASE 3:
                ! ***** Type (1) Red ***** !
                ! Object Position (Type A)
                IF pp_type = 0 AND pp_pos = 0 THEN
                    PulseDO DO_ATT_AP3;
                ELSEIF pp_type = 1 AND pp_pos = 0 THEN
                    PulseDO DO_DET_AP3;
                ENDIF
                ! Object Position (Type B)
                IF pp_type = 0 AND pp_pos = 1 THEN
                    PulseDO DO_ATT_BP3;
                ELSEIF pp_type = 1 AND pp_pos = 1 THEN
                    PulseDO DO_DET_BP3;
                ENDIF
        ENDTEST
    ENDPROC
    
    ! ################################## INIT PARAMETERS ################################## !
    PROC INIT_PARAM()   
        ! Simple counter to determine the position of the objects
        r_str.tAB_actual_counter := 0;

        ! Intitialization parameters of the environment
        ! Table offset: Type A, B; Position 1,2,3
        r_str.env_param.tAB_offset_x := 87.5; 
        r_str.env_param.tAB_offset_y := 300.00021478; 
        ! Conveyor offset: Position 1,2
        r_str.env_param.tC_AB_offset_x := 175;
        
        ! Intitialization parameters of the robot
        ! Speed
        r_str.r_param.speed := [400, 400, 400, 400];
        ! Zone 
        r_str.r_param.zone  := z50;
    ENDPROC
    ! ################################## RESET ENVIRONMENT ################################## !
    PROC RESET_ENV()
        ! Reset DO (Digital Output)
        ! Detacher {Environment}
        PulseDO DO_RESET_ENV;
        ! Detacher {Tab. Type A -> 3 objects}
        PulseDO DO_DET_AP1;
        PulseDO DO_DET_AP2;
        PulseDO DO_DET_AP3;
        ! Detacher {Tab. Type B -> 3 objects}
        PulseDO DO_DET_BP1;
        PulseDO DO_DET_BP2;
        PulseDO DO_DET_BP3;
        ! Detacher {Main Tab.}
        PulseDO DO_DET_TAB;
        ! Detacher {Objects of the same type in the Tab.}
        PulseDO DO_DET_AB1;
        PulseDO DO_DET_AB2;
        PulseDO DO_DET_AB3;
        ! Digital output (Conveyor stopped)
        SetDO DO_ENABLE_CONV, 0;
    ENDPROC
    ! ################################## TEST TARGETS ################################## !
    PROC Path_Targets_Test()
        MoveJ Target_HOME,v400,fine,smc_gripper;
        MoveJ Target_TAB,v400,fine,smc_gripper;
        MoveJ Target_TAB_CONV,v400,fine,smc_gripper;
        MoveL Target_INIT_AP1,v400,fine,smc_gripper;
        MoveL Target_CONV_PR,v400,fine,smc_gripper;
    ENDPROC
    PROC Path_10()

    ENDPROC
ENDMODULE