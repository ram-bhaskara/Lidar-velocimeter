% Convert points3D.bin from colmap to .ply format

% Replace these paths with your actual file paths
points3DFilePath = '/home/ram/PhD/imageProcessing/velocimetry_HIL/data/spinningRocket/colmap2/sparse/points3D.bin';
outputPLYFilePath = 'sparse_spinningRocket.ply';

% Read points3D.bin file
fid = fopen(points3DFilePath, 'rb');
points3D = fread(fid, [6, inf], 'double')';
fclose(fid);

% Extract 3D coordinates
xyz = points3D(:, 1:3);

% Visualize the point cloud
figure;
scatter3(xyz(:, 1), xyz(:, 2), xyz(:, 3), 10, 'b', 'filled');
xlabel('X');
ylabel('Y');
zlabel('Z');
title('Point Cloud Visualization');

% Save point cloud to PLY file
% plywrite(outputPLYFilePath, xyz);
disp(['Point cloud saved to: ' outputPLYFilePath]);