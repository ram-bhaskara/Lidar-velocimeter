function AevaPcRecord(pc_data, location)

    % To record velocimetry % spinning rocket body

    % Assuming pc_data is a structure array with fields xyz and velocity num_frames = numel(pc_data);
% Total number of frames

        fig = figure;
set(fig, 'Position', [ 100, 100, 560, 420 ]);
title('Velocity Color-coded Point Cloud Animation');
xlabel('X');
ylabel('Y');
zlabel('Z');

myWriter = VideoWriter(strcat(location, '/', 'spinningSatellite'), 'Motion JPEG AVI');
myWriter.Quality = 100;
myWriter.FrameRate = 10;
% myWriter.Width = 200;
% myWriter.Height = 200;
open(myWriter);

min_velocity = -1.5;
max_velocity = 0.45;
static_color = [ 1.0, 1.0, 1.0 ];

% logic for corresponding colorbar

colorMap = [linear_interpolate(static_color, [1,0,0], linspace(1,0,128)'); ...
    linear_interpolate(static_color, [0 0 1], linspace(0,1,128)')]; 
colormap(colorMap); 
colorbar;

for INPUT_FRAME = 1:num_frames

    pc_temp = pointCloud(double(pc_data(INPUT_FRAME).xyz'));
    roi = [2 5.2 -2 2 -1 1];
    i_roi = findPointsInROI(pc_temp,roi);
    pc_select = select(pc_temp,i_roi);
   
    myX = pc_select.Location(:,1); myY = pc_select.Location(:,2);
    myZ = pc_select.Location(:,3); 
    

    vel = pc_data(INPUT_FRAME).velocity;
    velocity_channel = vel(i_roi);
   
    colors = repmat(static_color, length(velocity_channel), 1); 
    
    pos_idx = find(velocity_channel > 0);
    pos_mag = clip(velocity_channel(pos_idx)/max_velocity, 0, 1); 
    colors(pos_idx,:) = linear_interpolate(static_color,[1.0,0.0,0.0],pos_mag); 
    
    neg_idx = find(velocity_channel < 0);
    neg_mag = clip(velocity_channel(neg_idx)/min_velocity, 0, 1); 
    colors(neg_idx,:) = linear_interpolate(static_color,[0.0,0.0,1.0],neg_mag); 

    colors = uint8(255*colors);
    pc_select.Color = colors;
    
    pcPlot = pcshow(pc_select);

        xlim([roi(1) roi(2)]);
        ylim([roi(3) roi(4)]);
        zlim([roi(5) roi(6)]);
        xlabel('X'); ylabel('Y'); zlabel('Z');
        axis on;
        set(gcf, 'color', 'k');
        view([90 0]);
        
        
        
        c = colorbar;
        c.Color = [1 1 1];
        c.Label.String = 'velocity (m/s)'; 
        c.Label.FontSize = 12;
        c.Label.Color = [1 1 1];
        caxis([min_velocity max_velocity]);
        

        drawnow;

        frame_data = getframe(fig);
      
        frame_data.cdata = imresize(frame_data.cdata, [420, 560]);
        
        writeVideo(myWriter, frame_data);
        clf; % Clear figure for the next iteration
        
    end

    close(myWriter);
end