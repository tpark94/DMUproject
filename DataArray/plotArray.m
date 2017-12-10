clear all
close all

pursue = dlmread('vec.rtf');
evade4 = dlmread('vec2.rtf');

plot(pursue,'k-o','LineWidth',1.0)
hold on
plot(evade4,'k-.x','LineWidth',1.0)

l = legend('Pursue Scenario', 'Evade Scenario');
set(l,'FontSize',14);
xlabel('Steps','FontSize',16)
ylabel('Probability that agent pursues, \theta_p','FontSize',16)
grid on

%%%%%%%
% Beta example fig.
% X = 0:0.001:1;
% y11 = betapdf(X,1,1);
% y62 = betapdf(X,6,2);
% y26 = betapdf(X,2,6);
% plot(X,y11,'k-',X,y62,'k--',X,y26,'k-.','LineWidth',1.0)
% l = legend('Beta(1,1)' ,'Beta(6,2)' ,'Beta(2,6)');
% set(l,'FontSize',14);
% xlabel('\theta_p', 'FontSize',16)
% ylabel('P(\theta_p)', 'FontSize',16)