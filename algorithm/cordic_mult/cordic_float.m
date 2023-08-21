function c = cordic_float(a,b,itr)

b_inner  = b;
b_shift_bit = 0;
while(b_inner > 1)
    b_inner = floor(b_inner / 2);
    b_shift_bit = b_shift_bit + 1;
end 

b = b / 2^b_shift_bit;

%% cordic muti
c = 0;
for cnt=0:itr-1
    tmp = 2^(-cnt);
    
    if b  >= 0
        c = c + 2^(-cnt) * a;
        b = b - tmp;
    else 
        c = c - 2^(-cnt) * a;
        b = b + tmp;
    end
end

c = floor(c * 2^b_shift_bit);


end