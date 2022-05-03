% Aircraft design tool
%
% Copyright (C) 2022 Mario Bras
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 3 as
% published by the Free Software Foundation.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
