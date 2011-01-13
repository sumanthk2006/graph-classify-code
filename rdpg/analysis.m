% %% Pipeline as outlined below by Jovo (via e-mail) 
%
% 1) for each graph, compute the scaled sign positive graph laplacian of
% each graph (call it L_i).  one obtains this by filling in the diagonal of
% each adjacency matrix by the degree of that vertex, divided by n-1 (this
% is the expected weight of the self loop).
% 
% 2) compute an svd of L_i for all i.  look at the scree plots.
% presumably, a relatively small number of eigenvalues should suffice to
% capture most of the variance. 
% 
% 3) build a classifier using only the first d singular vectors.  we
% haven't really thought much about this, but svd implicitly assumes
% gaussian noise, so, the optimal classifier under this assumption is a
% discriminant classifier.  the code i have in the repo for discriminant
% classifiers is still in progress, but if you want to fix it up, that'd be
% fine.  report results for the discriminant classifiers (LDA and QDA, but
% with diagonal covariance matrices and whitened covariance matrices).
% 
% 4) cluster the singular vectors.  do this by initializing with a
% hierarchical clustering algorithm, and then use that to seed a k-means
% algorithm.  you can do this for a variety of values of k and d.  choose
% the one with the best BIC. marchette will send details for computing BIC
% values here, and for implementing the "k-means" algorithm, which is, in
% fact, more like a constrained finite gaussian mixture model algorithm.
% 
% 5) given a particular choice of k and d, build a classifier.  here, each
% class is a mixture of gaussians, so a naive discriminant classifier is
% insufficient.  instead, one can implement a bayes plugin classifier. so,
% given the fit of the mixture distributions for the two classes, compute
% whether a test graph is closer to class 0 or class 1 distribution.

%% Setup - Change to fit your desires

% this is just where i load stuff from my computer
%load /users/dsussman/documents/MATLAB/Brain_graphs/BLSA79_data.mat;
load /users/dsussman/documents/MATLAB/Brain_graphs/BLSA50_stripped.mat;
As_nan = zeros([size(data(1).A),length(data)]);
sz = size(As_nan);
As = As_nan;
for k=1:length(data) % replace all nan values with 0s
    As_nan(:,:,k) = data(k).A;
    for i=1:sz(1)
        for j=1:sz(2)
            if ~isnan(As_nan(i,j,k))
                As(i,j,k) = As_nan(i,j,k);
            end
        end
    end
end
As_nonSym = As;
targs = [data.y];
% you can set up stuff however you want here

% Symetrize the the adjacency matrix
for k = 1:length(data)
    As(:,:,k) = As(:,:,k)+As(:,:,k)';
end

%% Step 1 & 2 - Compute Laplacians and SVDs, make scree plots
Ls = graph_laplacian(As);

[Us, Ss, Vs] = graph_svd(Ls);
sz =  size(Ss);
singVals =  zeros(sz(1),sz(3)); % col vectors of singular vals
for k=1:sz(3)
    singVals(:,k) = diag(squeeze(Ss(:,:,k)));
end

% show scree plots of for all the graphs, red is targs is true blue is
% targs is false
figure(401);
hold all;
plot( singVals(:,targs==1), 'r');
plot( singVals(:,targs==0), 'b');

%% Classify using first d singular values
% needed to add the repo to the path

% n=length(targs);
% nNode = length(singVals);
% all_ind = struct('ytrn', 1:n,'y0trn', find(targs ==0), 'y1trn', find(targs == 1));
% ind = struct('ytrn', [],'y0trn', [],'y1trn', []);
% 
% discrim = struct('dLDA',1,'QDA',1);
% Lhat = struct('dLDA',cell(nNode-1-5,n),'QDA',cell(nNode-1-5,n));
% Lsem = Lhat;
% % remove each sample to do LOOCV
% for d=1:(nNode-1-5);
%     for k=1:n
%         ind.ytrn = all_ind.ytrn(all_ind.ytrn~=k);
%         ind.y0trn = all_ind.y0trn(all_ind.y0trn~=k);
%         ind.y1trn = all_ind.y1trn(all_ind.y1trn~=k);
%         
%         subspace = d;
%         params = get_discriminant_params(singVals(subspace,:),...
%                                             ind,discrim);
%         [Lhat(d,k) Lsem(d,k)] = discriminant_classifiers(singVals(subspace,k),targs(k),...
%                                                 params,discrim);
%     end
% end
% 
% 
% Lhat_dLda = mean(reshape([Lhat.dLDA],size(Lhat)),2);
% Lhat_Qda = mean(reshape([Lhat.QDA],size(Lhat)),2);
% 
% % plot Lhat vs which singular value
% figure(402); clf; plot(1:nNode-1-5,[Lhat_dLda,Lhat_Qda])
%% Estimate Latent Features

% size of the in and out latent features to be used
inSpace = [1:12,15,20,25,30,40];
outSpace = [1:12,15,20,25,30,40];
Lhat_dLda = zeros(length(inSpace),length(outSpace));
sz = size(As);
discrim = struct('dLDA',1);
for kIn=1:length(inSpace)
for kOut=1:length(outSpace)    
    
    % get the feature vectors
    dIn = inSpace(kIn);
    dOut = outSpace(kOut);
    [Lat_in,Lat_out] = estimate_latent_features_SVD(As,dIn,dOut);
    
    % do loocv using dLDA
    Lhat =  lda_loocv(...
        reshape([Lat_in,Lat_out],[(dIn+dOut)*sz(1),sz(3)]),targs,discrim);
    Lhat_dLda(kIn,kOut) = mean([Lhat.dLDA]);
        
%%%     [dIn,dOut]
%     subspaceIn = 1:dIn;
%     subspaceOut = 1:dOut;
%     Lat_out = Vs(:,subspaceOut,:);
%     Lat_in = Us(:,subspaceIn,:);
%     sz =  size(Us);
%     for k=1:sz(3)
%         Lat_out(:,:,k) = diag(singVals(:,k).^(.5))*Lat_out(:,:,k);
%         Lat_in(:,:,k)  = diag(singVals(:,k).^(.5))*Lat_in(:,:,k);
%     end
% 
%     features = reshape([Lat_in,Lat_out],[(dIn+dOut)*sz(1),sz(3)]);
%     n=length(targs);
%     all_ind = struct('ytrn', 1:n,'y0trn', find(targs ==0), 'y1trn', find(targs == 1));
%     ind = struct('ytrn', [],'y0trn', [],'y1trn', []);
% 
%     discrim = struct('dLDA',1);%,'QDA',1);
%     Lhat = struct('dLDA',cell(n,1));%,'QDA',1);
%     Lsem = Lhat;
% 
%     for k=1:n
%         ind.ytrn = all_ind.ytrn(all_ind.ytrn~=k);
%         ind.y0trn = all_ind.y0trn(all_ind.y0trn~=k);
%         ind.y1trn = all_ind.y1trn(all_ind.y1trn~=k);
% 
%         params = get_discriminant_params(features,ind,discrim);
%         [Lhat(k) Lsem(k)] = discriminant_classifiers(features(:,k),targs(k),...
%                                                 params,discrim);
%     end
% 
%     Lhat_dLda(dIn,dOut) = mean([Lhat.dLDA]);

end
end
