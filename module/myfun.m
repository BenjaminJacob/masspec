function p=myfun(i1,i2,mu1,mu2,sig1,sig2)

%BSP 
%p=max(1-abs(mu1-mu2)/0.001,0);
p=(1-abs(mu1-mu2)/0.001 );

%Gives a linear decreasing score
%mu1-mu2=0 -> score=1
%mu1-mu2=1 -> score 0
%mu1-mu2>1 -> score 0