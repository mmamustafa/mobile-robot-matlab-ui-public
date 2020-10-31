function M = vec2skewSymMat(v)
% -------------------------------------------------------------------------
% Convert a 3D vector to skew symmetric matrix that represents the cross
% product.
%
% Inputs:
%   <v>         (3,1)   3D vector.
%
% Outputs:
%   <M>         (3,3)   Skew symmetric matrix (rank 2).
%
% Implementation:   Mohamed Mustafa, July 2017
%
% References:
%   - https://en.wikipedia.org/wiki/Cross_product#Conversion_to_matrix_multiplication
%   - Multiple View Geometry
% -------------------------------------------------------------------------

M = [   0       -v(3)	v(2);
        v(3)    0       -v(1);
        -v(2)   v(1)    0];
return