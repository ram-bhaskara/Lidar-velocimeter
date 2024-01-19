
saveAsFileName = 'carla2';
num_frames = 465; 

fig = figure;
set(fig, 'Position', [ 100, 100, 560, 420 ]);
title('Velocity Color-coded Point Cloud Animation');
xlabel('X');
ylabel('Y');
zlabel('Z');

cd 
myWriter = VideoWriter(strcat(Aeva_dataset, '/', datapath, saveAsFileName), 'Motion JPEG AVI');
myWriter.Quality = 100;
myWriter.FrameRate = 10;
open(myWriter);


for fileIter = 1:num_frames
    fileName = strcat(datapath, sprintf('%0.5d', fileIter), '.bin');
    
    data = fread(fopen(fileName, "rb"), [4, inf], 'float32')';
    pc = pointCloud(data(:, 1:3), 'Intensity', data(:, 4)); %doppler
    
    pcPlot = pcshow(pc, "ColorSource","Intensity");
    xlim([0 300]);
    ylim([-20 20]);
    zlim([0 30]);
    xlabel('X'); ylabel('Y'); zlabel('Z');
    axis on;
    c = colorbar; 
    c.Color = [1 1 1];
    c.Label.String = 'velocity (m/s)'; 
    c.Label.FontSize = 12;
    c.Label.Color = [1 1 1];

%     caxis([min(data(:,4)) max(data(:,4))]);

    drawnow; 

    frame_data = getframe(fig);
    frame_data.cdata = imresize(frame_data.cdata, [420, 560]);
    writeVideo(myWriter, frame_data);
    clf; % Clear figure for the next iteration
end

close(myWriter);
