include("Game.jl")
using .Game

importall POMDPs

#Pkg.add("Reel")
using Reel
using POMDPToolbox
using POMDPs

# solver algorithm
using QMDP

#rng = MersenneTwister(7)
pomdp = GamePOMDP()
solver = QMDPSolver()
policy = solve(solver, pomdp)

# make gif
frames = Frames(MIME("image/png"), fps=2)

#ßrng = MensenneTwister(7)
print("Simulating and generating the gif")
for step in stepthrough(pomdp, policy, "a,r,sp,o,bp", max_steps=50)
    push!(frames, GameVis(pomdp, step...))
    print(".")
    #@printf("s: %-26s  a: %-6s  r: %0.2f  o: %6s\n", s, a, r, o)
end
println(" Done.")
write("out_pomdp.gif", frames)
