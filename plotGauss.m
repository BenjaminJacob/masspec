

[numd txtd]=xlsread('sample_A_0.0ppm.xlsx');

mus=numd(:,1);
Is=numd(:,2);
reses=numd(:,3);

sigs=1/sqrt(log(4))*mus./reses;



sigs=1/sqrt(log(4))*mu_data/data(i,res);
figure
hold on
for i=1:length(numd)
x=(mus(i)-5*sigs(i)):0.0001:(mus(i)+5*sigs(i));
y=Is(i)*1./(sigs(i)*sqrt(2*pi))*exp(-0.5*( ((x-mus(i)))/sigs(i)).^2);

if Is(i)~=314159
   plot(x,y)
else
    plot(x,y,'r')
end

end

1./(sig*sqrt(2*pi))*exp(-0.5*( ((x-mus))/sig).^2)