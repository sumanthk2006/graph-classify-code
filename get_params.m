function P = get_params(adjacency_matrices,constants)

% NOTE THAT THIS IS A HACK AND WE WILL MODIFY TO USE DIRICHLET PRIOR
eps = 1/200;                        % to deal with 0's and 1's 

% deltahat
P.E0    = mean(adjacency_matrices(:,:,constants.y0),3);     % P[A | Y=0]
P.E0(P.E0==0) = eps;
P.E0(P.E0==1) = 1-eps;

P.E1    = mean(adjacency_matrices(:,:,constants.y1),3);     % P[A | Y=1]
P.E1(P.E1==0) = eps;
P.E1(P.E1==1) = 1-eps;

P.d_pos = abs(P.E0-P.E1);           % position difference
P.d_opt = abs(P.E0./(P.E0.*(1-P.E0)) - P.E1./(P.E1.*(1-P.E1))); % optimal difference

% pre-compute constants for bernoulli distribution
P.lnE0  = log(P.E0);
P.ln1E0 = log(1-P.E0);
P.lnE1  = log(P.E1);
P.ln1E1 = log(1-P.E1);

% log-priors
P.lnprior0 = log(constants.s0/constants.s);
P.lmprior1 = log(constants.s1/constants.s);