% Generates point cloud colors based on Doppler velocities.

INPUT_FRAME = 70;

% POINT CLOUD plots

pc_temp = pointCloud(double(pc_data(INPUT_FRAME).xyz'));
    roi = [2 6.2 -4 4 -2 2];
    i_roi = findPointsInROI(pc_temp,roi);
    pc_select = select(pc_temp,i_roi);
   
    myX = pc_select.Location(:,1); myY = pc_select.Location(:,2);
    myZ = pc_select.Location(:,3); 
    

vel = pc_data(INPUT_FRAME).velocity;
velocity_channel = vel(i_roi);
min_velocity = -0.5;
max_velocity = 0.5;
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
    pcshow(pc_select)
    colorbar;
    caxis([min_velocity max_velocity]); 
   




