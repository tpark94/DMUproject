# Many parts of this implementation is inspired & taken from
# https://github.com/zsunberg/LaserTag.jl.git

# install the POMDPs.jl interface
# Pkg.clone("https://github.com/sisl/POMDPs.jl.git")
# Pkg.clone("https://github.com/JuliaArrays/StaticArrays.jl")

using POMDPs
using StaticArrays
using Parameters
using Distributions
using AutoHashEquals

const grid = SVector{2, Float64} # {col, row}

# State space -- agent position (xa, ya) & target position (xt, yt)
@auto_hash_equals immutable PursueState
    agent::grid
    target::grid
    caught::bool
end

# grid world
immutable world
    nrows::Int64
    ncols::Int64
end

# must see if agent is inside grid world
inside(w::world, c::grid) = 0 < c[1] <= w.n_cols && 0 < c[2] <= w.n_rows


# Action space
const ACTION_NAMES = SVector("up", "down", "right", "left", "catch")
const ACTION_DIRS  = SVector(Grid(0,1), Grid(0,-1), Grid(1,0), Grid(-1,0), Grid(0,0))

# MDP when target's KNOWN intention is to evade - agent pursues
@With_kw immutable PursueMDP <: MDP{PursueState, Symbol}
    r_move::Float64    = -0.1 # reward for moving
    r_capture::Float64 = 10   # reward for capturing target
    discount::Float64  = 0.95 # gamma
end

# transiton model distribution .....
immutable PursueTransDist
    caught::bool
    apos::grid
    tpos_prev::grid
    pd::SVector{5, Float64}
end
PursueTransDist(apos::Coord, tpos_prev::Coord, pd::AbstractVector) = PursueTransDist(false, apos, tpos_prev, pd)

# Target movement
function TargetMovement(rng::AbstractRNG, d::PursueTransDist)
    if d.caught
        return PursueState(d.apos, d.tpos_prev, true)
    end

    # update target position based on its transition model
    i = sample(rng, Weights(d.pd, 1.0))
    tpos = d.tpos_prev + ACTION_DIRS[i]

    return PursueState(d.apos, tpos, false)
end

# What's needed for MDP solver

# STATES (S)

# ACTION (A)
n_actions(mdp::PursueMDP) = 5;
actions(mdp::PursueMDP) = 1:n_actions(mdp);
function action_index(mdp::PursueMDP, a::Symbol)

# TRANSITION MODEL (T)
function transition(mdp::PursueMDP, s::PursueState, a::Int)
    d.pd = [0.2 0.2 0.2 0.2 0.2] # uniform when agent is pursuing


end
