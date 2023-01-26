function skew_sym_matrix = skew (v)
%This function constructs a skew symmetric matrix given an 3x1 input vector
 skew_sym_matrix= [  0,-v(3), v(2);
                   v(3),  0,-v(1);
                 -v(2), v(1),  0] ;