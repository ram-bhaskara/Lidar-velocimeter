% INTENSITY ANALYSIS
% RR Bhaskara
% Texas A&M University

clc; clear; close all; 

Aeva_dataset = 'H:\Research\Image_processing\velocimeter_HIL\pointclouds_raw';
addpath(genpath(Aeva_dataset));
%% READ Aeva point_cloud data
filename = 'traj1_test3_int'; % trajectory raw data
pc_data = AevaPcRead(filename);

%% Aeva PC intensity data
INPUT_FRAME = 55; 

pc_temp = pointCloud(double(pc_data(INPUT_FRAME).xyz'));
roi = [1 7 -2 4 -2 2];
i_roi = findPointsInROI(pc_temp,roi);
pc_select = select(pc_temp,i_roi);
myX = pc_select.Location(:,1); myY = pc_select.Location(:,2);
myZ = pc_select.Location(:,3); 

pc_data_intensity = pc_data(INPUT_FRAME).intensity;
pc_select.Intensity = pc_data_intensity(i_roi); 
   
figure
    pcshow(pc_select)
    c=colorbar;
    c.Color = [1.0 1.0 1.0]; 
    % colormap('gray');
    title('Aeva intensity return (frame #55)');
%     xlim([roi(1) roi(2)])
%     ylim([roi(3) roi(4)])
%     zlim([roi(5) roi(6)])
    exportgraphics(gcf,'aeva_intensity_t1t3.jpg',...
    'BackgroundColor','k')
%% PROCESS Aeva data
vicon_data = 'H:\Research\Image_processing\velocimeter_HIL\lidarspecsandtrajectories';
addpath(genpath(vicon_data));

data_matrix = readmatrix('traj1_test3_vicon.csv');
N_pts = 142;
lidar_times = linspace(0,14.10,N_pts);


%% Associated NaRPA data
% Artificial albedo

% [xp, yp, zp] = readPointCloud('wall_t1t3_55_3D.txt');
narpa_xyzPoints = [xp, yp, zp];
ptCloud = pointCloud(narpa_xyzPoints);

myIntnsty_ = (mean(pc_select.Intensity)+5.5)*ones(length(narpa_xyzPoints),1);

for ii=1:length(narpa_xyzPoints)
    if narpa_xyzPoints(ii,2) < 4
        myIntnsty_(ii) = min(pc_select.Intensity)+7;
    end
end
[y_sorted, IDy] = sort(yp); 
myIntnsty_(IDy(1:20)) = max(pc_select.Intensity)-7;

ptCloud.Intensity = myIntnsty_;

figure
    pcshow(ptCloud, 'MarkerSize',10)
%     xlabel('X'); ylabel('Y'); zlabel('Z')
    title('NaRPA intensity map')
    c = colorbar;
%     colormap('gray');
    caxis([min(pc_select.Intensity) max(pc_select.Intensity)])
    c.Color = [1 1 1];
    exportgraphics(gcf,'narpa_intensity_t1t3.jpg',...
    'BackgroundColor','k')

