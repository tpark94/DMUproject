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
using MCTS

const Grid = SVector{2, Int64} # {col, row}

# State space -- agent position (xa, ya) & target position (xt, yt)
@auto_hash_equals immutable PursueState
    agent::Grid
    target::Grid
    terminal::bool
end

# grid world
immutable World
    nrows::Int64
    ncols::Int64
end
npos(w::World) = (w.nrows * w.ncols) # num. of positions of an anget

# must see if agent is inside grid world
inside(w::World, c::Grid) = 0 < c[1] <= w.n_cols && 0 < c[2] <= w.n_rows

# MDP when target's KNOWN intention is to evade - agent pursues
@With_kw immutable PursueMDP <: MDP{PursueState, Symbol}
    r_move::Float64    = -0.1 # reward for moving
    r_capture::Float64 = 10   # reward for capturing target
    discount::Float64  = 0.95 # gamma
    world::World       = World(15, 15)
end

#=
# transiton model distribution .....
immutable PursueTransDist
    terminal::bool
    apos::grid
    tpos_prev::grid
    pd::SVector{5, Float64}
end
PursueTransDist(apos::Coord, tpos_prev::Coord, pd::AbstractVector) = PursueTransDist(false, apos, tpos_prev, pd)

# returns random state after target moved
function rand(rng::AbstractRNG, d::PursueTransDist)
    if d.terminal
        return PursueState(d.apos, d.tpos_prev, true)
    end

    # update target position based on its transition model
    i = sample(rng, Weights(d.pd, 1.0))
    tpos = d.tpos_prev + ACTION_DIRS[i]

    return PursueState(d.apos, tpos, false)
end

# probability density function at state s
function pdf(d::PursueTransDist, s::PursueState)
    if d.terminal
        return s.terminal ? 1.0 : 0.0

=#



# What's needed for MDP solver

include("states.jl")
include("actions.jl")


#=
# TRANSITION MODEL (T)
function transition(mdp::PursueMDP, s::PursueState, a::Int)

    if s.terminal
        return PursueTransDist(true, s.agent, s.target, SVector{0., 0., 0., 0., 1.})
    end

    d = PursueTransDist(s.agent, s.target, )
    d.pd = [0.2 0.2 0.2 0.2 0.2] # uniform when agent is pursuing

end

=#
