function cf = friction_coeff(x, v, a, rr, mm)
re = reynolds(x, v, rr, mm);
if is_laminar(re)
    cf = 1.328 / sqrt(re);
else
    m = v / a;
    cf = 0.455 / log10(re)^2.58 / (1 + 0.144 * m^2)^0.65;
end

function test = is_laminar(re)
if re < 5e5
    test = true;
else
    test = false;
end
