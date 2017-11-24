using PursueMDP

mdp = PursueMDP()

#=
solver = ValueIterationSolver(max_iterations=100, belres=1e-3)
policy = ValueIterationPolicy(mdp)
solve(solver, mdp, policy, verbose=true)
=#
solver = MCTSSolver(n_iterations=2000,
                    depth=50,
                    exploration_constant=20.0,
                    enable_tree_vis=true)

planner = solve(solver, mdp)

# initial
s = PursueState((1,2), (7,8), false)

hist = HistoryRecorder(max_steps=1000)

hist = simulate(hist, mdp, planner, s)

for (s, a, sp) in eachstep(hist, "s,a,sp")
    @printf("s: %-26s  a: %-6s  s': %-26s\n", s, a, sp)
end
