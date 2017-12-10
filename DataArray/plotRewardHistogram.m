clear all
close all

pomdp_r_pursue = dlmread('rewards_pursue_pomdp.txt');
mdp_r_pursue = dlmread('rewards_pursue_mdp.txt');

r_pomdp_p = sum(pomdp_r_pursue)/1000;
r_mdp_p   = sum(mdp_r_pursue)/1000;

mdp_r_evade = dlmread('rewards_evade_mdp.txt');
mdp_r_evade_5 = dlmread('rewards_evade_mdp_5.txt');
pomdp_r_evade = dlmread('rewards_evade_pomdp.txt');
pomdp_r_evade_5 = dlmread('rewards_evade_pomdp_5.txt');


r_mdp_e = sum(mdp_r_evade)/1000;
r_mdp_e_5 = sum(mdp_r_evade_5)/1000;
r_pomdp_e_4 = sum(pomdp_r_evade)/1000;
r_pomdp_e_5 = sum(pomdp_r_evade_5)/1000;


