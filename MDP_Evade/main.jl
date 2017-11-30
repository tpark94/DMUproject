include("Evade.jl")
using .Evade

#Pkg.add("Reel")
using Reel
using POMDPToolbox
using POMDPs
using DiscreteValueIteration

mdp = EvadeMDP()
solver = ValueIterationSolver(max_iterations=100, belres=1e-3)
policy = solve(solver, mdp)

# make gif
frames = Frames(MIME("image/png"), fps=2)

print("Simulating and generating Pursue gif")
for (a, r, s) in stepthrough(mdp, policy, "a,r,s", max_steps = 50)
    push!(frames, EvadeVis(mdp, a, r, s))
    @printf("s: %-26s  a: %-6s\n", s, a)
end
println(" Done.")
write("out_evade.gif", frames)
