% function AevaPcRecord_AstWall(pc_data, location, saveAsFileName)

% To record velocimetry 

% Assuming pc_data is a structure array with fields xyz and velocity 
% Total number of frames
num_frames = numel(pc_data);


fig = figure;
set(fig, 'Position', [ 100, 100, 560, 420 ]);
title('Velocity Color-coded Point Cloud Animation');
xlabel('X');
ylabel('Y');
zlabel('Z');

% myWriter = VideoWriter(strcat(location, '/', saveAsFileName), 'Motion JPEG AVI');
% myWriter.Quality = 100;
% myWriter.FrameRate = 10;
% myWriter.Width = 200;
% myWriter.Height = 200;
% open(myWriter);

% min_velocity = -2.0;
% max_velocity = 0.45;
min_velocity = -0.2;
max_velocity = 0.2;
static_color = [ 1.0, 1.0, 1.0 ];

% logic for corresponding colorbar

colorMap = [linear_interpolate(static_color, [1,0,0], linspace(1,0,128)'); ...
    linear_interpolate(static_color, [0 0 1], linspace(0,1,128)')]; 
colormap(colorMap); 
colorbar;

for INPUT_FRAME = 1:20

    pc_temp = pointCloud(double(pc_data(INPUT_FRAME).xyz'));
%     roi = [2 5.2 -2 2 -1 1]; 
    roi = [7 9 -2.5 2.5 -1.5 1.5]; % traj1_test3
%     i_roi = findPointsInROI(pc_temp,roi);
%     pc_select = select(pc_temp,i_roi);
   pc_select = pc_temp;
    myX = pc_select.Location(:,1); myY = pc_select.Location(:,2);
    myZ = pc_select.Location(:,3); 
    
%     velocity_channel = vel; 

    vel = pc_data(INPUT_FRAME).velocity;
%     velocity_channel = vel(i_roi);
    vel_estimate = pc_data(INPUT_FRAME).linear_vel1;
   velocity_channel = vel; 

    for ii = 1:length(myX)
    direction = [myX(ii) myY(ii) myZ(ii)];
    velocity_channel(ii) = vel(ii) - myX(ii) * vel_estimate(1) / norm(direction);
    end

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
        view([-135 10]);
        
        
        
        c = colorbar;
        c.Color = [1 1 1];
        c.Label.String = 'velocity (m/s)'; 
        c.Label.FontSize = 12;
        c.Label.Color = [1 1 1];
        caxis([min_velocity max_velocity]);
        

        drawnow;

        frame_data = getframe(fig);
      
        frame_data.cdata = imresize(frame_data.cdata, [420, 560]);
        
%         writeVideo(myWriter, frame_data);
%         clf; % Clear figure for the next iteration
        
    end

%     close(myWriter);
% end