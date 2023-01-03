% VELOCIMETRY ANALYSIS
% RR Bhaskara
% Texas A&M University

clc; clear; close all; 

% data path
Aeva_dataset = 'C:\Users\brc06\Research\imageProcessing\Lidar_HIL\data';
addpath(genpath(Aeva_dataset));
%% READ Aeva point_cloud data
filename = 'traj1_test3_int'; % trajectory raw data
pc_data = AevaPcRead(filename);

%% ICP

% figure
pc_temp = pointCloud(double(pc_data(1).xyz'));
roi = [1 7 -2 4 -2 2];
i_roi = findPointsInROI(pc_temp,roi);
pc_fixed = select(pc_temp,i_roi);
% pcshow(pc_select)

pc_temp = pointCloud(double(pc_data(100).xyz'));
roi = [1 7 -2 4 -2 2];
i_roi = findPointsInROI(pc_temp,roi);
pc_moving = select(pc_temp,i_roi);

tform = pcregrigid(pc_moving, pc_fixed)