function y = logIo(x)
% Returns the natural log of the 0th order modified Bessel function of first kind for an argument x
% Follows the exponential implementation of the Bessel function in Numerical Recipes, Ch. 6
%
% Translated to MATLAB from C++ from the FSL source code and vectorized for
% faster computations in MATLAB

b = abs(x);

% if b < 3.75
%     a = x/3.75;
%     a = a.^2;
%     % Bessel function evaluation
%     y = 1.0+a*(3.5156229+a*(3.0899424+a*(1.2067492+a*(0.2659732+a*(0.0360768+a*0.0045813)))));
%     y = log(y);
% else
%     a = 3.75/b;
%     %Bessel function evaluation
%       %y=(exp(b)/sqrt(b))*(0.39894228+a*(0.01328592+a*(0.00225319+a*(-0.00157565+a*(0.00916281+a*(-0.02057706+a*(0.02635537+a*(-0.01647633+a*0.00392377))))))));
%       %Logarithm of Bessel function
%       y=b+log((0.39894228+a*(0.01328592+a*(0.00225319+a*(-0.00157565+a*(0.00916281+a*(-0.02057706+a*(0.02635537+a*(-0.01647633+a*0.00392377))))))))/sqrt(b));
% end

y = zeros(size(x));

a1 = (x(b < 3.75)/3.75).^2;
a2 = 3.75./b(b >= 3.75);
y(b < 3.75) = log(1.0 + a1.*(3.5156229 + a1.*(3.0899424 + a1.*(1.2067492 + a1.*(0.2659732 + a1.*(0.0360768 + a1.*0.0045813))))));
y(b >= 3.75) = b(b >= 3.75) + log((0.39894228+a2.*(0.01328592+a2.*(0.00225319+a2.*(-0.00157565+a2.*(0.00916281+a2.*(-0.02057706+a2.*(0.02635537+a2.*(-0.01647633+a2.*0.00392377))))))))./sqrt(b(b>=3.75)));
