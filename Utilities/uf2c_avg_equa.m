function EquaString = uf2c_avg_equa(n)
%gera valores para a equa��o de template ou m�dias em geral no incalc
%colocar o numero de imagens   'n'
%o resultado ser� impresso na command window

b='i1';
for j=2:n
    a=sprintf('%s+i%d',b,j);
    b=a;
end
EquaString = sprintf('(%s)/%d',b,j);