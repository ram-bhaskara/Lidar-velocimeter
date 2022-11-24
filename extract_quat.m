function q=extract_quat(att)
%function q=extract(att)
%
% This function extracts the quaternion from the attitude matrix.
% It finds the maximum value of trace of the attitude matrix.
%
%  The input is:
%    att = attitude matrix (3x3)
%
%  The output is:
%      q = quaternion (4x1)

% John L. Crassidis 4/24/95

tracea=trace(att);
[maxdiag,i]=max(diag(att));

%Branch for trace > maxdiag
if(tracea > maxdiag)
   q(4)=0.5*(1+tracea)^(0.5);
   q(1)=(att(2,3)-att(3,2))/(4*q(4));
   q(2)=(att(3,1)-att(1,3))/(4*q(4));
   q(3)=(att(1,2)-att(2,1))/(4*q(4));

%Branch for trace < maxdiag
else
   j=i+1;
   if (j==4), j=1; end
   k=j+1;
   if (k==4), k=1; end
   q(i)=0.5*(2*maxdiag+1-tracea)^(0.5);
   q(j)=(att(i,j)+att(j,i))/(4*q(i));
   q(k)=(att(i,k)+att(k,i))/(4*q(i));
   q(4)=(att(j,k)-att(k,j))/(4*q(i));
end
   
q=q(:);

