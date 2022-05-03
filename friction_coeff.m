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

function cf = friction_coeff(x, v, a, rr, mm)

if (v > 0)
    re = reynolds(x, v, rr, mm);
    if is_laminar(re)
        cf = 1.328 / sqrt(re);
    else
        m = v / a;
        cf = 0.455 / log10(re)^2.58 / (1 + 0.144 * m^2)^0.65;
    end
else
    cf = 0;
end

function test = is_laminar(re)
if re < 5e5
    test = true;
else
    test = false;
end
