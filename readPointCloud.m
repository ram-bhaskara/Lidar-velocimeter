% addpath()


function [x_data, y_data, z_data] = readPointCloud(filename)

data = textread(filename); 
x_data = data(:,1); 
y_data = data(:,2); 
z_data = data(:,3);

x_data(x_data>1e5)=NaN;
y_data(y_data>1e5)=NaN;
z_data(z_data>1e5)=NaN;

figure
plot3(x_data, y_data, z_data,'.','MarkerSize',0.5);
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Point cloud in body-frame | NaRPA')
axis equal
end