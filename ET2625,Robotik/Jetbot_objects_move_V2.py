
#=========================import Python libs========================
import os
import numpy as np
import matplotlib.pyplot as plt
import random
from time import sleep
#sleep(0.05)

import omni
import carb

#Start ISaac SIM with GUI
from omni.isaac.kit import SimulationApp
#=========================OPEN an Isaac SIM SESSION with GUI==========================
CONFIG = {
    "width": 1280,
    "height": 720,
    "window_width": 1920,
    "window_height": 1200,
    "headless": False,
    # "renderer": "RayTracedLighting",
    # "display_options": 3286,  # Set display options to show default grid
}
simulation_app = SimulationApp(CONFIG)
# simulation_app = SimulationApp({"headless": False, "additional_args": ["--/app/window/maximized=true"]})
# simulation_app = SimulationApp({"headless": False, "additional_args": ["--/app/window/resizable=true","--/app/window/maximized=true"]})
simulation_app._wait_for_viewport()

#=========================Import OMNI Libraries=============================
import omni
from pxr import Usd, UsdGeom
import omni.usd
from omni.isaac.core import World
# import random
# import omni.isaac.debug_draw as debug_draw
from omni.isaac.debug_draw import _debug_draw
draw = _debug_draw.acquire_debug_draw_interface()
# import random

from omni.isaac.core.objects import DynamicCuboid, VisualCuboid
from omni.isaac.core.utils.nucleus import get_assets_root_path
from omni.isaac.wheeled_robots.controllers.differential_controller import DifferentialController
from omni.isaac.wheeled_robots.robots import WheeledRobot
# from omni.isaac.utils.scripts.scene_utils import create_viewport
from omni.isaac.sensor import Camera
from omni.isaac.core.utils import prims
from omni.isaac.core.articulations import Articulation


#=========================SETUP world======================
my_world = World(stage_units_in_meters=1.0)
my_world.initialize_physics()
my_world.set_simulation_dt(physics_dt=1 / 60.0, rendering_dt=1 / 60.0)

# app = Application()
# scene = simulation_app.get_scene()
#===========================Add Ground=====================
from omni.isaac.core.physics_context import PhysicsContext
PhysicsContext()
# from omni.isaac.core.objects.ground_plane import GroundPlane
# GroundPlane(prim_path="/World/groundPlane", size=10, color=np.array([0.5, 0.5, 0.5]))
ground_plane=my_world.scene.add_default_ground_plane()
#=============================Add Warehouse==================
#Add Warehouse
from omni.isaac.core.utils.stage import add_reference_to_stage
from omni.isaac.dynamic_control import _dynamic_control
from omni.physx.scripts import utils ## added to use colliders to the warehouse

# Acquire dynamic control winterface
# dc = _dynamic_control.acquire_dynamic_control_interface()

wh_usdpath="http://omniverse-content-production.s3-us-west-2.amazonaws.com/Assets/ArchVis/Industrial/Buildings/Warehouse/Warehouse01.usd"
wh_path = "/World/Warehouse"
wh_prim = add_reference_to_stage(usd_path=wh_usdpath, prim_path=wh_path)
xformAPI = UsdGeom.XformCommonAPI(wh_prim)
utils.setCollider(wh_prim) #add colliders to warehouse ,modified by us 
xformAPI.SetScale((0.001, 0.001, 0.001))
#===========================Add Jetbot======================
assets_root_path = get_assets_root_path()
if assets_root_path is None:
    carb.log_error("Could not find Isaac Sim assets folder")
jetbot_asset_path = assets_root_path + "/Isaac/Robots/Jetbot/jetbot.usd"
JB = my_world.scene.add(
    WheeledRobot(
        prim_path="/World/Jetbot",
        name="my_jetbot",
        wheel_dof_names=["left_wheel_joint", "right_wheel_joint"],
        create_robot=True,
        usd_path=jetbot_asset_path,
        position=np.array([0.5, 0.5, .1]),
    )
)
#---------Add differential controller to the robot----
JB_controller = DifferentialController(name="simple_control", wheel_radius=0.03, wheel_base=0.1125)
# ----------Get the camera object------------
camera_prim_path = "/World/Jetbot/chassis/rgb_camera/jetbot_camera"
JBcam = Camera(camera_prim_path)
JBcam.initialize()
#==============Add Obstacles=============
OBJ=[]
Nobj=20
Posbounds=np.array([[-2, 2],[-2, 2],[.1, .2]])
Scalebounds=np.array([[.1,.2],[.1,.2],[.1,.2]])

