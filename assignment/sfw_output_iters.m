function [f,myp,x,iter]=sfw_output_iters(A,B,IMAX,x0)
%function [f,p,x,iter]=sfw(A,B,IMAX,x0)'
% Perform at most IMAX iterations of the Frank-Wolfe method to compute an
% approximate solution to the quadratic assignment problem given the
% matrices A and B. A and B should be square and the same size.  The method
% seeks a permutatation p which minimizes
%       f(p)=sum(sum(A.*B(p,p))).
% Convergence is declared if a fix point is encountered or if the projected
% gradient has 2-norm of 1.0e-4 or less.
% IMAX is optional with a default value of 30 iterations.
%     If IMAX is set to 0 then one iteration of FW is performed with no
%     line search.  This is Carey Priebe's LAP approximation to the QAP.
% The starting point is optional as well and its default value is
% ones(n)/n, the flat doubly stochastic matrix.
% x0 may also be
%   -1 which signifies a "random" starting point should be used.
%       here the start is given by
%       0.5*ones(n)/n+sink(rand(n),10)
%       where sink(rand(n),10) performs 10 iterations of Sinkhorn balancing
%       on a matrix whose entries are drawn from the uniform distribution
%       on [0,1].
%   x0 may also be a user specified n by n doubly stochastic matrix. 
%   x0 may be a permutation vector of size n.
% On output:
%     f=sum(sum(A.*B(p,p))), where
%     p is the permutation found by FW after projecting the interior point
%         to the boundary.
%     x is the doubly stochastic matrix (interior point) computed by the FW
%       method
%     iter is the number of iterations of FW performed.
%   
% Louis J. Podrazik circa 1996
% Modified by John M. Conroy, 1996-2010
%
% IDA Center for Computing Sciences
%  (c) 1996-2010, Institute for Defense Analyses, 4850 Mark Center Drive, Alexandria, Virginia, 22311-1882; 703-845-2500.
%
%     This material may be reproduced by or for the U.S. Government pursuant to the copyright license under the clauses at DFARS 252.227-7013 and 252.227-7014.
%
% joshuav vogelstein modified this code to store and output each iteration
% of the FW algorithm, so myp becomes a structure

[m,n]=size(A);
stype=2;
if ~exist('x0','var')% Use flat start
    x0=[1/m*ones(m^2,1);1/n*ones(n^2,1)];
elseif x0==-1 % Random start near center of space
    X=ones(m)/m;% Y=ones(n)/n;
    lam=0.5;
    X=(1-lam)*X+lam*sink(rand(size(X)),10);
    %X=(1-lam)*X+lam*perm2mat(randperm(m));
    Y=X;
    x0=[X(:);Y(:)];
elseif numel(x0)==size(A,1) %x0 is assumed to be a permutation.
    x0=perm2mat(x0)';
    x0=[x0(:);x0(:)];
elseif numel(x0)==numel(A)
    x0=[x0(:);x0(:)];
else
    x0=x0(:);
end
x=x0; 
if ~exist('IMAX','var') 
    IMAX=30; 
end;
stoptol=1.0e-4;

iter=1; stop=0;
while ( (iter <= IMAX+1) && (stop==0))
        % ---- fun+grad ------
    [f0,g] = fungrad(x,A,B);
    g=[g(1:n^2)+g(1+n^2:end);g(1:n^2)+g(1+n^2:end)]/2;
    
    % ---- projection ------
    %%%%%% JOVO ADDED "{iter}" TO THE BELOW LINE %%%%%%%%%%%%%%%%
    [d,myp{iter}] = dsproj(x,g,m,n);
    stopnorm = (d'*d)^0.5;
    %frintf(1,'i= %3d, ||pg||= %e, ||lpg||= %e \n',iter, stopnorm, (d'*d)^0.5 );
    
    % ---- stop rule ------
    if(stopnorm < stoptol ), stop=1; end;
    % ---- line search  ------
    %plotline( T,O, x,d,g,n,m,50);
    if IMAX>0
        [f0new, salpha] = lines(       stype, x,d,g,A,B);
    else
        salpha=1;  % Priebe's LAP approximation to a QAP
    end
    % [f0new, salpha] = toolboxlines(stype, T,O, x,d,g,n,m,scale);
    x = x + salpha*d;
    iter= iter+1;

    %%%%%% JOVO COMMENTED OUT THE BELOW LINE TO ENSURE WE ALWAYS HAVE THE SAME NUMBER OF FW ITERATIONS %%%%%%%%%%%%%%%%
    %     if salpha==0, stop=1; end
    %frintf(1,'Norm of error=%e.  Step length=%f\n ',norm(x-xs),salpha)
end;
% frintf(1,'\n');
% frintf(1,'\ndone\n');
%frintf(1,'\niter= %3d, cost= %3.2f, ||pg||= %e \n'  ,iter-1,f0,stopnorm);
%-----------------------------------------------------------------------

%%%%%%%% JOVO COMMENTED OUT THE BELOW LINES %%%%%%%%%%%%
% [P,Q]=unstack(x,m,n);
% if salpha~=1,
%     myp=assign(P,1);
% end
%%%%%%%% JOVO COMMENTED OUT THE ABOVE LINES %%%%%%%%%%%%

%%%%%%%% JOVO ADDED "{iter-1}" TO THE NEXT LINE %%%%%%%%%%%%
f=sum(sum(A.*B(myp{iter-1},myp{iter-1})));
% if sum(abs(P-Q)~=0)
%     error('Symmetry Error');
% end
