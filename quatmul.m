function product = quatmul(q,p)
pvec = imagq(p);
qvec = imagq(q);
q4 = realq(q);

product = [q4*eye(3)-skew(qvec), qvec;
           -qvec',                  q4]*p;

    