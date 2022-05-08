
%The variable indicates what method is to be used
Type=['standard'];
Type=['scaling'];

%zero mean normally distributed random data 
X=randn(100,2);
%Assign different mean and standard deviation for both variables   
X(:,1)=0.5*X(:,1)+2
X(:,2)=1*X(:,2)+2
%This function normalizes each column of an array  using the standard score or feature scaling.
Y = StatisticalNormaliz(X,Type);
% plot data 
plot(X(:,1),X(:,2),'o')
hold on
plot(Y(:,1),Y(:,2),'or')
hold off
legend('Regular Data', 'Normalized Data')



