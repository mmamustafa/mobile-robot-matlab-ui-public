function P = homog2cart(P)
% -------------------------------------------------------------------------
% CART2HOMOG    converts coordinates from homogeneous to cartesian in
% d-dimensional space.
%
% Usage
% 	P = HOMOG2CART(P);
%
% Parameters
%   P   (d+1, n)    homogeneous points
%
% Returns
%   P	(d, n)      cartesian point in d-dimensions.
%
% Implementation
%   Mohamed Mustafa, July 2010
% -------------------------------------------------------------------------

D = size(P,1);                  % dimension of the points
w = repmat(P(end,:),D-1,1);     % last element of each point in homogeneous
P = P(1:D-1,:)./w;
end
