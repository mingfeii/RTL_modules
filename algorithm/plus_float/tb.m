clear;
close all;
clc;

% a : 3 位整数，4位小数，无符号
% b : 2 位整数，3位小数，无符号
% c : 限定 3位整数，1位小数，无符号（要求四舍五入输出），位宽共4位

cntwhole = 1;

for cnt1 = 0:2^-4:8-2^-4
    a = cnt1;

    for cnt2 = 0:2^-3:4-2^-3
        b = cnt2;
        c = plus_float(a,b);

        c_real = a + b;

        if c_real > 8 - 2^-1 % 1位小数,限制了最大值，其余是全精度的
            c_real = 8 - 2^-1;
        end 

        err = abs(c_real - c);

        a_group(cntwhole) = a;
        b_group(cntwhole) = b;
        c_group(cntwhole) = c;
        c_real_group(cntwhole) = c_real;
        err_group(cntwhole) = err;
        cntwhole = cntwhole + 1;
    end 
end 

figure;plot(err_group);grid on;
