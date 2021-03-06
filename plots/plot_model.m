function plot_model(params,alg)
%% plot params

figure(1), clf
fs=10;
w=0.3;
h=0.3;
s=(1-3*w)/15;


emax=max(max([params.E0(:) params.E1(:) abs(params.E0(:)-params.E1(:))]));

% subplot('Position',[s .1 w h])
subplot(131)
image(64*params.E0/emax)
colormap('gray')
title('class 0 mean','fontsize',fs)
xlabel('vertices','fontsize',fs)
ylabel('vertices','fontsize',fs)
set(gca,'fontsize',fs,'DataAspectRatio',[1 1 1])

% subplot('Position',[2*s+w .1 w h])
subplot(132)
image(64*params.E1/emax)
title('class 1 mean','fontsize',fs)
set(gca,'fontsize',fs)
set(gca,'fontsize',fs,'DataAspectRatio',[1 1 1])
% colorbar('Position',[.01 .3 .02 .4],'YTick',linspace(0,64,5),'YTickLabel',linspace(0,100,5),'fontsize',fs)

% subplot('Position',[4*s+2*w .1 w h])
subplot(133)
imagesc((params.E0-params.E1))
colormap('gray')
title('difference','fontsize',fs)
set(gca,'fontsize',fs)
set(gca,'fontsize',fs,'DataAspectRatio',[1 1 1])


if alg.save
    wh=[6 2];   %width and height
    set(gcf,'PaperSize',wh,'PaperPosition',[0 0 wh],'Color','w');
    figname=[alg.figdir alg.fname '_params'];
    print('-dpdf',figname)
    print('-deps',figname)
    saveas(gcf,figname)
end

