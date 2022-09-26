function M = linear_interpolate(point1, point2, alphas)
    
    % Linearly interpolate point1 --> point2, given a vector of alphas
    
    points1 = repmat(point1, length(alphas),1);
    points2 = repmat(point2, length(alphas),1);
    
    M = (ones(length(alphas),1)-alphas).*points1 + alphas.*points2;
end