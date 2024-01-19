function makeAevaImageVideo(pc_data, location, saveAsFileName)

n_frames = numel(pc_data);

% myWriter = VideoWriter(strcat(location, '/', saveAsFileName), 'Motion JPEG AVI');
% myWriter.Quality = 100;
% myWriter.FrameRate = 10;
% open(myWriter);

% Ncol = 1000; % RESOLUTION

for INPUT_FRAME = 1:n_frames

  figure
  myFrame = pc_data(INPUT_FRAME).image;
%   im_plot = imshow(myFrame);
  imwrite(myFrame, strcat(location, '/', string(INPUT_FRAME) , ".png"));
  
  drawnow;
%   writeVideo(myWriter,getframe(gcf));
%   delete(im_plot);
end
%  close(myWriter);
end