x=[0:9]; 
ybp=[0.4798 0.4796 0.4786 0.4563 0.4627 0.4693 0.4788 0.4647 0.4844 0.4815];
yamp=[0.4756 0.4772 0.4725 0.4596 0.4784 0.4679 0.4809 0.4642 0.4791 0.4834];
yomp=[0.4638 0.4578 0.4637 0.4669 0.3805 0.4519 0.3685 0.4844 0.4891 0.4165];
bpavg=sum(ybp)/10;
ompavg=sum(yomp)/10;
ampavg=sum(yamp)/10;
bpavg=[bpavg bpavg bpavg bpavg bpavg bpavg bpavg bpavg bpavg bpavg];
ompavg=[ompavg ompavg ompavg ompavg ompavg ompavg ompavg ompavg ompavg ompavg];
ampavg=[ampavg ampavg ampavg ampavg ampavg ampavg ampavg ampavg ampavg ampavg];
plot(x,yomp,'r',x,ompavg,'r--',x,ybp,'g',x,bpavg,'g--',x,yamp,'b',x,ampavg,'b--'),title('error rate comparison'),xlabel('input'),ylabel('Error Rate'),
grid on,legend('OMP','OMP avg','BP','BP avg','AMP','BP avg')
