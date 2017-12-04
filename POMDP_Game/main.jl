include("Game.jl")
using .Game

#Pkg.add("Reel")
using Reel
using POMDPToolbox
using POMDPs

# solver algorithm
#using SARSOP
using QMDP
importall POMDPs

print("Solve for policy")
pomdp = GamePOMDP()
#solver = SARSOPSolver()
solver = QMDPSolver()
policy = solve(solver, pomdp)

init_dist = initial_state_distribution(pomdp)
up = updater(policy)

print("Simulate")
sim = HistoryRecorder(max_steps=50, rng=MersenneTwister(7))
hist = simulate(sim,pomdp,policy,up,init_dist)

# make gif
#frames = Frames(MIME("image/png"), fps=2)

#rng = MensenneTwister(7)
#print("Simulating and generating the gif")
#=
for step in stepthrough(pomdp, policy, "a,r,sp,o,bp", max_steps=50)
    push!(frames, GameVis(pomdp, step...))
    print(".")
    #@printf("s: %-26s  a: %-6s  r: %0.2f  o: %6s\n", s, a, r, o)
end
println(" Done.")
write("out_pomdp.gif", frames)
=#
