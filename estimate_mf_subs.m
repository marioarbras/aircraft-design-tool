% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function mf_subs = estimate_mf_subs(mf_prop, mf_struct)

mf_subs = 3 / 7 * (mf_prop + mf_struct);
