function R = q2R(quat)
temp = zeros(1,4);
temp(1) = quat(4); temp(2) = quat(2); temp(3) = quat(3);
temp(4) = quat(1);

% scalar first convention
R = quat2dcm(temp);
end