function c = div_float(a,b,itr)

    if ((a >= 0) && (b >= 0)) || ((a < 0) && (b < 0))
        sign_flag = 0;
    else 
        sign_flag = 1;
    end 

%限定分子范围在[1,2)
    if (a >= 0)
        a = a;
    else 
        a = -a;
    end 

    a_shift_bit = 0;
    if a ~= 0
        a_inner = a;
        while((a_inner >= 2) || (a_inner < 1))
            if a_inner >= 2
                a_inner = floor(a_inner / 2)
                a_shift_bit = a_shift_bit + 1;
            else % a_inner < 1
                a_inner = a_inner * 2;
                a_shift_bit = a_shift_bit - 1;
            end 
        end 
        a = a / 2^a_shift_bit;
    end

%限定分母范围在[1,2)
    if (b >= 0)
        b = b;
    else 
        b = -b;
    end 

    b_shift_bit = 0;
    if b ~= 0
        b_inner = b;
        while((b_inner >= 2) || (b_inner < 1))
            if (b_inner >= 2)
                b_inner = floor(b_inner / 2);
                b_shift_bit = b_shift_bit + 1;
            else %b_inner < 1
                b_inner = b_inner * 2;
                b_shift_bit = b_shift_bit - 1;
            end 
        end 
        b = b / 2^b_shift_bit;
    end 

% 迭代处理
for cnt = 0:itr - 1
    f = 2 - b;
    a = a * f;
    b = b * f; %让b不断接近1
end 


%补完处理
if b ~= 0
    c = a * 2^(a_shift_bit - b_shift_bit)
    if (sign_flag == 0)
        c = c;
    else 
        c = -c;
    end 

else % b == 0
    if (a == 0)
        c = 0;
    else % a~=0
        if (sign_flag == 0)
            c = 256 - 2^7;
        else 
            c = -256;
        end 
    end 
end 