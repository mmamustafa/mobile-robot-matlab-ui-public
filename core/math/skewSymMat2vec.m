function v = skewSymMat2vec(M)
% -------------------------------------------------------------------------
% Convert a skew symmetric matrix that represents the cross product to a 3D vector.
%
% Inputs:
%   <M>         (3,3)   Skew symmetric matrix (rank 2).
%
% Outputs:
%   <v>         (3,1)   3D vector.
%
% Implementation:   Mohamed Mustafa, July 2017
%
% References:
%   - https://en.wikipedia.org/wiki/Cross_product#Conversion_to_matrix_multiplication
%   - Multiple View Geometry
% -------------------------------------------------------------------------

v = [-M(2,3) M(1,3) -M(1,2)]';
return