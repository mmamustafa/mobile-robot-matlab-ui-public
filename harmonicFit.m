function [a, b] = harmonicFit(t, x, freqs)
%HARMONICFIT fits a sum of sine waves to a time series
%   [A, B] = HARMONICFIT(T, X, FREQS) performs a least squares fit of a sum
%   of sine waves of known frequencies to a possibly irregular time series.
% 
%   T is a either a vector of sample times, or a scalar giving the time
%   step between equally spaced sample times. If it is a scalar the time of
%   the first sample is 0.
% 
%   X is a vector of data samples. If T is a vector, T and X must have the
%   same length. X may contain NaN values to indicate missing data.
% 
%   FREQS is a vector of the frequencies of the sine waves of the model.
% 
%   A and B are vectors of length equal to the length of FREQS, containing
%   the amplitudes of the cosine and sine components of the model with the
%   best least squares fit to the data. That is, A and B are chosen to
%   minimise
% 
%       E = SUM { X(n) - SUM [ A(k) * cos(2*pi*FREQS(k)*T(n) + 
%            n            k                                      2
%                              B(k) * sin(2*pi*FREQS(k)*T(n) ]  }
% 
%   where T(n) is the time of X(n).
% 
%   Note that if a component is written using amplitude and phase as C(k) *
%   sin(2*pi*F(k)*T(n) + PHI(k)), then C = hypot(A,B) and PHI =(mod 2*pi)
%   atan2(A,B).
% 
%   See also: harmonicSynth

if isscalar(t)
    % assume time of x(1) is 0 and time increment is given
    tstart = 0;
    N = length(x);
    t = linspace(0, t*(N-1), N);
else
    tstart = t(1);
    t = t - tstart;
    t = t(:).';    % force row vector
end

% deal with missing data
missing = isnan(x);
t(missing) = [];
x(missing) = [];

% Form array of harmonic curves.
% This is extravagant with memory - assumes length(freqs) * length(x) not
% too big. Could use less memory if necessary at cost of recomputing.
omegas = 2 * pi * freqs(:);
phi = bsxfun(@times, omegas, t);
h = [cos(phi); sin(phi)];

% Form normal equations and solve
A = h * h.';
v = h * x(:);

r = A \ v;

% reshape to put cos and sin components side by side
r = reshape(r, [], 2);
ap = r(:, 1);
bp = r(:, 2);

% change phase to allow for non-zero start time
c = cos(omegas * tstart);
s = sin(omegas * tstart);
a = c .* ap - s .* bp;
b = s .* ap + c .* bp;

end
