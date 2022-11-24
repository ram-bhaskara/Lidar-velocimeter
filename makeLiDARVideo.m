function makeLiDARVideo(pc_data)

% PARAMETERS FOR FOR TRAJ4_TEST1 

% myWriter = VideoWriter('Aeva_t4t1_PointScans','MPEG-4');
myWriter = VideoWriter('Aeva_t4t1_velMap','MPEG-4');
myWriter.Quality = 100;
myWriter.FrameRate = 10;
open(myWriter);

Ncol = 1000; % RESOLUTION

for INPUT_FRAME = 1:150

    pc_temp = pointCloud(double(pc_data(INPUT_FRAME).xyz'));
%     roi = [0 4.5 -1.2 0.02*(INPUT_FRAME-69) -2 2];
    roi = [0 5 -2 2 -1 1];
    i_roi = findPointsInROI(pc_temp,roi);
    pc_select = select(pc_temp,i_roi);
% pc_select = pc_temp;
   
    myX = pc_select.Location(:,1); myY = pc_select.Location(:,2);
    myZ = pc_select.Location(:,3); 
    
    vel = pc_data(INPUT_FRAME).velocity; 
    vel = vel(i_roi); 
%     range = vecnorm([myX myY myZ]');
    myVar = vel;
%%
    minVar = min(myVar); maxVar = max(myVar);
    intensity = myVar + (-1)*minVar; 
    intensity = (intensity./max(intensity,[],'all'))*Ncol; 
    
    figure
    subplot(2,1,1)
    CMap = colormap(jet(Ncol)); 
    pcPlot = scatter3(myX, myY, myZ, 1, CMap(max(1,round(intensity)),:));
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title("Range (Aeva) frame: "+INPUT_FRAME+" | time t = "+pc_data(INPUT_FRAME).timestamp);
    axis equal
    view([-110,20])
    colorbar
    caxis([minVar maxVar])
%     % set(gcf, 'InvertHardCopy', 'off'); 
%     % set(gca, 'color', 'k');

    %% Histogram of velocities
    subplot(2,1,2)
    histogram(myVar)
    title('Velocity Histogram'); xlabel('Velocity'); ylabel('Points'); 
    drawnow;
    writeVideo(myWriter,getframe(gcf));
    delete(pcPlot);
end
 close(myWriter);
end