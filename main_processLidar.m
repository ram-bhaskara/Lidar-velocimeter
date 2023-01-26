% q = [-0.0060102	-0.011766	-0.69559	-0.71831];
q = [-0.0027431	-0.012164	-0.81445	-0.5801];
% t = [-0.12444	1.9679	0.50008];
t = [0.16879	0.23557	0.50167];
% t = [-0.12068	2.0776	0.49917];
pre = [0 1 0; 1 0 0; 0 0 1];
% transformation between body frame and the lidar frame
% lookAt, lookFrom, up

% LookFrom - origin(body_frame) = t
% 
R = q2R(q);
% tform = rigid3d(R,t)

lookFrom = t' 
lookAt = R' * [0 4.2 0]' % z = y for this terrain
% % up = R(:,2)
up = [0 0 1]
% lookFrom = [1 -1 0]'; lookAt = [0 1 0]'; 

%%
% ax = plotTransforms(t,q)

data_matrix = readmatrix('traj1_test3_vicon.csv');
N_pts = 142;
lidar_times = linspace(0,14.10,N_pts);

% Converting units to meters
% data_matrix(:,4:6) = data_matrix(:,4:6) * 1e-3;
x=data_matrix(:,6); 
y=data_matrix(:,7);
z=data_matrix(:,8);

readPointCloud('wall_t1t3_55_3D.txt');


% hold on
% plot3(x,y,z,'r')

%%
[x_body, y_body, z_body] = readPointCloud('wall_baseline.txt');
comass = [mean(x_body(~isnan(x_body))), mean(y_body(~isnan(y_body))), ...
    mean(z_body(~isnan(z_body)))]
%%
% readPointCloud('wall_t1t3_01.txt');
Q = cameraDCM(lookFrom, lookAt, up)
%%

pointCloudinSensorFrame('wall_t1t3_00_3D.txt', lookFrom, lookAt, up);

%% TRAJECTORY / SENSOR DATA
addpath('H:\Research\Image_processing\velocimeter_HIL\pointclouds_raw\Davis_datasets');
filename = 'rocket_spin_pt5_2'; % trajectory raw data
pc_data = AevaPcRead(filename);
%%
AevaPcRecord(pc_data);
