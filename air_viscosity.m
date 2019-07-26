function mm = air_viscosity(t)
% Sutherland's formula (Crane, 1988)
% http://jullio.pe.kr/fluent6.1/help/html/ug/node294.htm

% Standard air
s = 110.56;
t0 = 273.11;
mm0 = 1.7894e-5;

mm = mm0 * (t / t0)^1.5 * (t0 + s) / (t + s);
