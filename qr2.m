function [Q,R] = qr2(A)
% http://nl.mathworks.com/matlabcentral/newsreader/view_thread/48300

[m,n] = size(A);
% compute QR using Gram-Schmidt
for j = 1:n
   v = A(:,j);
   for i=1:j-1
        R(i,j) = Q(:,i)'*A(:,j);
        v = v - R(i,j)*Q(:,i);
   end
   R(j,j) = norm(v);
   Q(:,j) = v/R(j,j);
end