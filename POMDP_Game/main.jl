include("Game.jl")
using .Game

#Pkg.add("Reel")
using Reel
using POMDPToolbox
using POMDPs
#using ParticleFilters

# solver algorithm
using QMDP
#using SARSOP
#using DiscreteValueIteration
importall POMDPs

using Plots

# define model & updater
pomdp = GamePOMDP()
updater = BayesianUpdater(pomdp)

#bmdp = GenerativeBeliefMDP(pomdp, updater)

print("Solve for policy")
solver = QMDPSolver()
#solver = SARSOPSolver()
policy = solve(solver, pomdp)


print("Simulate")
sim = HistoryRecorder(max_steps=100)
hist = simulate(sim, pomdp, policy, updater)

# If doing multiple simulations & saving rewards for each
#=
total_reward_vec = Array{Float64}(1000)
p_nocatch = 0
for ii in 1:1000
    println(ii)
    hist = simulate(sim, pomdp, policy, updater)
    r = 0
    for i in 1:length(hist)
        r += hist.reward_hist[i]
    end
    total_reward_vec[ii] = r

    if r < 0
        p_nocatch += 1
    end
end
writedlm("rewards_pursue_pomdp.txt",total_reward_vec)
=#

# make gif
frames = Frames(MIME("image/png"), fps=2)

print("Simulating and generating the gif")
for i = 1:length(hist)
    g = GameVis(pomdp, hist.action_hist[i], hist.reward_hist[i], hist.state_hist[i],
                    hist.observation_hist[i], hist.belief_hist[i])
    #g = GameVis(pomdp, hist.action_hist[i], hist.reward_hist[i], hist.state_hist[i])
    push!(frames, g)
    print(i)
end
println(" Done.")
write("out_pomdp.gif", frames)
