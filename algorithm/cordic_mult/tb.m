clc;
clear;
close all;

a_reg = zeros(1,1048576);
b_reg = zeros(1,1048576);
c_reg = zeros(1,1048576);
err_reg = zeros(1,1048576);

cntwhole = 1;
cnt1_range = 0:2^10-1;

for cnt1 = cnt1_range
    a = cnt1;
    for cnt2 = cnt1_range
        b = cnt2;
        c = cordic_float(a,b,20);
        c_real = a * b;

        err = abs(c_real - c);

        a_reg(cntwhole) = a;
        b_reg(cntwhole) = b;
        err_reg(cntwhole) = err;
        cntwhole = cntwhole + 1;
    end
end

figure;plot(err_reg);grid on;