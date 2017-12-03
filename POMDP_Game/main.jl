include("Game.jl")
using .Game

importall POMDPs

#Pkg.add("Reel")
using Reel
using POMDPToolbox
using POMDPs
using DiscreteValueIteration

pomdp = GamePOMDP()
solver = ValueIterationSolver(max_iterations=100, belres=1e-3)
policy = solve(solver, pomdp)

# make gif
frames = Frames(MIME("image/png"), fps=2)

print("Simulating and generating the gif")
for (a, r, s) in stepthrough(pomdp, policy, "a,r,s", max_steps = 150)
    push!(frames, GameVis(pomdp, a, r, s))
    @printf("s: %-26s  a: %-6s  r: %0.2f\n", s, a, r)
end
println(" Done.")
write("out_pomdp.gif", frames)