for i in range(Nobj):
    x=np.random.rand()*(Posbounds[0][0]-Posbounds[0][1])+Posbounds[0][1]
    y=np.random.rand()*(Posbounds[1][0]-Posbounds[1][1])+Posbounds[1][1]
    z=np.random.rand()*(Posbounds[2][0]-Posbounds[2][1])+Posbounds[2][1]
    xscale=np.random.rand()*(Scalebounds[0][0]-Scalebounds[0][1])+Scalebounds[0][1]
    yscale=np.random.rand()*(Scalebounds[1][0]-Scalebounds[1][1])+Scalebounds[1][1]
    zscale=np.random.rand()*(Scalebounds[2][0]-Scalebounds[2][1])+Scalebounds[2][1]
    if i==0:
        objname="TARGET"
        objcolor=np.array([255, 0, 0])
        xscale=.2
        yscale=.2
        zscale=.2
        x=.1
        y=0
        z=0
    else:
        objname="Obstacle"+str(i)
        objcolor=np.array([0, 0, 255])
        xscale=np.random.rand()*(Scalebounds[0][0]-Scalebounds[0][1])+Scalebounds[0][1]
        yscale=np.random.rand()*(Scalebounds[1][0]-Scalebounds[1][1])+Scalebounds[1][1]
        zscale=np.random.rand()*(Scalebounds[2][0]-Scalebounds[2][1])+Scalebounds[2][1]

    OBJ.append(
        my_world.scene.add(
        DynamicCuboid(
            prim_path="/World/"+objname,
            name=objname,
            position=np.array([x, y, z]),
            scale=np.array([xscale, yscale, zscale]),
            size=1.0,
            color=objcolor,
            linear_velocity=np.array([0, 0, 1]),
        )
    )
    )
#=================Initiate Obstacles Movement=====================
#<<<<<<<<<<<<<<<WRITE YOUR CODE HERE>>>>>>>>>>>>>>>>>>

################ADED by us
import omni.isaac.core.utils.stage
import omni.physx.scripts.physicsUtils
def move(obj):
    stage= omni.isaac.core.utils.stage.get_current_stage()
    omni.physx.scripts.physicsUtils.add_force_torque(stage,f"/World/{obj}",(3,3,1))
# stage= omni.isaac.core.utils.stage.get_current_stage()
# omni.physx.scripts.physicsUtils.add_force_torque(stage,"/World/TARGET",(3,3,1))
# stage1= omni.isaac.core.utils.stage.get_current_stage()
# omni.physx.scripts.physicsUtils.add_force_torque(stage1,"/World/Obstacle5",(3,3,1))
# omni.physx.scripts.physicsUtils.add_force_torque(stage,"/World/Obstacl4",(3,3,1))
# omni.physx.scripts.physicsUtils.add_force_torque(stage,"/World/Obstacle1",(3,3,1))
# omni.physx.scripts.physicsUtils.add_force_torque(stage,"/World/Obstacle3",(3,3,1))
# omni.physx.scripts.physicsUtils.add_force_torque(stage,"/World/Obstacle6",(3,3,1))
# ######################################
#=========Draw Line=============
start_point = [(0,0,0)]  # Adjust these values for your desired start position
end_point = [(0,0,3)]  # Adjust these values for your desired end p
line_color = [(1.0, 0.0, 0.0, 1.0)]  # Red color (RGBA format)
line_width = [2.0]  # Line thickness
draw.draw_lines(start_point, end_point, line_color, line_width)
#=====================START SIMULATION=====================
disp_time=.1
curtime=0
my_world.reset()
while simulation_app.is_running():
    my_world.step(render=True)
    if my_world.is_playing():
        if my_world.current_time_step_index == 0:
            my_world.reset()
            JB_controller.reset()
        # print('step'+str(my_world.current_time_step_index)+' time=' + str(my_world.current_time) + '\n')
        #=====================================RUNTIME======================================================
        #---------Move Obstacles------------
        # move("TARGET")
        for i in range(Nobj):
            OBJ[i].set_world_pose(position=np.array([np.random.randint(0,10),np.random.randint(0,10),0.]), orientation=np.array([np.random.randint(0,2),np.random.randint(0,3),0.,0.]))


        #<<<<<<<<<<<<<<<WRITE YOUR CODE HERE>>>>>>>>>>>>>>>>>>
        #-------------GET JB Camera----------------
        CAMFRAME=JBcam.get_current_frame()
        CAMRGB=JBcam.get_rgba()
        #-----------PROCESS JB RGB Image-----------
        if my_world.current_time>curtime:
            curtime=my_world.current_time+disp_time
        # #=========Draw Line=============
        # start_point = [(0,0,0)]  # Adjust these values for your desired start position
        # end_point = [(0,0,3)]  # Adjust these values for your desired end p
        # line_color = [(1.0, 0.0, 0.0, 1.0)]  # Red color (RGBA format)
        # line_width = [2.0]  # Line thickness
        # draw.draw_lines(start_point, end_point, line_color, line_width)
        #----------------MOVE JETBOT---------------
        position, orientation = JB.get_world_pose()
        # JB.apply_wheel_actions(JB_controller.forward(command=[1, np.pi]))
        # print(JB.get_angular_velocity())
        #=====================================END of RUNTIME======================================================
        if my_world.current_time_step_index == 0:
            my_world.reset()
            # my_controller.reset()
        observations = my_world.get_observations()
simulation_app.close()
