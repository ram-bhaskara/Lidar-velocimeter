function myVec = clip(x, xmin, xmax)
    x(x<xmin) = xmin;
    x(x>xmax) = xmax;
    myVec = x;
end