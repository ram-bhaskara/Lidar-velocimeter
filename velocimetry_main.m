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
%% PROCESS Aeva data
vicon_data = 'H:\Research\Image_processing\velocimeter_HIL\lidarspecsandtrajectories';
addpath(genpath(vicon_data));

data_matrix = readmatrix('traj1_test3_vicon.csv');
N_pts = 142;
lidar_times = linspace(0,14.10,N_pts);

% Converting units to meters
% data_matrix(:,4:6) = data_matrix(:,4:6) * 1e-3;
x=data_matrix(:,6); 
y=data_matrix(:,7);
z=data_matrix(:,8);

vx=data_matrix(:,9); 
vy=data_matrix(:,10);
vz=data_matrix(:,11);
lin_vel = [vx, vy, vz]; 
%%
AevaVelocimetryRecord(pc_data, lin_vel);
