__precompile__()

# Many parts of this implementation is inspired & taken from
# https://github.com/zsunberg/LaserTag.jl.git

# install the POMDPs.jl interface
#Pkg.clone("https://github.com/sisl/POMDPs.jl.git")
#Pkg.clone("https://github.com/JuliaArrays/StaticArrays.jl")
#Pkg.add("Parameters")
#Pkg.add("Distributions")
#Pkg.add("AutoHashEquals")

using POMDPs, POMDPToolbox
using StaticArrays
using Parameters
using Distributions
using AutoHashEquals

#POMDPs.add("MCTS")
#POMDPs.add("DiscreteValueIteration")
using DiscreteValueIteration

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
inside(w::World, c::Grid) = 0 < c[1] <= w.n_cols && 0 < c[2] <= w.n_rows

# MDP when target's KNOWN intention is to evade - agent pursues
@with_kw immutable PursueMDP <: MDP{PursueState, Symbol}
    r_move::Float64    = -0.1 # reward for moving
    r_capture::Float64 = 10   # reward for capturing target
    discount::Float64  = 0.95 # gamma
    world::World       = World(15, 15)
end

# What's needed for MDP solver
include("states.jl")
include("actions.jl")
