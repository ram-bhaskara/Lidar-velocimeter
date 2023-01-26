%% Read in Aeva data
%h5disp('aeva_pointcloud.h5','/','min')

% Data file
filename = 'JPL_STATIC/mid_back_int'; % INPUT FILE NAME HERE
%%
LIDAR_name = 'LASR1';
file_info = h5info([filename '.h5'],'/0/point_cloud/');
state_est_data_avail = 0;
calibration_data_avail = 1;


%%
% Point Cloud Data
for pt_cloud_ctr = 1:length(file_info.Groups)
    pc_data(pt_cloud_ctr).xyz = h5read(file_info.Filename, [file_info.Groups(pt_cloud_ctr).Name '/xyz']);
    pc_data(pt_cloud_ctr).velocity = h5read(file_info.Filename, [file_info.Groups(pt_cloud_ctr).Name '/velocity']);
    pc_data(pt_cloud_ctr).intensity = h5read(file_info.Filename, [file_info.Groups(pt_cloud_ctr).Name '/intensity']);
    pc_data(pt_cloud_ctr).timestamp = h5read(file_info.Filename, [file_info.Groups(pt_cloud_ctr).Name '/acquisition_timestamp']);
end
pc_count = pt_cloud_ctr;
for pt_cloud_ctr = length(file_info.Groups):-1:1
    pc_data(pt_cloud_ctr).timestamp = double(pc_data(pt_cloud_ctr).timestamp - pc_data(1).timestamp)*1e-9;
    lidar_time(pt_cloud_ctr) = pc_data(pt_cloud_ctr).timestamp;
end

% Image data
file_info = h5info([filename '.h5'],'/0/image/');
for image_ctr = 1:length(file_info.Groups)
    image_data_raw = h5read(file_info.Filename,[file_info.Groups(image_ctr).Name '/image_data']);
    image_data_temp(:,:,1) = image_data_raw(3,:,:);
    image_data_temp(:,:,2) = image_data_raw(2,:,:);
    image_data_temp(:,:,3) = image_data_raw(1,:,:);    
    pc_data(image_ctr).image = fliplr(imrotate3(image_data_temp,-90,[0 0 1],'linear','loose'));
end
image_count = image_ctr; 

% Calibration Data
if(calibration_data_avail)
    file_info = h5info([filename '.h5'],'/0/calibration');
    calib_data.image_dist_coef = h5read(file_info.Filename, [file_info.Groups(1).Name '/image_distortion_coefficients']);
    calib_data.image_matrix = h5read(file_info.Filename, [file_info.Groups(1).Name '/image_matrix']);
    calib_data.rotation_reference_sensor = h5read(file_info.Filename, [file_info.Groups(1).Name '/rotation_reference_sensor']);
    calib_data.rotation_sensor_camera = h5read(file_info.Filename, [file_info.Groups(1).Name '/rotation_sensor_camera']);
    calib_data.translation_reference_sensor = h5read(file_info.Filename, [file_info.Groups(1).Name '/translation_reference_sensor']);
    calib_data.translation_sensor_camera = h5read(file_info.Filename, [file_info.Groups(1).Name '/translation_sensor_camera']);   
    aeva_intrinsic = reshape(calib_data.image_matrix,3,3);
    aeva_rel_trans = calib_data.translation_sensor_camera; % in LIDAR frame
    aeva_rel_rot = quat_as_DCM(calib_data.rotation_sensor_camera); % C_C2L
end

if(state_est_data_avail)
    % Vehicle State Estimate data
    file_info = h5info([filename '.h5'],'/0/vehicle_state_estimate/');
    for veh_state_ctr = 1:length(file_info.Groups)
        pc_data(veh_state_ctr).ang_vel1 = h5read(file_info.Filename, [file_info.Groups(veh_state_ctr).Name '/angular_vel']);
        pc_data(veh_state_ctr).cov_state1 = h5read(file_info.Filename, [file_info.Groups(veh_state_ctr).Name '/cov_state']);
        pc_data(veh_state_ctr).linear_acc1 = h5read(file_info.Filename, [file_info.Groups(veh_state_ctr).Name '/linear_acc']);
        pc_data(veh_state_ctr).linear_vel1 = h5read(file_info.Filename, [file_info.Groups(veh_state_ctr).Name '/linear_vel']);
        pc_data(veh_state_ctr).imu_quat = h5read(file_info.Filename, [file_info.Groups(veh_state_ctr).Name '/rotation']);
        pc_data(veh_state_ctr).imu_pos = h5read(file_info.Filename, [file_info.Groups(veh_state_ctr).Name '/translation']);
    end

%     % Velocity Estiamte Data
%     file_info = h5info([filename '.h5'],'/0/velocity_estimate/');
%     for vel_est_ctr = 1:length(file_info.Groups)
%         pc_data(vel_est_ctr).ang_vel2 = h5read(file_info.Filename, [file_info.Groups(vel_est_ctr).Name '/angular_velocity']);
%         pc_data(vel_est_ctr).ang_vel_conf = h5read(file_info.Filename, [file_info.Groups(vel_est_ctr).Name '/angular_velocity_conf']);
%         pc_data(vel_est_ctr).linear_vel2 = h5read(file_info.Filename, [file_info.Groups(vel_est_ctr).Name '/linear_velocity']);
%         pc_data(vel_est_ctr).linear_vel_conf = h5read(file_info.Filename, [file_info.Groups(vel_est_ctr).Name '/linear_velocity_conf']);
% 
%     end
end

% Truncate data to least amount:
if(image_count<pc_count)
    pc_data = pc_data(1:image_count-1);
else
    pc_data = pc_data(1:pc_count-1);
end
lidar_time = lidar_time(1:size(pc_data,2));
% Camera to LIDAR Parameters
% Image size
imageSize = [1081,1920];
if(calibration_data_avail)
    % Cam Params 
    cam_intrinsic_matrix = aeva_intrinsic;
    cam_params = cameraParameters('IntrinsicMatrix',cam_intrinsic_matrix,'ImageSize',imageSize);
    % Cam LIDAR Calibration
    C_cam2lidar = aeva_rel_rot';
    t_lidar2cam = C_cam2lidar'*aeva_rel_trans; % in camera frame now   
end