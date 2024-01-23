clc; close; clear; 

% 1. Plotting the trajectory of cameras in the scene
% 2. Setting up the trajectory for NaRPA data handling

% Working Directory
cd('/home/ram/PhD/imageProcessing/velocimetry_HIL/software_ram/Lidar-velocimeter/reconstruction'); 

% Path of colmap output products (cameras.txt, images.txt, points3D.txt files)
dataPath = '/home/ram/PhD/imageProcessing/velocimetry_HIL/data/spinningRocket/colmap2/sparse/0/'; 

[cameras, images, points3D] = read_model(dataPath); 
%%
[xyz, xyzColors, camera_centers, view_dirs] = plot_model(cameras, images, points3D); 
ptFused = pointCloud(xyz); 
% ptFused.Color = xyzColors;
% pcshow(ptFused); axis on; xlabel('X'); ylabel('Y'); zlabel('Z');
% view([180 90])

%%

figure 
% Point Cloud
pcFileName = 'fused.ply'; 
% 'spinningRocket.ply';
ptCloud = pcread([dataPath pcFileName]);  
% Edited pointcloud from MeshLab
% Does not correspond with the points3d.txt

pcshow(ptCloud); 
axis on;  
hold on;
extrinsics = images.values;

for ii = 1:5:numel(extrinsics)
    rotm = extrinsics{ii}.R;
    trnsl = extrinsics{ii}.t;
    % rotm takes from world to camera; rotm' -> camera to world
    % https://colmap.github.io/format.html#images-txt
h = plotTransforms(transpose(-rotm'*trnsl), rotm2quat(rotm'), "FrameAxisLabels","on", "FrameSize",0.3);
pause(0.1);
end
xlabel('X'); ylabel('Y'); zlabel('Z');
hold off

view([180 90])

%% Verification
translations = zeros(numel(extrinsics),3); 

for ii = 1:length(translations)
    rotm = extrinsics{ii}.R;
    trnsl = extrinsics{ii}.t;
    translations(ii,:) = transpose(-rotm'*trnsl);
end

disp(translations - camera_centers); % -> correct

%% NARPA Meta Data Preparation

lookFroms = camera_centers;
lookAts = zeros(length(lookFroms), 3);
ups = lookAts;

for i = 1:length(lookFroms)
    rotm = extrinsics{ii}.R;
    trnsl = extrinsics{ii}.t;
    lookAts(i,:) = camera_centers(i,:)' + rotm' * [0; 0; 0.3]; % vector along camera +z-axis
    ups(i,:) = rotm' * [0; 1; 0]; % verify cross products
    % https://stackoverflow.com/questions/3427379/effective-way-to-calculate-the-up-vector-for-glulookat-which-points-up-the-y-axi
    
end