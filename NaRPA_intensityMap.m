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

%%

% 
% y_pc = reshape(I2', length(y),1);
% colors = repmat(y_pc,1,3); 
% % ptCloud.Color = colors; 
% % ptCloud.Intensity = y_pc;
myIntnsty_ = (mean(pc_select.Intensity)+5)*ones(length(xyzPoints),1);
% myIntnsty_(1:min(length(pc_select.Intensity), length(myPoints))) = ...
%     pc_select.Intensity(1:min(length(pc_select.Intensity), length(myPoints)));
% ptCloud.Intensity = myIntnsty_;

for ii=1:length(xyzPoints)
    if xyzPoints(ii,2) < 4
        myIntnsty_(ii) = min(pc_select.Intensity)+8;
    end
end


ptCloud.Intensity = myIntnsty_;

figure
pcshow(ptCloud, 'MarkerSize',20)
xlabel('X'); ylabel('Y'); zlabel('Z')
title('Intensity map')
c = colorbar;
% colormap('gray');
caxis([min(pc_select.Intensity) max(pc_select.Intensity)])
c.Color = [1 1 1];

%% DOWNSAMPLING
% ptCloudOut = pcdownsample(ptCloud,'gridAverage',0.01);
% figure
% pcshow(ptCloudOut,'MarkerSize',20);
% %% ICP
% tform = pcregistericp(pc_select,ptCloud); % moving, fixed
% 
% % Transform
% ptCloudOut_tform = pctransform(ptCloud,tform);
% figure
% pcshow(ptCloudOut_tform)
% xlabel('X'); ylabel('Y'); zlabel('Z')