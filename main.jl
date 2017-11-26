include("Pursue.jl")
using .Pursue

#Pkg.add("Reel")
using Reel
using POMDPToolbox
using POMDPs
using MCTS

mdp = PursueMDP()
solver = MCTSSolver(n_iterations=2000,
                    depth=50,
                    exploration_constant=20.0,
                    enable_tree_vis=true)

policy = solve(solver, mdp)

#=
# initial
s = PursueState((1,2), (7,8), false)
hist = HistoryRecorder(max_steps=1000)
hist = simulate(hist, mdp, policy, s)

for (s, a, sp) in eachstep(hist, "s,a,sp")
    @printf("s: %-26s  a: %-6s  s': %-26s\n", s, a, sp)
end
=#
frames = Frames(MIME("image/png"), fps=2)

print("Simulating and generating Pursue gif")
for step in stepthrough(mdp, policy, "a,r,s", max_steps = 1000)
    push!(frames, PursueVis(mdp, step...))
    print('.')
end
println(" Done.")
write("out.gif", frames)
