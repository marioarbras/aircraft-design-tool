% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function mm = air_viscosity(t)
% Sutherland's formula (Crane, 1988)
% https://www.grc.nasa.gov/www/k-12/airplane/viscosity.html
% https://www.afs.enea.it/project/neptunius/docs/fluent/html/ug/node294.htm
% https://doc.comsol.com/5.5/doc/com.comsol.help.cfd/cfd_ug_fluidflow_high_mach.08.27.html

% Standard air
s = 110.56;
t0 = 273.11;
mm0 = 1.716e-5;

mm = mm0 * (t / t0)^1.5 * (t0 + s) / (t + s);
