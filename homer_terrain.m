% VELOCIMETRY ANALYSIS
% RR Bhaskara
% Texas A&M University

clc; clear; close all; 
Aeva_dataset = 'C:\Users\brc06\Research\imageProcessing\Lidar_HIL\data\terrain';
addpath(genpath(Aeva_dataset));

%% READ Aeva point_cloud data
load("trn_ekf_HOMER_pc_data_raw.mat"); 
load("trn_ekf_HOMER_truth.mat");
% load("trn_ekf_HOMER_pc_data_segmented.mat");
%%

figure
pc_temp = pointCloud(double(pc_data(1).xyz'));
roi = [-10 15 -10 10 -1 5];
i_roi = findPointsInROI(pc_temp,roi);
pc_fixed = select(pc_temp,i_roi);
pcshow(pc_fixed)

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

%% TESTING

for ii = 1:length(xtrue)
 x_c(ii) = (xtrue(ii, 6));
  y_c(ii) = (xtrue(ii, 7));
   z_c(ii) = (xtrue(ii, 8));

end
figure 
plot3(x_c, y_c, z_c)
xlabel('x'); ylabel('y'); zlabel('z')
%% 
function p = IMU2LIDAR(p_b)
    p_B2L = [0.0094 0.0625 0.1213]';
    C_B2L =   [-0.0277    0.9903    0.1363
   -0.9993   -0.0311    0.0229
    0.0269   -0.1356    0.9904];
    
    p = C_B2L * p_b + p_B2L;

end