function R = cameraDCM(LookFrom, LookAt, up)
    
    LookAt = reshape(LookAt, [3,1]);
    LookFrom = reshape(LookFrom, [3,1]);
    up = reshape(up, [3,1]);
    
    zaxis = LookAt - LookFrom; % pointing in the camera plane 
    zaxis = zaxis./norm(zaxis);
    
    xaxis = cross(up, zaxis); 
    xaxis = xaxis./norm(xaxis); 
    
    yaxis = cross(zaxis, xaxis); 
    R = zeros(3,3);
    R = [xaxis, yaxis, zaxis];
   
end