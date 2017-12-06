include("Game.jl")
using .Game

#Pkg.add("Reel")
using Reel
using POMDPToolbox
using POMDPs

# solver algorithm
#using SARSOP
#POMDPs.add("QMDP")
using QMDP
importall POMDPs

print("Solve for policy")
rng = MersenneTwister(7)
pomdp = GamePOMDP()
#solver = SARSOPSolver()
solver = QMDPSolver()
policy = solve(solver, pomdp)

print("Define Updater")
updater = BayesianUpdater(pomdp)


print("Simulate")
sim = HistoryRecorder(max_steps=50, rng=rng, show_progress=true)
hist = simulate(sim, pomdp, policy, updater)


#
# make gif
frames = Frames(MIME("image/png"), fps=2)

print("Simulating and generating the gif")
for step in stepthrough(pomdp, policy, updater, "a,r,sp,o,bp", max_steps=50)
    push!(frames, GameVis(pomdp, step...))
    print(".")
    #@printf("s: %-26s  a: %-6s  r: %0.2f  o: %6s\n", s, a, r, o)
end
println(" Done.")
write("out_pomdp.gif", frames)
