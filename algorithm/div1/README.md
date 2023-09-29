#### Division



long division的二进制版本。

N除以D,得到商Q和余数R:

```haskell
if D = 0 then error(DivisionByZeroException) end
Q := 0                  -- Initialize quotient and remainder to zero
R := 0                     
for i := n − 1 .. 0 do  -- Where n is number of bits in N
  R := R << 1           -- Left-shift R by 1 bit
  R(0) := N(i)          -- Set the least-significant bit of R equal to bit i of the numerator
  if R ≥ D then
    R := R − D
    Q(i) := 1
  end
end
```

改成Python实现：

```python
def long_division(N, D):
    if D == 0:
        raise ZeroDivisionError("Division by zero")
    
    Q = 0  # Initialize quotient to zero
    R = 0  # Initialize remainder to zero
    
    n = len(bin(N)) - 2  # Number of bits in N
    
    for i in range(n - 1, -1, -1):
        R <<= 1
        R |= (N >> i) & 1
        
        if R >= D:
            R -= D
            Q |= (1 << i)
    
    return Q, R

#test 
dividend = 560
divisor = 33
print("start")

quotient, remainder = long_division(dividend, divisor)
print(f"Quotient: {quotient}")
print(f"Remainder: {remainder}")
```

然后按照此步骤翻译成Verilog，加上对符号的判断，这样就改成了带符号的流水线除法器。






