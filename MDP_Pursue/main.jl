include("Pursue.jl")
using .Pursue

#Pkg.add("Reel")
using Reel
using POMDPToolbox
using POMDPs
using DiscreteValueIteration
#using MCTS

mdp = PursueMDP()
solver = ValueIterationSolver(max_iterations=100, belres=1e-3)
#solver = MCTSSolver(n_iterations=100, depth=150, exploration_constant=10.0)
policy = solve(solver, mdp)

print("Simulate")
sim = HistoryRecorder(max_steps=100, show_progress=true)
total_reward_vec = Array{Float64}(1000)
for ii in 1:1000
    println(ii)
    hist = simulate(sim, mdp, policy)
    r = 0
    for i in 1:length(hist)
        r += hist.reward_hist[i]
    end
    total_reward_vec[ii] = r
end

# make gif
frames = Frames(MIME("image/png"), fps=2)

print("Simulating and generating Pursue gif")
for i = 1:length(hist)
    g = PursueVis(mdp, hist.action_hist[i], hist.reward_hist[i], hist.state_hist[i])
    push!(frames, g)
    println(i)
end
println(" Done.")
write("out_pursue.gif", frames)

v = 0
for s in states(mdp)
  v += value(policy, s)
end
println("sum of values = ", v)
