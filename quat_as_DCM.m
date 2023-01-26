function DCM_from_quat = quat_as_DCM (quat)
q = imagq(quat);
q4 = realq(quat);
%This definition for DCM agrees with Dr. Hurtado's book. I checked.
% DCM_from_quat = (2*q4^2-1)*eye(3) - 2*q4*skew(q) +2*(q*q');

%Dr. Hurtado
DCM_from_quat = eye(3)-2*q4*skew(q)+2*skew(q)*skew(q);
