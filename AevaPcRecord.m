function AevaPcRecord(pc_data)

% To record velocimetry
% spinning rocket body


myWriter = VideoWriter('spinningSatellite','MPEG-4');
myWriter.Quality = 100;
myWriter.FrameRate = 10;
open(myWriter);


for INPUT_FRAME = 1:3:175

    pc_temp = pointCloud(double(pc_data(INPUT_FRAME).xyz'));
    roi = [2 5.2 -2 2 -1 1];
    i_roi = findPointsInROI(pc_temp,roi);
    pc_select = select(pc_temp,i_roi);
   
    myX = pc_select.Location(:,1); myY = pc_select.Location(:,2);
    myZ = pc_select.Location(:,3); 
    

vel = pc_data(INPUT_FRAME).velocity;
velocity_channel = vel(i_roi);
min_velocity = -1.5;
max_velocity = 0.45;
static_color = [1.0,1.0,1.0];

colors = repmat(static_color, length(velocity_channel), 1); 

pos_idx = find(velocity_channel > 0);
pos_mag = clip(velocity_channel(pos_idx)/max_velocity, 0, 1); 
colors(pos_idx,:) = linear_interpolate(static_color,[1.0,0.0,0.0],pos_mag); 

neg_idx = find(velocity_channel < 0);
neg_mag = clip(velocity_channel(neg_idx)/min_velocity, 0, 1); 
colors(neg_idx,:) = linear_interpolate(static_color,[0.0,0.0,1.0],neg_mag); 

colors = uint8(255*colors);
pc_select.Color = colors;
    
    figure
    pcPlot = pcshow(pc_select);
    c = colorbar;
    custom_cmap = load('custom_dockingColormap.mat');
    colormap(custom_cmap.custom_dockingCmap);
    c.Color = [1 1 1]; 
    c.Label.String = 'velocity (m/s)'; c.Label.FontSize = 12;
    c.Label.Color = [1 1 1];
    caxis([min_velocity max_velocity]); 
    xlabel('X'); ylabel('Y'); zlabel('Z');
    xlim([roi(1) roi(2)]);
    ylim([roi(3) roi(4)]);
    zlim([roi(5) roi(6)]);
    %set(gcf,'color','w');
    view([90 0]);


    drawnow;
    writeVideo(myWriter,getframe(gcf));
    delete(pcPlot);  

end

close(myWriter);

end