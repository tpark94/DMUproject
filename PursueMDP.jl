__precompile__()

# Many parts of this implementation is inspired & taken from
# https://github.com/zsunberg/LaserTag.jl.git

# install the POMDPs.jl interface
#Pkg.clone("https://github.com/sisl/POMDPs.jl.git")
#Pkg.clone("https://github.com/JuliaArrays/StaticArrays.jl")
#Pkg.add("Parameters")
#Pkg.add("Distributions")
#Pkg.add("AutoHashEquals")
#Pkg.add("StatsBase")

using StaticArrays
using Parameters
using Distributions
using AutoHashEquals
using StatsBase
using POMDPToolbox

importall POMDPs

#POMDPs.add("MCTS")
#POMDPs.add("DiscreteValueIteration")
using MCTS
#using DiscreteValueIteration

const Grid = SVector{2, Int64} # {col, row}

# State space -- agent position (xa, ya) & target position (xt, yt)
@auto_hash_equals immutable PursueState
    agent::Grid
    target::Grid
    terminal::Bool
end

# grid world
immutable World
    nrows::Int64
    ncols::Int64
end

# must see if agent is inside grid world
inside(w::World, c::Grid) = 0 < c[1] <= w.ncols && 0 < c[2] <= w.nrows

# MDP when target's KNOWN intention is to evade - agent pursues
@with_kw immutable PursueMDP <: MDP{PursueState, Symbol}
    r_move::Float64    = -0.1 # reward for moving
    r_capture::Float64 = 100   # reward for capturing target
    discount::Float64  = 0.95 # gamma
    world::World       = World(15, 15)
end

isterminal(mdp::PursueMDP, s::PursueState) = s.terminal
discount(mdp::PursueMDP) = mdp.discount

# What's needed for MDP solver
include("states.jl")
include("actions.jl")
include("transition.jl")

function reward(mdp::PursueMDP, s::PursueState, a::Symbol, sp::PursueState)

    if a == :catch && s.agent == s.target
        return mdp.r_capture
    elseif a == :catch && s.agent != s.target
        return 0
    else
        if action_index(mdp, a) <= 4
            return 0
        end
    end
end


#######################################
mdp = PursueMDP()

#=
solver = ValueIterationSolver(max_iterations=100, belres=1e-3)
policy = ValueIterationPolicy(mdp)
solve(solver, mdp, policy, verbose=true)
=#
solver = MCTSSolver(n_iterations=1000,
                    depth=20,
                    exploration_constant=10.0,
                    enable_tree_vis=true)

planner = solve(solver, mdp)

# initial
s = PursueState((1,2), (7,8), false)

hist = HistoryRecorder(max_steps=1000)

hist = simulate(hist, mdp, planner, s)

for (s, a, sp) in eachstep(hist, "s,a,sp")
    @printf("s: %-26s  a: %-6s  s': %-26s\n", s, a, sp)
end
