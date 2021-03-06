clear; clc

alg.datadir = '~/Research/data/sims/labeled/';
alg.figdir  = '~/Research/figs/sims/labeled/';
alg.fname   = 'kidney_egg';
alg.save    = 0;

load([alg.datadir alg.fname])                                      % loads adjacency_matrices, class_labels, algs, params, and misc.
constants = get_constants(adjacency_matrices,class_labels);     % get constants to ease classification code

alg.ind_edge           = true;
alg.signal_subgraph_ind= params.signal_subgraph_ind;               % use true signal subgraph
alg.nb_ind             = 1:params.n^2;                             % use naive bayes classifier
alg.num_inc_edges      = params.num_signal_edges;                  % use incoherent classifier with num_signal_vertices^2 edges
alg.num_coh_vertices   = params.num_signal_vertices;               % use coherent classifier with num_signal_vertices^2 edges
alg.num_signal_edges   = params.num_signal_edges;                  % # of signal edges

alg.knn             = false;
alg.knn_vanilla     = true;
alg.knn_lmnn        = false;
alg.knn_mmlmnn      = false;

alg.er              = false;

alg.num_splits      = 3;
alg.num_repeats     = 2;
alg.min_samples     = 2;
alg.max_samples     = min(constants.s0,constants.s1)-4;

%% test using in-sample training data
[Lhatin Lvarin Pin yhatin] = graph_classify_ER(adjacency_matrices,constants,alg); % compute in-sample classification accuracy
disp(Lhatin)

%% test using hold-out training data
[Lhats alg inds] = get_Lhat_hold_out(adjacency_matrices,class_labels,alg);

%% make plots

est_params  = get_params(adjacency_matrices,constants);         % estimate parameters from data
plot_params(est_params,alg,params)                              % plot params and estimated params
plot_recovered_subspaces(constants,est_params,alg)              % plot recovered subspaces 
plot_edge_identification_rates(inds,constants,alg)              % plot misclassification rates and edge detection rates
plot_Lhats(Lhats,alg)                                           % plot misclassification rates