function narpaPlotter(pointCloudObject, Rrate, location, plotVideo, videoName)
% pointCloudObject = myObject;
% videoName = 'sRockTest';
% location = pwd; 

fig = figure;
set(fig, 'Position', [100, 100, 800, 500]);

    if plotVideo
        myWriter = VideoWriter(fullfile(location, videoName), 'Motion JPEG AVI');
        myWriter.FrameRate = 10; % Set the frame rate (adjust as needed)
        myWriter.Quality = 50;
        open(myWriter);
    end

title('Velocity Color-coded Point Cloud Animation');
xlabel('X'); ylabel('Y'); zlabel('Z');
cmap = load('blueRedCmap.mat');
cmap = cmap.blueRedCmap; 
min_velocity = -0.5;
max_velocity = 0.5;

colormap(cmap);

for frameID = 1:1:100
% frameID = 35;

xt = pointCloudObject(frameID).t{1};
yt = pointCloudObject(frameID).t{2};
zt = pointCloudObject(frameID).t{3};

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
% % view([0 -90])
% view([0 -90])
az = frameID * 360 / 70;  
camorbit(az, 0, 'data');

c = colorbar; c.Color = [1 1 1]; 
c.Label.String = 'velocity (m/s)'; c.Label.FontSize = 12; 
c.Label.Color = [1 1 1]; caxis([min_velocity max_velocity]);

ax = gca; 
ax.Color = 'k'; ax.XColor = 'k'; ax.YColor = 'k'; ax.ZColor = 'k'; 
ax.FontSize = 10; ax.FontWeight = 'bold'; 
drawnow;
    if plotVideo
         % Refresh the figure
        frame_data = getframe(fig);
        frame_data.cdata = imresize(frame_data.cdata, [420, 560]);
        writeVideo(myWriter, frame_data);
        clf; % Clear figure for the next iteration
    end
end

    if plotVideo
        close(myWriter);
    end
end