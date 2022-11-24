% VELOCIMETRY ANALYSIS
% RR Bhaskara
% Texas A&M University

clc; clear; close all; 

Aeva_dataset = 'H:\Research\Image_processing\velocimeter_HIL\pointclouds_raw';
addpath(genpath(Aeva_dataset));
%% READ Aeva point_cloud data
filename = 'traj1_test3_int'; % trajectory raw data
pc_data = AevaPcRead(filename);
%% PROCESS Aeva data
