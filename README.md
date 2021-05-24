# ABB RobotStudio - Sorting Machine

## Requirements:

**Software:**
```bash
ABB RobotStudio
```

**RobotWare:**
```bash
Version 6.10
```

Link ABB RS: https://new.abb.com/products/robotics/robotstudio/downloads

## Project Description:

The project focuses on controlling multiple robots using the simulation tool RobotStudio ABB. Robot on table no. 1 communicates with another robot on table no. 2 using a conveyor belt. The main goal of the project is to create a simple sorting production line.

Main challenges of project implementation:
- object manipulation using an smart gripper (ABB), simple vacuum gripper
- data communication between the multiple robotic arms
- conveyor belt control
- clean rapid program using functions, structures, etc.

The project was created to improve the [VRM (Programming for Robots and Manipulators)](https://github.com/rparak/Programming-for-robots-and-manipulators-VRM) university course.

The project was realized at Institute of Automation and Computer Science, Brno University of Technology, Faculty of Mechanical Engineering (NETME Centre - Cybernetics and Robotics Division).


**Unpacking a station (/Final/Solution_Sorting_Machine.rspag):**
1. On the File tab, click Open and then browse to the folder and select the Pack&Go file, the Unpack & Work wizard opens.
2. In the Welcome to the Unpack & Work Wizard page, click Next.
3. In the Select package page, click Browse and then select the Pack & Go file to unpack and the Target folder. Click Next.
4. In the Library handling page select the target library. Two options are available, Load files from local PC or Load files from Pack & Go. Click the option to select the location for loading the required files, and click Next.
5. In the Virtual Controller page, select the RobotWare version and then click Locations to access the RobotWare Add-in and Media pool folders. Optionally, select the check box to automatically restore backup. Click Next.
6. In the Ready to unpack page, review the information and then click Finish.

<p align="center">
  <img src="https://github.com/rparak/ABB-RobotStudo-Tutorial-SortingMachine/blob/main/images/1_1.PNG" width="800" height="450">
  <img src="https://github.com/rparak/ABB-RobotStudo-Tutorial-SortingMachine/blob/main/images/1_2.PNG" width="800" height="450">
  <img src="https://github.com/rparak/ABB-RobotStudo-Tutorial-SortingMachine/blob/main/images/1_3.png" width="800" height="450">
</p>

## Project Hierarchy:

**Repositary [/ABB-RobotStudo-Tutorial-SortingMachine/]:**

```bash
[ Project Template (without a robot) ] /Template/

/IRB_1200/ -> ABB IRB 1200
[ Main Program (.rspag)                             ] /IRB_1200/Final/
[ Example of the resulting application              ] /IRB_1200/Exe_file/
[ Rapid codes (.mod) - Controller1(Right/Left Arm)  ] /IRB_1200/Rapid/

/Solution_CRB_15000_GoFa/ -> ABB CRB 15000 GoFa
[ Main Program (.rspag)                ] /Solution_CRB_15000_GoFa/Final/
[ Example of the resulting application ] /Solution_CRB_15000_GoFa/Exe_file/
[ Rapid codes (.mod) - Controller1,2   ] /Solution_CRB_15000_GoFa/Rapid/

[ Scene parts, gripper, etc. ] /Project_Materials/
```

## Application:

**ABB CRB 15000 (GoFa):**
<p align="center">
  <img src="https://github.com/rparak/ABB-RobotStudo-Tutorial-SortingMachine/blob/main/images/3_1.png" width="380" height="225">
  <img src="https://github.com/rparak/ABB-RobotStudo-Tutorial-SortingMachine/blob/main/images/3_2.png" width="380" height="225">
  <img src="https://github.com/rparak/ABB-RobotStudo-Tutorial-SortingMachine/blob/main/images/3_3.png" width="380" height="225">
  <img src="https://github.com/rparak/ABB-RobotStudo-Tutorial-SortingMachine/blob/main/images/3_4.png" width="380" height="225">
  <img src="https://github.com/rparak/ABB-RobotStudo-Tutorial-SortingMachine/blob/main/images/3_5.png" width="380" height="225">
  <img src="https://github.com/rparak/ABB-RobotStudo-Tutorial-SortingMachine/blob/main/images/3_6.png" width="380" height="225">
  <img src="https://github.com/rparak/ABB-RobotStudo-Tutorial-SortingMachine/blob/main/images/3_7.png" width="760" height="450">
</p>

**ABB IRB 1200:**
<p align="center">
  <img src="https://github.com/rparak/ABB-RobotStudo-Tutorial-SortingMachine/blob/main/images/2_1.png" width="400" height="225">
  <img src="https://github.com/rparak/ABB-RobotStudo-Tutorial-SortingMachine/blob/main/images/2_2.png" width="400" height="225">
  <img src="https://github.com/rparak/ABB-RobotStudo-Tutorial-SortingMachine/blob/main/images/2_3.png" width="400" height="225">
  <img src="https://github.com/rparak/ABB-RobotStudo-Tutorial-SortingMachine/blob/main/images/2_4.png" width="400" height="225">
  <img src="https://github.com/rparak/ABB-RobotStudo-Tutorial-SortingMachine/blob/main/images/2_5.png" width="400" height="225">
  <img src="https://github.com/rparak/ABB-RobotStudo-Tutorial-SortingMachine/blob/main/images/2_6.png" width="400" height="225">
  <img src="https://github.com/rparak/ABB-RobotStudo-Tutorial-SortingMachine/blob/main/images/2_7.png" width="800" height="450">
</p>

## Result:

Youtube: ...

## Contact Info:
Roman.Parak@outlook.com

## License
[MIT](https://choosealicense.com/licenses/mit/)
