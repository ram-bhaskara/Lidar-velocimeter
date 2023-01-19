% VELOCIMETRY ANALYSIS
% RR Bhaskara
% Texas A&M University

clc; clear; close all; 

% data path
% Aeva_dataset = 'C:\Users\brc06\Research\imageProcessing\Lidar_HIL\data';
Aeva_dataset = 'C:\Users\brc06\Research\imageProcessing\Lidar_HIL\data\terrain';
addpath(genpath(Aeva_dataset));

%% READ Aeva point_cloud data
% filename = 'traj1_test3_int'; % trajectory raw data
% pc_data = AevaPcRead(filename);
load("trn_ekf_HOMER_pc_data_raw.mat"); 
load("trn_ekf_HOMER_truth.mat");
load("trn_ekf_HOMER_pc_data_segmented.mat");
%%
% stlData = stlread('AsteroidWall_Int.stl');
% points = stlData.Points;
% ptCloud = pointCloud(points); 
% 
% figure 
% subplot(1,2,1)
% pcshow(ptCloud); 
% axis on
% xlabel('X'); ylabel('Y'); zlabel('Z')
% hold on
% ax = plotTransforms([0 0 0], [1 0 0 0], "FrameAxisLabels","on",...
%     "MeshFilePath","groundvehicle.stl","MeshColor",[0.9 0.5 0.5]);
% hold off
% title("vicon frame")
% 
% subplot(1,2,2)

pc_temp = pointCloud(double(pc_data(1).xyz));
roi = [-10 20 -20 20 -5 5];
i_roi = findPointsInROI(pc_temp,roi);
pc_fixed = select(pc_temp,i_roi);
pcshow(pc_temp)

axis on
xlabel('X'); ylabel('Y'); zlabel('Z');
hold on
% ax = plotTransforms([0 0 0], [1 0 0 0], "FrameAxisLabels","on");
hold off
title("sensor frame")

%% ICP

% figure
pc_temp = pointCloud(double(pc_data(1).xyz'));
roi = [1 7 -2 4 -2 2];
i_roi = findPointsInROI(pc_temp,roi);
pc_fixed = select(pc_temp,i_roi);
pcshow(pc_select)

pc_temp = pointCloud(double(pc_data(100).xyz'));
roi = [1 7 -2 4 -2 2];
i_roi = findPointsInROI(pc_temp,roi);
pc_moving = select(pc_temp,i_roi);

tform = pcregrigid(pc_moving, pc_fixed)