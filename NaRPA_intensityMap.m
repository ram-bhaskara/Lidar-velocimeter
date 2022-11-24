[x,y,z] = readPointCloud('wall_materials.txt');
x_new = reshape(x', 500,500); 
y_new = reshape(y', 500,500); 
z_new = reshape(z', 500,500); 

% figure
% I = mat2gray(y_new');
% imshow(I)
Img = imread('mitsuba_mat_500px.png');
I2 = rgb2gray(Img);
figure
imshow(I2)

%% Creating pointcloud object
xyzPoints = [x, y, z]; 
ptCloud = pointCloud(xyzPoints);

y_pc = reshape(I2', length(y),1);
colors = repmat(y_pc,1,3); 
% ptCloud.Color = colors; 
ptCloud.Intensity = y_pc; 

figure
pcshow(ptCloud)
title('Intensity map')