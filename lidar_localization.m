% VELOCIMETRY ANALYSIS
% RR Bhaskara
% Texas A&M University

clc; clear; close all; 

% data path
Aeva_dataset = 'C:\Users\brc06\Research\imageProcessing\Lidar_HIL\data';
% Aeva_dataset = 'C:\Users\brc06\Research\imageProcessing\Lidar_HIL\data\terrain';
addpath(genpath(Aeva_dataset));

%% READ Aeva point_cloud data
filename = 'traj1_test3_int'; % trajectory raw data
pc_data = AevaPcRead(filename);

%% Read VICON meta data from excel

data_matrix = readmatrix('traj1_test3_vicon.csv');
N_pts = 142;
lidar_times = linspace(0,14.10,N_pts);

timestamps = data_matrix(:,1); % 10 Hz vicon data - excel 

% Converting units to meters
% data_matrix(:,4:6) = data_matrix(:,4:6) * 1e-3;

quat_data = data_matrix(:,2:5); 
T_V2L = data_matrix(:,6:8);

vx=data_matrix(:,9); 
vy=data_matrix(:,10);
vz=data_matrix(:,11);
lin_vel = [vx, vy, vz]; 


%%
stlData = stlread('AsteroidWall_Int.stl');
points = stlData.Points;
ptCloud = pointCloud(points); 

%% YAW check 

% C_B2L =   [-0.0277    0.9903    0.1363
%    -0.9993   -0.0311    0.0229
%     0.0269   -0.1356    0.9904];

figure
pcshow(ptCloud, 'BackgroundColor',[1 1 1])
hold on


for ii = 1:25:length(quat_data)
% transformation = se3(quat_as_DCM(quat_data(ii,:)), T_V2L(ii,:)); 
% h = plot(transformation); 
plot3(T_V2L(ii,1), T_V2L(ii,2), T_V2L(ii,3), '.k', "MarkerSize", 20);
h = plotTransforms(T_V2L(ii,:), [quat_data(ii,4) quat_data(ii,1) quat_data(ii,2) quat_data(ii,3)], "FrameAxisLabels","on", "FrameSize",0.75);

% h = plotTransforms(transformation, "FrameAxisLabels","off", "FrameSize",0.75);
pause(0.01);
axis on; xlabel('X'); ylabel('Y'); zlabel('Z')
% xlim([-5 5])
% ylim([-5 5])
% zlim([-5 5])
hold all
% set(h,'Visible','off')
% delete(h);
end

plot3(T_V2L(:,1), T_V2L(:,2), T_V2L(:,3), 'k', "LineWidth", 2);
% 
% hold off


%% NARPA renders

pc_sensor = pointCloudinSensorFrame("wall_t1t3_00_3D.txt", zeros(3,1), zeros(3,1), zeros(3,1));


%% To sensor frame
% composite vicon to lidar transformation
INPUT_FRAME = 100;

[c, v_frame_id] = min(abs(timestamps - lidar_times(INPUT_FRAME)));

TF_V2L = [quat_as_DCM(quat_data(v_frame_id,:)) transpose(T_V2L(v_frame_id,:)); zeros(1,3) 1];

points_ICP = zeros(size(points)); 

for ii = 1:length(points)
%     temp_V2L = tform.A * [transpose(points(ii,:)); 1];
    
    temp_V2L = TF_V2L(1:3,1:3) * (transpose(points(ii,:)) - transpose(T_V2L(v_frame_id,:)));
% temp_V2L = tform.R * (transpose(points(ii,:)) - transpose(T_V2L(v_frame_id,:)));   
points_ICP(ii,:) = transpose(temp_V2L(1:3));
end
ptCloud_V2L = pointCloud(points_ICP); 
%%

% crop the pointcloud
pc_temp = pointCloud(double(pc_data(INPUT_FRAME).xyz'));
roi = [1 7 -2 4 -2 2];
i_roi = findPointsInROI(pc_temp,roi);
pc_fixed = select(pc_temp,i_roi);
% pcshow(pc_fixed)

figure 
subplot(1,3,1)
pcshow(ptCloud); 
axis on
xlabel('X'); ylabel('Y'); zlabel('Z')
hold on
ax = plotTransforms([0 0 0], [1 0 0 0], "FrameAxisLabels","on",...
    "MeshFilePath","groundvehicle.stl","MeshColor",[0.9 0.5 0.5]);
hold off
title("vicon frame")

subplot(1,3,2)
pcshow(pc_fixed)
axis on
xlabel('X'); ylabel('Y'); zlabel('Z');
hold on
% ax = plotTransforms([0 0 0], [1 0 0 0], "FrameAxisLabels","on");
hold off
title("sensor frame")

subplot(1,3,3)
pcshow(ptCloud_V2L); 
axis on; xlabel('X'); ylabel('Y'); zlabel('Z');
title("Lidar frame")
%% ICP

% figure
% pc_temp = pointCloud(double(pc_data(1).xyz'));
% roi = [1 7 -2 4 -2 2];
% i_roi = findPointsInROI(pc_temp,roi);
% pc_fixed = select(pc_temp,i_roi);
% pcshow(pc_select)
% 
% pc_temp = pointCloud(double(pc_data(100).xyz'));
% roi = [1 7 -2 4 -2 2];
% i_roi = findPointsInROI(pc_temp,roi);
% pc_moving = select(pc_temp,i_roi);

[tform, movingReg] = pcregistericp(pc_fixed, ptCloud_V2L); 
figure
subplot(1,2,1)
pcshowpair(pc_fixed,ptCloud_V2L)
axis on; xlabel('X'); ylabel('Y'); zlabel('Z');
title("ICP static vs moving")

subplot(1,2,2)
pcshowpair(movingReg,ptCloud_V2L)
axis on; xlabel('X'); ylabel('Y'); zlabel('Z');
title("Registered vs static")

%% figure

points_ICP = zeros(size(points)); 

for ii = 1:length(points)
    temp_V2L = tform.A * [transpose(ptCloud.Location(ii,:)); 1];
    points_ICP(ii,:) = transpose(temp_V2L(1:3));
end
ptCloud_ICP = pointCloud(points_ICP); 


figure 
subplot(1,3,1)
pcshow(ptCloud); 
axis on
xlabel('X'); ylabel('Y'); zlabel('Z')
hold on
ax = plotTransforms([0 0 0], [1 0 0 0], "FrameAxisLabels","on",...
    "MeshFilePath","groundvehicle.stl","MeshColor",[0.9 0.5 0.5]);
hold off
title("vicon frame")

subplot(1,3,2)

pc_temp = pointCloud(double(pc_data(INPUT_FRAME).xyz'));
roi = [1 7 -2 4 -2 2];
i_roi = findPointsInROI(pc_temp,roi);
pc_fixed = select(pc_temp,i_roi);
pcshow(pc_fixed)

axis on
xlabel('X'); ylabel('Y'); zlabel('Z');
hold on
% ax = plotTransforms([0 0 0], [1 0 0 0], "FrameAxisLabels","on");
hold off
title("sensor frame")

subplot(1,3,3)
pcshow(ptCloud_ICP); 
axis on; xlabel('X'); ylabel('Y'); zlabel('Z');
title("ICP Transformed frame")


%%
function p = IMU2LIDAR(p_b)
    p_B2L = [0.0094 0.0625 0.1213]';
    C_B2L =   [-0.0277    0.9903    0.1363
   -0.9993   -0.0311    0.0229
    0.0269   -0.1356    0.9904];
    
    p = C_B2L * p_b + p_B2L;

end
