__precompile__()

module Evade

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
#using DiscreteValueIteration

export
    Grid,
    EvadeState,
    EvadeMDP,
    states,

    EvadeVis

#####################################################
const Grid = SVector{2, Int64} # {col, row}

# State space -- agent position (xa, ya) & target position (xt, yt)
@auto_hash_equals immutable EvadeState
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
@with_kw immutable EvadeMDP <: MDP{EvadeState, Symbol}
    r_move::Float64    = -1.0 # reward for moving
    r_caught::Float64 = -100.0   # reward for capturing target
    discount::Float64  = 0.9 # gamma
    world::World       = World(15, 15)
    tp::Float64        = 0.5
end

ncols(mdp::EvadeMDP) = mdp.world.ncols
nrows(mdp::EvadeMDP) = mdp.world.nrows

# What's needed for MDP solver
include("states.jl")
include("actions.jl")
include("transition.jl")

function reward(mdp::EvadeMDP, s::EvadeState, a::Symbol, sp::EvadeState)

    if s.agent == s.target
        @assert sp.terminal
        return mdp.r_caught
    end

    if action_index(mdp, a) <= 4
        return mdp.r_move
    else
        return 0.
    end
end

isterminal(mdp::EvadeMDP, s::EvadeState) = s.terminal
discount(mdp::EvadeMDP) = mdp.discount

initial_state(mdp::EvadeMDP, rng::AbstractRNG) = EvadeState((1,2), (10,8), false)

include("EvadeVis.jl")

#######################################

end
