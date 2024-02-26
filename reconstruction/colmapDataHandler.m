% clc; close; clear; 

% 1. Plotting the trajectory of cameras in the scene
% 2. Setting up the trajectory for NaRPA data handling

% Working Directory
% cd('/home/ram/PhD/imageProcessing/velocimetry_HIL/software_ram/Lidar-velocimeter/reconstruction'); 

% Path of colmap output products (cameras.txt, images.txt, points3D.txt files)
% dataPath = '/home/ram/PhD/imageProcessing/velocimetry_HIL/data/spinningRocket/colmap2/sparse/0/'; 
% dataPath = [pwd '\reconstruction\']; 
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
% pcFileName = 'fused.ply'; 
pcFileName = '\spinningRocket.ply';
ptCloud = pcread([dataPath pcFileName]);  
% Edited pointcloud from MeshLab
% Does not correspond with the points3d.txt

pcshow(ptCloud); 
axis on;  
hold on;

extrinsics = images.values;
h = plotTransforms(([0 0 0]), rotm2quat(eye(3)), "FrameSize", 1.25);

for ii = 1:7:70
    rotm = extrinsics{ii}.R;
    trnsl = extrinsics{ii}.t;
    % rotm takes from world to camera; rotm' -> camera to world
    % https://colmap.github.io/format.html#images-txt
h = plotTransforms(transpose(-rotm'*trnsl), rotm2quat(rotm'), "FrameSize",0.6);
pause(0.1);
end
xlabel('X'); ylabel('Y'); zlabel('Z'); axis off; 
hold off

view([180 90])
ax = gca;
ax.LineWidth = 16;

% set(gcf, 'InvertHardCopy', 'off'); 
% set(gcf,'Color',[0 0 0]); % RGB values [0 0 0] indicates black color
%% Verification
translations = zeros(numel(extrinsics),3); 

for ii = 1:length(translations)
    rotm = extrinsics{ii}.R;
    trnsl = extrinsics{ii}.t;
    translations(ii,:) = transpose(-rotm'*trnsl);
end

disp(translations - camera_centers); % -> correct

%% NARPA Meta Data Preparation

lookFroms = camera_centers; % translations
lookAts = zeros(length(lookFroms), 3);
ups = lookAts;

for i = 1:length(lookFroms)
    rotm = extrinsics{ii}.R;
    trnsl = extrinsics{ii}.t;
    lookAts(i,:) = camera_centers(i,:)' + rotm' * [0; 0; 0.3]; % vector along camera +z-axis
    ups(i,:) = rotm' * [0; 1; 0]; % verify cross products
    % https://stackoverflow.com/questions/3427379/effective-way-to-calculate-the-up-vector-for-glulookat-which-points-up-the-y-axi
end

%% Verification of camera matrix
DCM_camera = cameraDCM( lookFroms(1,:), lookAts(1,:), ups(1,:) )
%% Data Association Problem
% Associate Colmap indexed images with the cropped image data
keys = images.keys;
for ii = 1:images.Count
   fprintf('CamID: %d \t ImgID: %d \t Img: %s\n', images(keys{ii}).camera_id, images(keys{ii}).image_id, images(keys{ii}).name);
end
%% SORT the images and save point clouds at each camera instance
% Correct ID
% Animate the point cloud and compare
% Operating on 101 images
timeDiff = 0.1; % Time between consecutive frames
timeInstances = 0.0:timeDiff:100*timeDiff;
velocitiesApprox = zeros(101,3);
for ii = 1:100
    velocitiesApprox(ii+1,:) = (lookFroms(ii+1,:)-lookFroms(ii,:))./timeDiff;
end

plot(timeInstances(2:end), velocitiesApprox(2:end,1), 'r', timeInstances(2:end), velocitiesApprox(2:end,2),'b', timeInstances(2:end), velocitiesApprox(2:end,3), 'k', ...
    'LineWidth', 2.5);
legend('$v_x$', '$v_y$', '$v_z$', 'Interpreter', 'latex', 'FontSize', 16);
xlabel('t', 'Interpreter', 'latex'); ylabel('$\mathbf{v}$', 'Interpreter', 'latex'); title('Linear velocities (m/s)', 'Interpreter', 'latex');
ax = gca; 
ax.FontSize = 14;
ax.LineWidth = 2.5;
xlim([timeInstances(2) timeInstances(end)]); axis equal;
%% Coarse angular velocity estimation
angularVelocities = zeros(101, 3);

for ii = 1:100
    rotm_i = extrinsics{ii}.R;
    rotm_i1 = extrinsics{ii+1}.R;
    quat_i = rotm2quat(rotm_i');
    quat_i1 = rotm2quat(rotm_i1');
    
    deltaQuaternion = quatmultiply( quat_i1,  quatconj(quat_i) );
    
    % Convert quaternion to axis-angle representation
    axang = quat2axang(deltaQuaternion);
    principleAxis = axang(1:3); principleAngle = axang(4);
     % Estimate angular velocity vector
    angularVelocities(ii+1, :) = (principleAxis * principleAngle) / timeDiff;
end
plot(timeInstances(2:end), angularVelocities(2:end,1), 'r',timeInstances(2:end), angularVelocities(2:end,2),'b', timeInstances(2:end), angularVelocities(2:end,3),'k', ...
    'LineWidth', 2.5);
legend('$\omega_x$', '$\omega_y$', '$\omega_z$', 'Interpreter', 'latex', 'FontSize', 16);
xlabel('t', 'Interpreter', 'latex'); ylabel('\boldmath{$\omega$}', 'Interpreter', 'latex'); title('Angular velocities (rad/s)', 'Interpreter', 'latex');
ax = gca; 
ax.FontSize = 14;
ax.LineWidth = 2.5;
xlim([timeInstances(2) timeInstances(end)]); axis tight;
%% File Write
VelFileID = fopen('Velocity.txt','w');
TrajFileID = fopen('Trajectory.txt', 'w'); 
LookAtFileID = fopen('LookAt.txt', 'w'); 
UpFileID = fopen('updata.txt', 'w'); 

for ii = 1:101
 fprintf(VelFileID,'%f \t %f \t %f\n', velocitiesApprox(ii,1), velocitiesApprox(ii,2), velocitiesApprox(ii,3));
 fprintf(TrajFileID,'%f \t %f \t %f\n', lookFroms(ii,1), lookFroms(ii,2), lookFroms(ii,3));
 fprintf(LookAtFileID,'%f \t %f \t %f\n', 0, 0, 0);
 fprintf(UpFileID,'%f \t %f \t %f\n', 0, 1, 0);
end 

fclose(VelFileID);
fclose(TrajFileID); fclose(LookAtFileID); fclose(UpFileID);