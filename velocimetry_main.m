% VELOCIMETRY ANALYSIS % 
% RR Bhaskara %
% Texas A& M University

clc;
clear;
close all;

% cd '/home/ram/PhD/imageProcessing/velocimetry_HIL/software_ram/Lidar-velocimeter'
cd('H:\Research\Image_processing\velocimeter_HIL\Lidar-velocimeter');
addpath(genpath('.\reconstruction\'));
%%
% data path % 
% Aeva_dataset = 'C:\Users\brc06\Research\imageProcessing\Lidar_HIL\data';
Aeva_dataset = 'H:\Research\Image_processing\velocimeter_HIL\pointclouds_raw\Davis_datasets\';
addpath(genpath(Aeva_dataset));

% % READ Aeva point_cloud data % 
% filename = 'traj4_test3_ref';
% % trajectory raw data % 
% pc_data = AevaPcRead(filename);
% % %
% 
 pc_data_rocket = AevaPcRead('rocket_spin_pt5_2');


% datapath ='carla-town04-straight-walls/point_clouds/';
 %% MAKE IMAGE VIDEO and SAVE IMAGES
 makeAevaImageVideo(pc_data, strcat(Aeva_dataset, '/', 'traj4_test1_int/images/'), 't4t1_'); 

%%
pc_data = load('trn_ekf_HOMER_pc_data_raw.mat');
pc_data = pc_data.pc_data; 
 %%
%  saveAs = "homer_trn";
 trn_truth = load("trn_ekf_HOMER_truth.mat");
%  AevaPcRecord_AstWall(pc_data, Aeva_dataset, saveAs); 
%%
%% Rocket data image cropping
rect = [ 640   340   640   225];

for ii = 1:178
    im = imcrop(  imread( sprintf("spinningRocket/%d.png", ii) ), ...
        rect  );
    imwrite( im, sprintf("%d.png", ii) );
    clf;
end

%%

    % % % % % PROCESS Aeva data % vicon_data = 'H:\Research\Image_processing\velocimeter_HIL\lidarspecsandtrajectories';
% addpath(genpath(vicon_data));
% % data_matrix = readmatrix('traj1_test3_vicon.csv');
% N_pts = 142;
% lidar_times = linspace(0, 14.10, N_pts);
% % % Converting units to meters % % data_matrix( :, 4 : 6) = data_matrix( :, 4 : 6) * 1e-3;
% x = data_matrix( :, 6);
% y = data_matrix( :, 7);
% z = data_matrix( :, 8);
% % vx = data_matrix( :, 9);
% vy = data_matrix( :, 10);
% vz = data_matrix( :, 11);
% lin_vel = [ vx, vy, vz ];
% % % % AevaVelocimetryRecord(pc_data, lin_vel);
