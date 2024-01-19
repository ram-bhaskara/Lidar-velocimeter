function AevaPlotter(pc_data, location)

% Assuming pc_data is a structure array with fields xyz and velocity
num_frames = numel(pc_data); % Total number of frames

% Define color map based on velocity
cmap = jet(256);
min_velocity = -1.5;
max_velocity = 0.45;

% Set figure size explicitly
fig = figure;
set(fig, 'Position', [100, 100, 800, 500]);

% Create VideoWriter object
myWriter = VideoWriter(fullfile(location, 'spinningSatellite'), 'Motion JPEG AVI');
myWriter.FrameRate = 10; % Set the frame rate (adjust as needed)
myWriter.Quality = 25;
open(myWriter);

% Create figure
title('Velocity Color-coded Point Cloud Animation');
xlabel('X'); ylabel('Y'); zlabel('Z');
colormap(cmap);

% Add colorbar with white text markings
c = colorbar;
c.Color = [1 1 1]; % Set color to white
c.Label.String = 'Velocity';
c.Label.FontSize = 12;
c.Label.Color = [1 1 1];
caxis([min_velocity max_velocity]);

% Preallocate figure for animation
colors = [1.0, 1.0, 1.0]; % Static color is white

% Set background to black outside the loop
% set(gca, 'Color', 'k');

for frame = 1:10:num_frames
    % Crop points of interest
    pc_temp = pointCloud(double(pc_data(frame).xyz'));
    roi = [2 5.2 -2 2 -1 1];
    i_roi = findPointsInROI(pc_temp, roi);
    
    % Extract velocities
    vel = pc_data(frame).velocity;
    velocity_channel = vel(i_roi);

%     static_color = [1.0, 1.0, 1.0];
%     colors = repmat(static_color, length(velocity_channel), 1);
%     
%     pos_idx = find(velocity_channel > 0);
%     pos_mag = clip(velocity_channel(pos_idx)/max_velocity, 0, 1); 
%     colors(pos_idx,:) = linear_interpolate(static_color,[1.0,0.0,0.0],pos_mag); 
%     
%     neg_idx = find(velocity_channel < 0);
%     neg_mag = clip(velocity_channel(neg_idx)/min_velocity, 0, 1); 
%     colors(neg_idx,:) = linear_interpolate(static_color,[0.0,0.0,1.0],neg_mag); 
% 
%     colors = uint8(255*colors);

    
    % Map velocities to colors
    colors = interpolateColors(velocity_channel, cmap, min_velocity, max_velocity);
   

    % Update point cloud figure using scatter3
    scatter3(pc_temp.Location(i_roi, 1), pc_temp.Location(i_roi, 2), pc_temp.Location(i_roi, 3), ...
        10, colors, 'filled');
    

    xlim([roi(1) roi(2)]);
    ylim([roi(3) roi(4)]);
    zlim([roi(5) roi(6)]);
    xlabel('X'); ylabel('Y'); zlabel('Z');
    axis on;
   
    ax = gca; 
    ax.Color = 'k'; 
    ax.XColor = 'k'; ax.YColor = 'k'; ax.ZColor = 'k'; 
    ax.FontSize = 10; ax.FontWeight = 'bold'; 
%     ax.GridColor = 'y'; ax.GridAlpha = 0.9;

    c = colorbar;
    c.Color = [0 0 0]; % Set color to white
    c.Label.String = 'Velocity';
    c.Label.FontSize = 10;
    c.Label.Color = [0 0 0];
    caxis([min_velocity max_velocity]);
    view([90 0]);

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

end

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
