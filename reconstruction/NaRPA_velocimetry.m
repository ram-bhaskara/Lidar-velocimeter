% Jan 27, 2024
% Ramchander Bhaskara 
% output data products from NARPA engine: of spinning satellite example

%% Read multiple text files of 3d terrain and depth data
% 'narpaData' is the directory containing the point cloud and
% depth data text files that corresponding to respective frames generated
% along the trajectory

clear all; close all; clc
% addpath(genpath('\narpaData'));
fileNames3D = dir(fullfile('narpaData','*3D.txt')); 
fileNames3D = {fileNames3D.name}';

fileNamesDepth = dir(fullfile('narpaData','*depth.txt'));
fileNamesDepth = {fileNamesDepth.name}';

%% store pointCloud across frames
for i=1:length(fileNames3D)
    file = fileNames3D{i};
    f = fopen(fullfile('narpaData', file));
    myObject(i).t = textscan(f,'%f %f %f');
    fclose(f);
end

% myObject(i).t(1) - x coordinates of frame i | 
%myObject(i).t(2) - y coordinates of frame i | myObject(i).t(3) - z coordinates of frame i

%% Trajectory
% Text files stored in a 'Trajectory' directory - correspond to the
% spacecraft trajectory info
file = "Trajectory";
f = fopen(strcat(file,".txt"));
Trajdata = textscan(f,'%f %f %f');
fclose(f);

x = Trajdata{1};
y = Trajdata{2};
z = Trajdata{3};

file = "Velocity";
f = fopen(strcat(file,".txt"));
Veldata = textscan(f,'%f %f %f');
fclose(f);

vx = Veldata{1};
vy = Veldata{2};
vh = Veldata{3};

camPos = [x,y,z]; %camPos(i) represents x,y,z of camera at a particular frame

aa = plot3(x,y,z,'k','linewidth',2); axis on; 
xlabel('X'); ylabel('Y'); zlabel('Z');

%% store range rates and frequency shifts from different frames

% depth.txt files contain three columns 
% ranges | range rates | doppler frequency_shifts
% Depth maps can be generated from range (rmag) information 

for i=1:length(fileNamesDepth)
    file = fileNamesDepth{i};
    f = fopen(fullfile('narpaData', file));
    depthData(i).DD = textscan(f,'%f %f %f');
    fclose(f);
end

% Note: delta_f(i) = depthData(i).DD{3} - frequency shift data for frame i in GHz
% range (multiply this by 1000 to obtain MHz range)

%% Extra omega

% Angular rates of the spacecraft in world-frame

% file = "Omega";
% f = fopen(strcat(file,".txt"));
% omegaData = textscan(f,'%f %f %f');
% fclose(f);
% 
% omega = [omegaData{1}, omegaData{2}, omegaData{3}];
% omega = [0,0,0]'; % constant angular motion

%% Code to compute range rates / frequency shifts 
% This is also done by the renderer and output in columns 2 and 3 of depth.txt files

% wavelength = 1290;
err = 1e6; % ignore large values which occur in point cloud / depth data due to no ray-surface intersection 
Rrate = zeros( length(z)-1, length(myObject(1).t{1}) );

for ii = 1:length(z)-1
    
    Omega = [0 0.5 0];
%     Omega = omega(ii,:);
    vel = [vx(ii);vy(ii);vh(ii)];
    
for jj=1:length(myObject(1).t{1})
        if(myObject(ii).t{1}(jj)>err)
            myObject(ii).t{1}(jj)= NaN; %x
            myObject(ii).t{2}(jj)= NaN; %y
            myObject(ii).t{3}(jj)= NaN; %z
            
        end
            
        DDx = myObject(ii).t{1}(jj)-camPos(ii,1);
        DDy = myObject(ii).t{2}(jj)-camPos(ii,2);
        DDz = myObject(ii).t{3}(jj)-camPos(ii,3);
%         
        rhat = [DDx,DDy,DDz];
        rhat = rhat/norm(rhat);
