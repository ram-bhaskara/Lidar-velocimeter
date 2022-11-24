function qm=quat_err(q1,q2);
%function qm=quat_err(q1,q2);
%
% This program determines the error quaternion q1*q2^-1.
%
%  The inputs are:
%    q1 = first quaternion set (mx4)
%    q2 = second quaternion set (mx4)
%
%  The output is q1xq2^-1

% John L. Crassidis 4/24/95
q1 = reshape(q1,1,4);
q2 = reshape(q2,1,4);

q2(:,1:3)=-q2(:,1:3);
qm(:,1)=q1(:,4).*q2(:,1)+q1(:,3).*q2(:,2)-q1(:,2).*q2(:,3)+q1(:,1).*q2(:,4);
qm(:,2)=-q1(:,3).*q2(:,1)+q1(:,4).*q2(:,2)+q1(:,1).*q2(:,3)+q1(:,2).*q2(:,4);
qm(:,3)=q1(:,2).*q2(:,1)-q1(:,1).*q2(:,2)+q1(:,4).*q2(:,3)+q1(:,3).*q2(:,4);
qm(:,4)=-q1(:,1).*q2(:,1)-q1(:,2).*q2(:,2)-q1(:,3).*q2(:,3)+q1(:,4).*q2(:,4);

%normalize: Note, comment this out if you don't want it!!

nn=(qm(:,1).^2+qm(:,2).^2+qm(:,3).^2+qm(:,4).^2).^0.5;
qm(:,1)=qm(:,1)./nn;
qm(:,2)=qm(:,2)./nn;
qm(:,3)=qm(:,3)./nn;
qm(:,4)=qm(:,4)./nn;
