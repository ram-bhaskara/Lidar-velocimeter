function inv_quat = invq(q)
q = reshape(q,4,1);
inv_quat = [-q(1:3);q(4)];
