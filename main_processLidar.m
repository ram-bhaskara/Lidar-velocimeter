q = [-0.0060102	-0.011766	-0.69559	-0.71831];
t = [-0.12444	1.9679	0.50008];
% t = [-0.12068	2.0776	0.49917];
pre = [0 1 0; -1 0 0; 0 0 1];
% transformation between body frame and the lidar frame
% lookAt, lookFrom, up

% LookFrom - origin(body_frame) = t
% 
R = q2R(q);
lookFrom = t' 
lookAt = R' * [0 4.2 0]' % z = y for this terrain
% % up = R(:,2)
up = [0 0 1]
% lookFrom = [1 -1 0]'; lookAt = [0 1 0]'; 

%%
% ax = plotTransforms(t,q)
figure
data_matrix = readmatrix('traj1_test3_vicon.csv');
N_pts = 142;
lidar_times = linspace(0,14.10,N_pts);

% Converting units to meters
% data_matrix(:,4:6) = data_matrix(:,4:6) * 1e-3;
x=data_matrix(:,6); 
y=data_matrix(:,7);
z=data_matrix(:,8);


readPointCloud('wall_t1t3_01.txt');
hold on
plot3(x,y,z,'r')

%%
[x_body, y_body, z_body] = readPointCloud('wall_baseline.txt');
comass = [mean(x_body(~isnan(x_body))), mean(y_body(~isnan(y_body))), ...
    mean(z_body(~isnan(z_body)))]
%%
% readPointCloud('wall_t1t3_01.txt');
Q = cameraDCM(lookFrom, lookAt, up)
%%

pointCloudinSensorFrame('wall_t1t3_01.txt', lookFrom, lookAt, up);

%% TRAJECTORY / SENSOR DATA
filename = 'traj4_test1_ref'; % trajectory raw data
pc_data = AevaPcRead(filename);
%%
makeLiDARVideo(pc_data);
