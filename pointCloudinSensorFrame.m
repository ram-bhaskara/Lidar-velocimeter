function pointCloudinSensorFrame(PC_filename, Rotm)


%     PC_filename = 'wall_t1t3_99.txt';
    data = textread(PC_filename); 
    x_data = data(:,1); 
    y_data = data(:,2); 
    z_data = data(:,3);
    
    x_data(x_data>1e5)=NaN;
    y_data(y_data>1e5)=NaN;
    z_data(z_data>1e5)=NaN;
    
    xyzPoints = [x_data, y_data, z_data]; 
    ptCloud = pointCloud(xyzPoints);

    figure
    subplot(2,1,1)
    pcshow(ptCloud);
%     plot3(x_data, y_data, z_data, '.','MarkerSize',0.5); 
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('Point cloud | NaRPA')
    axis equal
    grid on
    
% Rotation into sensor coordinate frame
    xyzPoints_ = zeros(3, length(xyzPoints)); 

    for ii = 1:length(xyzPoints)
        xyzPoints_(:,ii) = Rotm * transpose(xyzPoints(ii,:));
    end
    ptCloud = pointCloud(xyzPoints_');

    subplot(2,1,2)
    pcshow(ptCloud);
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('Point cloud | NaRPA')
    axis equal
    grid on

end