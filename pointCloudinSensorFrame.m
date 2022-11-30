function pc_sensor = pointCloudinSensorFrame(PC_filename, lookFrom, lookAt, up)


%     PC_filename = 'wall_t1t3_99.txt';
    data = textread(PC_filename); 
    x_data = data(:,1); 
    y_data = data(:,2); 
    z_data = data(:,3);
    
    x_data(x_data>1e5)=NaN;
    y_data(y_data>1e5)=NaN;
    z_data(z_data>1e5)=NaN;

    R_r = [0 1 0; 1 0 0; 0 0 1]  ;

% R_r = R;
% t_r = t'
%     t_r = zeros(3,1);
t_r = R_r * ([0 0 0]' - lookFrom);
%     t_r = R_r' * ([-0.268 4.02 0.74]' - lookFrom);
%     Rt_frame = [R',t];
%%
    temp = zeros(3,1);
    xs = zeros(length(x_data),1); ys = xs; zs = xs;
    for ii = 1:length(x_data)
        point_ = [x_data(ii,1); y_data(ii,1); z_data(ii,1)];
        temp = R_r * point_ + t_r;
        xs(ii) = temp(1);
        ys(ii) = temp(2);
        zs(ii) = temp(3);        
    end
    pc_sensor = [xs ys zs];

    figure
    subplot(2,1,1)
    plot3(x_data, y_data, z_data, '.','MarkerSize',0.5); 
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('Point cloud in body-frame | NaRPA')
    axis equal

    subplot(2,1,2)
    plot3(xs, ys, zs,'.','MarkerSize',0.5);
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('Point cloud in sensor-frame | NaRPA')
    axis equal
end