include("Game.jl")
using .Game

#Pkg.add("Reel")
using Reel
using POMDPToolbox
using POMDPs
#using ParticleFilters

# solver algorithm
using QMDP
importall POMDPs

print("Solve for policy")
rng = MersenneTwister(7)
pomdp = GamePOMDP()
solver = QMDPSolver(max_iterations=1000, tolerance=1e-5)
policy = solve(solver, pomdp)

print("Define Updater")
updater = BayesianUpdater(pomdp)

print("Simulate")
sim = HistoryRecorder(max_steps=100, rng=rng, show_progress=true)
hist = simulate(sim, pomdp, policy, updater)

# make gif
frames = Frames(MIME("image/png"), fps=2)

print("Simulating and generating the gif")
for i = 1:length(hist)
    g = GameVis(pomdp, hist.action_hist[i], hist.reward_hist[i], hist.state_hist[i],
                    hist.observation_hist[i], hist.belief_hist[i])
    push!(frames, g)
    print(i)
end
println(" Done.")
write("out_pomdp.gif", frames)
