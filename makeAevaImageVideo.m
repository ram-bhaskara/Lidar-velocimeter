function makeAevaImageVideo(pc_data)

myWriter = VideoWriter('Aeva_t1t3_imagery_aeva','MPEG-4');
myWriter.Quality = 100;
myWriter.FrameRate = 10;
open(myWriter);

% Ncol = 1000; % RESOLUTION

for INPUT_FRAME = 1:141

  figure
  im_plot = imshow(pc_data(INPUT_FRAME).image);
    
  drawnow;
  writeVideo(myWriter,getframe(gcf));
  delete(im_plot);
end
 close(myWriter);
end