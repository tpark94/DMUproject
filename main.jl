include("Pursue.jl")
using .Pursue

#Pkg.add("Reel")
using Reel
using POMDPToolbox
using POMDPs
using DiscreteValueIteration

mdp = PursueMDP()
solver = ValueIterationSolver(max_iterations=100, belres=1e-3)
policy = solve(solver, mdp)

# make gif
frames = Frames(MIME("image/png"), fps=2)

print("Simulating and generating Pursue gif")
for (a, r, s) in stepthrough(mdp, policy, "a,r,s", max_steps = 150)
    push!(frames, PursueVis(mdp, a, r, s))
    @printf("s: %-26s  a: %-6s\n", s, a)
end
println(" Done.")
write("out_pursue.gif", frames)