%         
        v=-vel+cross(Omega',[DDx;DDy;DDz]);
%         
%         % range rate for all the 3d points jj = 1:250,000 of frame ii
        Rrate(ii,jj) = dot(v,rhat); % range rate of a particular frame ii is a row vector 
        
        
end
    % Range rate from frequency shift data
%          del_f{ii} = 2*R(ii,:)/wavelength;
%         Rrate(:,ii)= depthData(ii).DD{3}*wavelength/2;
%             Rrate(:,ii)= depthData(ii).DD{2};
end

%% Test: Plot the NARPA point cloud data
narpaPlotter(myObject, Rrate, pwd, 1, 'spinningSatellite2');
%%
fig = figure;
% set(fig, 'Position', [100, 100, 800, 500]);


xlabel('X'); ylabel('Y'); zlabel('Z');
cmap = blueRedCmap;
min_velocity = -0.5;
max_velocity = 0.5;

colormap(cmap);

% for frameID = 1:2:30
frameID = 13;

xt = myObject(frameID).t{1};
yt = myObject(frameID).t{2};
zt = myObject(frameID).t{3};

nanIDs = isnan(xt);

xt = xt(~nanIDs);
yt = yt(~nanIDs);
zt = zt(~nanIDs);

velocity_channel = Rrate(frameID,:);
velocity_channel2 = velocity_channel(~nanIDs); % nanIDs correspond
velocity_channel2 = velocity_channel2'; 
 
% POINT CLOUD | NARPA
narpa_ptCloud = pointCloud([xt, yt, zt]); 
roi = [-0.25 2.25 -1 1 -4 4];
i_roi = findPointsInROI(narpa_ptCloud, roi);
pc_select = select(narpa_ptCloud,i_roi);

% pc_select.Intensity = uint8(velocity_channel2(i_roi)*255); % Assign
% intensity as color and check the colors quickly

% Step: Extract velocities in the ROI
velocity_channel = (velocity_channel2(i_roi));

colors = interpolateColors(velocity_channel, cmap, min_velocity, max_velocity);
pc_select.Color = uint8(255*colors); 

pcshow(pc_select)
% scatter3(pc_select.Location(i_roi, 1), pc_select.Location(i_roi, 2), pc_select.Location(i_roi, 3), ...
%         2, colors, 'filled');
xlim([roi(1) roi(2)]); ylim([roi(3) roi(4)]); zlim([roi(5) roi(6)]);
xlabel('X'); ylabel('Y'); zlabel('Z'); axis off; 
view([0 -90])
% view([-2.5*frameID 90])
title('$\textbf{Rendered Doppler Velocity Map}$', 'interpreter', 'Latex');

c = colorbar; c.Color = [1 1 1]; 
c.Label.String = 'Velocity (m/s)'; c.Label.FontSize = 14; 
% c.Label.Position = [0.82 0.11 0.04 0.82];
c.Label.Color = [1 1 1]; caxis([min_velocity max_velocity]);

ax = gca; 
ax.Color = 'w'; ax.XColor = 'w'; ax.YColor = 'w'; ax.ZColor = 'w'; 
ax.FontSize = 14; ax.FontWeight = 'bold'; 
set(gcf, 'InvertHardCopy', 'off'); 
set(gcf,'Color',[0 0 0]); % RGB values [0 0 0] indicates black color
% end

%% Aeva
pc_rocket_temp = pointCloud(double(pc_data_rocket(frameID).xyz'));
roi = [2 5.2 -2 2 -1 1]; 
i_roi = findPointsInROI(pc_rocket_temp, roi);
pc_select = select(pc_rocket_temp,i_roi);
% narpa_ptCloud.Intensity = uint8(velocity_channel);

vel = pc_data_rocket(frameID).velocity;
velocity_channel = vel(i_roi);

% velocity_channel = velocity_channel(velocity_channel>-0.5 & velocity_channel<0.5); 

colors = interpolateColors(velocity_channel, cmap, min_velocity, max_velocity);
pc_select.Color = uint8(255*colors); 


% pc_select.Intensity = uint8(velocity_channel*255); 
% Extract velocities
% vel = pc_select.velocity;
% velocity_channel = vel(i_roi);

figure
pcshow(pc_select)
xlim([roi(1) roi(2)]); ylim([roi(3) roi(4)]); zlim([roi(5) roi(6)]);
xlabel('X'); ylabel('Y'); zlabel('Z'); axis off; 
% view([0 -90])
% view([-2.5*frameID 90])
title('\textbf{Aeva Doppler Velocity Map}', 'Interpreter', 'latex');
colormap(cmap);

c = colorbar; c.Color = [1 1 1]; 
c.Label.String = 'Velocity (m/s)'; c.Label.FontSize = 14; 
% c.Label.Position = [0.82 0.11 0.04 0.82];
c.Label.Color = [1 1 1]; 
caxis([min_velocity max_velocity]);

ax = gca; 
ax.Color = 'w'; ax.XColor = 'w'; ax.YColor = 'w'; ax.ZColor = 'w'; 
ax.FontSize = 14; ax.FontWeight = 'bold'; 
set(gcf, 'InvertHardCopy', 'off'); 
set(gcf,'Color',[0 0 0]); % RGB values [0 0 0] indicates black color
%% Velocimetry ANALYSIS

frameID = 26; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%  DATASET: AEVA %%%%%%%%%%%%%%%%%%%%%

pc_rocket_temp = pointCloud(double(pc_data_rocket(frameID).xyz'));
roi = [2 5.2 -2 2 -1 1]; 
i_roi = findPointsInROI(pc_rocket_temp, roi);
Aeva_pc_select = select(pc_rocket_temp,i_roi);
vel = pc_data_rocket(frameID).velocity; 
aevaLidarVelocities = vel(i_roi);
aevaLidarVelocities = aevaLidarVelocities(aevaLidarVelocities>-0.5);

% figure
% subplot(2,1,1)
% pcshow(Aeva_pc_select); xlabel('x'); ylabel('y'); zlabel('z');
% title('Aeva PointCloud');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%  DATASET: NARPA %%%%%%%%%%%%%%%%%%%%%

xt = myObject(frameID).t{1}; yt = myObject(frameID).t{2}; zt = myObject(frameID).t{3};
nanIDs = isnan(xt);
xt = xt(~nanIDs);    yt = yt(~nanIDs);  zt = zt(~nanIDs);

velocity_channel = Rrate(frameID,:);
velocity_channel2 = velocity_channel(~nanIDs); % nanIDs correspond
velocity_channel2 = velocity_channel2'; 
 
% POINT CLOUD | NARPA
narpa_ptCloud = pointCloud([xt, yt, zt]); 
roi = [-1 2.5 -1.5 1.5 -4 4];
i_roi = findPointsInROI(narpa_ptCloud, roi);
narpa_pc_select = select(narpa_ptCloud,i_roi);

% subplot(2,1,2)
% pcshow(narpa_pc_select); xlabel('x'); ylabel('y'); zlabel('z'); axis on; 
% title('NARPA PointCloud');
narpaVelocities = (velocity_channel2(i_roi));


figure
fontSize = 14;
histogram(aevaLidarVelocities(aevaLidarVelocities>-0.5 & aevaLidarVelocities<0.5), ...
    'BinEdges', linspace(-0.5, 0.5, 40),'Normalization', 'probability', ...
    'DisplayStyle', 'bar', 'EdgeColor', 'b', 'EdgeAlpha', 0.8, 'FaceColor', 'b', 'FaceAlpha', 0.25, 'LineStyle', "none"); 
hold on; 
histogram(narpaVelocities(narpaVelocities>-0.5 & narpaVelocities<0.5), ...
    'BinEdges', linspace(-0.5, 0.5, 40), 'Normalization', 'probability', ...
    'DisplayStyle', 'bar', 'EdgeColor', 'r', 'EdgeAlpha', 0.8, 'FaceColor', 'r', 'FaceAlpha', 0.25, 'LineStyle', "none");
hold off;
title('Instant velocity vistribution (single frame)', 'Interpreter','latex', 'FontSize', fontSize); legend('{Aeva}', '{Renderer}', 'Interpreter','latex', 'FontSize', fontSize);
xlabel('{Instant velocity bins} {(m/s)}', 'Interpreter','latex', 'FontSize', fontSize);
ylabel('{Probability}', 'Interpreter','latex', 'FontSize', fontSize);
ax = gca;
ax.FontSize = 16; 
ylim([0 0.1])
xlim([-0.5 0.5])

%% Averaged Histogram

numFrames = 100; % Replace with the actual number of frames
numBins = 40;

% allAevaVelocities = zeros(numBins, numFrames);
% allNarpaVelocities = zeros(numBins, numFrames);


allAevaVelocities = [];
allNarpaVelocities = [];

mad_Aeva = zeros(numFrames,2);
mad_Narpa = zeros(numFrames,2);

mad_Aeva_xyz = zeros(numFrames,3);
mad_Narpa_xyz = zeros(numFrames,3);

Aeva_var = zeros(numFrames,1);
Narpa_var = zeros(numFrames,1);
Aeva_var2 = zeros(numFrames,1);
Narpa_var2 = zeros(numFrames,1);

for frameID = 1:numFrames
pc_rocket_temp = pointCloud(double(pc_data_rocket(frameID).xyz'));
roi = [2 5.2 -2 2 -1 1]; 
i_roi = findPointsInROI(pc_rocket_temp, roi);
Aeva_pc_select = select(pc_rocket_temp,i_roi);
vel = pc_data_rocket(frameID).velocity; 
aevaLidarVelocities = vel(i_roi);
% aevaLidarVelocities = aevaLidarVelocities(aevaLidarVelocities>-0.5);

xt = myObject(frameID).t{1}; yt = myObject(frameID).t{2}; zt = myObject(frameID).t{3};
nanIDs = isnan(xt);
xt = xt(~nanIDs);    yt = yt(~nanIDs);  zt = zt(~nanIDs);

velocity_channel = Rrate(frameID,:);
velocity_channel2 = velocity_channel(~nanIDs); % nanIDs correspond
velocity_channel2 = velocity_channel2'; 
 
% POINT CLOUD | NARPA
narpa_ptCloud = pointCloud([xt, yt, zt]); 
roi = [-1 2.5 -1.5 1.5 -4 4];
i_roi = findPointsInROI(narpa_ptCloud, roi);
narpa_pc_select = select(narpa_ptCloud,i_roi);
narpaVelocities = (velocity_channel2(i_roi));


[counts_a, binEdges_a] = histcounts(aevaLidarVelocities(aevaLidarVelocities>-0.5 & aevaLidarVelocities<0.5), numBins);
[counts_n, binEdges_n] = histcounts(narpaVelocities(narpaVelocities>-0.5 & narpaVelocities<0.5), numBins);


allAevaVelocities(:, frameID) = counts_a;
allNarpaVelocities(:, frameID) = counts_n;

allAevaVelocities = [allAevaVelocities; aevaLidarVelocities(aevaLidarVelocities>-0.5 & aevaLidarVelocities<0.5)];
allNarpaVelocities = [allNarpaVelocities; narpaVelocities(narpaVelocities>-0.5 & narpaVelocities<0.5)];


% Median Absolute Deviation
aevaLidarVelocities = aevaLidarVelocities(aevaLidarVelocities>-0.5 & aevaLidarVelocities<0.5);
narpaVelocities= narpaVelocities(narpaVelocities>-0.5 & narpaVelocities<0.5);

mad_Aeva(frameID, 1) = mad(aevaLidarVelocities, 0); % mean
mad_Aeva(frameID, 2) = mad(aevaLidarVelocities, 1); % Median
mad_Narpa(frameID, 1) = mad(narpaVelocities, 0);
mad_Narpa(frameID, 2) = mad(narpaVelocities, 1);


std_dev_Aeva(frameID) = std(aevaLidarVelocities);
std_dev_Narpa(frameID) = std(narpaVelocities);


%%%% XYZ POINT CLOUD
Aeva_xyz_centroid = mean(Aeva_pc_select.Location);
Narpa_xyz_centroid = mean(narpa_pc_select.Location);

Aeva_var(frameID) = sum( ( Aeva_xyz_centroid(1) - Aeva_pc_select.Location(:,1) ).^2 + ...
    ( Aeva_xyz_centroid(2) - Aeva_pc_select.Location(:,2) ).^2 + ...
    ( Aeva_xyz_centroid(3) - Aeva_pc_select.Location(:,3) ).^2  );
Aeva_var2(frameID) = Aeva_var(frameID);
Aeva_var(frameID) = Aeva_var(frameID)./ length(Aeva_pc_select.Location(:,1));


Narpa_var(frameID) = sum( ( Narpa_xyz_centroid(1) - narpa_pc_select.Location(:,1) ).^2 + ...
    ( Narpa_xyz_centroid(2) - narpa_pc_select.Location(:,2) ).^2 + ...
    ( Narpa_xyz_centroid(3) - narpa_pc_select.Location(:,3) ).^2 );
Narpa_var2(frameID) =Narpa_var(frameID);
Narpa_var(frameID) = Narpa_var(frameID)/length(narpa_pc_select.Location(:,1));


mad_Aeva_xyz(frameID, 1:3) = [mad(Aeva_pc_select.Location(:,1),1), ...
    mad(Aeva_pc_select.Location(:,2),1), mad(Aeva_pc_select.Location(:,3),1)]; % Median

mad_Narpa_xyz(frameID, 1:3) = [mad(narpa_ptCloud.Location(:,1),1), ...
    mad(narpa_ptCloud.Location(:,2),1), mad(narpa_ptCloud.Location(:,3),1)]; % Median

end


averageAevaVelocities = mean(allAevaVelocities, 2);
averageNarpaVelocities = mean(allNarpaVelocities, 2);


figure
fontSize = 24;
histogram(allAevaVelocities, ...
    'BinEdges', linspace(-0.5, 0.5, numBins),'Normalization', 'probability', ...
    'DisplayStyle', 'bar', 'EdgeColor', 'b', 'EdgeAlpha', 0.8, 'FaceColor', 'b', 'FaceAlpha', 0.2, 'LineStyle', "none"); 
hold on; 
histogram(allNarpaVelocities, ...
    'BinEdges', linspace(-0.5, 0.5, numBins), 'Normalization', 'probability', ...
    'DisplayStyle', 'bar', 'EdgeColor', 'r', 'EdgeAlpha', 0.8, 'FaceColor', 'r', 'FaceAlpha', 0.25, 'LineStyle', "none");
hold off;
% bar(binEdges_a(1:end-1), averageAevaVelocities / sum(averageAevaVelocities), 'EdgeColor', 'r', 'FaceColor', 'r', 'EdgeAlpha', 1, 'FaceAlpha', 0.5);
% hold on; 
% bar(binEdges_a(1:end-1), averageNarpaVelocities / sum(averageNarpaVelocities), 'EdgeColor', 'b', 'FaceColor', 'b', 'EdgeAlpha', 1, 'FaceAlpha', 0.5);
% hold off;
title('{Instant Velocity Distribution}', 'Interpreter','latex', 'FontSize', fontSize); legend('{Aeva}', '{Renderer}', 'Interpreter','latex', 'FontSize', fontSize);
xlabel('{Instant velocity bins} {(m/s)}', 'Interpreter','latex', 'FontSize', fontSize);
ylabel('{Probability}', 'Interpreter','latex', 'FontSize', fontSize);
ax = gca;
ax.FontSize = 16; 
ylim([0 0.07])
xlim([-0.5 0.5])

%% MAD Velocities
figure
plot(2:numFrames, mad_Aeva(2:end,2), 'b', 2:numFrames, mad_Narpa(2:end,2), 'r', ...
    'LineWidth', 2);
hold on; 
patch([(2:numFrames) fliplr(2:numFrames)], [transpose(mad_Aeva(2:end,2)+std_dev_Aeva(2:end)) fliplr(transpose(mad_Aeva(2:end,2)-std_dev_Aeva(2:end)))], 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.1);
patch([(2:numFrames) fliplr(2:numFrames)], [transpose(mad_Narpa(2:end,2)+std(mad_Narpa(2:end,2))) fliplr(transpose(mad_Narpa(2:end,2)-std(mad_Narpa(2:end,2))))], 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.2);
hold off
title('{Median Absolute Deviation (MAD)}', 'Interpreter','latex', 'FontSize', fontSize); legend('{Aeva}', '{Renderer}', '${1\sigma_{Renderer}}$','Interpreter','latex', 'FontSize', fontSize);
xlabel('{Frames}', 'Interpreter','latex', 'FontSize', fontSize);
ylabel('{Instantaneous Velocities (m/s)}', 'Interpreter','latex', 'FontSize', fontSize);
ax = gca;
ax.FontSize = 16; 
% ylim([0 0.25])
xlim([2 100])

%% MAD Point Clouds
figure
plot(2:numFrames, (Aeva_var(2:end)), 'b', 2:numFrames, (Narpa_var(2:end)), 'r', ...
    'LineWidth', 2);
hold on; 
patch([(2:numFrames) fliplr(2:numFrames)], [transpose(mad_Aeva(2:end,2)+std_dev_Aeva(2:end)) fliplr(transpose(mad_Aeva(2:end,2)-std_dev_Aeva(2:end)))], 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.1);
patch([(2:numFrames) fliplr(2:numFrames)], [transpose(mad_Narpa(2:end,2)+std(mad_Narpa(2:end,2))) fliplr(transpose(mad_Narpa(2:end,2)-std(mad_Narpa(2:end,2))))], 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.2);
hold off
title('Sample variance of pointcloud', 'Interpreter','latex', 'FontSize', fontSize); legend('{Aeva}', '{Renderer}', '${1\sigma_{Renderer}}$','Interpreter','latex', 'FontSize', fontSize);
xlabel('{Frames}', 'Interpreter','latex', 'FontSize', fontSize);
ylabel('point cloud units (m)', 'Interpreter','latex', 'FontSize', fontSize);
ax = gca;
ax.FontSize = 16; 
ylim([0 1])
xlim([2 100])
