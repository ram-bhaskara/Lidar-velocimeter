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

% This is only for plotting purposes - to see the full picture to get a
% gist of what each frame is relatively viewing

fig = figure;
set(fig, 'Position', [100, 100, 800, 500]);

location = pwd; 
myWriter = VideoWriter(fullfile(location, 'spinningSatellite'), 'Motion JPEG AVI');
myWriter.FrameRate = 10; % Set the frame rate (adjust as needed)
myWriter.Quality = 50;
open(myWriter);

title('Velocity Color-coded Point Cloud Animation');
xlabel('X'); ylabel('Y'); zlabel('Z');
cmap = blueRedCmap;
min_velocity = -0.5;
max_velocity = 0.5;

colormap(cmap);

for frameID = 1:2:80
% frameID = 35;

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
roi = [-1 2.5 -1.5 1.5 -4 4];
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
xlabel('X'); ylabel('Y'); zlabel('Z'); axis on; 
view([0 -90])
view([-2.5*frameID 90])

c = colorbar; c.Color = [1 1 1]; 
c.Label.String = 'velocity (m/s)'; c.Label.FontSize = 12; 
c.Label.Color = [1 1 1]; caxis([min_velocity max_velocity]);

ax = gca; 
ax.Color = 'k'; ax.XColor = 'k'; ax.YColor = 'k'; ax.ZColor = 'k'; 
ax.FontSize = 10; ax.FontWeight = 'bold'; 

 drawnow; % Refresh the figure
    
% Capture frame for video
frame_data = getframe(fig);
% Resize frame to 560 by 420
frame_data.cdata = imresize(frame_data.cdata, [420, 560]);
writeVideo(myWriter, frame_data);
clf; % Clear figure for the next iteration
end

% Close the video writer
close(myWriter);
%% Aeva
pc_rocket_temp = pointCloud(double(pc_data_rocket(3).xyz'));
roi = [2 5.2 -2 2 -1 1]; 
i_roi = findPointsInROI(pc_rocket_temp, roi);
pc_select = select(pc_rocket_temp,i_roi);
% narpa_ptCloud.Intensity = uint8(velocity_channel);

vel = pc_data_rocket(3).velocity;
velocity_channel = vel(i_roi);
    
% pc_select.Intensity = uint8(velocity_channel*255); 
% Extract velocities
% vel = pc_select.velocity;
% velocity_channel = vel(i_roi);

figure
pcshow(pc_select)
c = colorbar;
c.Color = [1 1 1];
c.Label.String = 'velocity (m/s)'; 
c.Label.FontSize = 12;
c.Label.Color = [1 1 1];
% caxis([-1.4 0.4]);
%% Velocity Analysis
velocity_channel2 = [];
jj = 1;
for ii = 1:length(velocity_channel)
    if(velocity_channel(ii) < 0 || velocity_channel(ii) > 0)
        velocity_channel2(jj) = velocity_channel(ii);
        jj = jj+1;
    end
end
%%
function interpolated_colors = interpolateColors(data, cmap, min_val, max_val)
    % Normalize data to [0, 1]
    normalized_data = (data - min_val) / (max_val - min_val);
    
    % Clip values to [0, 1]
    normalized_data(normalized_data < 0) = 0;
    normalized_data(normalized_data > 1) = 1;
    
    % Map normalized data to colormap indices
    indices = round(normalized_data * (size(cmap, 1) - 1)) + 1;
    
    % Interpolate colors
    interpolated_colors = cmap(indices, :);
end