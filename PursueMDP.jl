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
npos(w::World) =(w.nrows * w.ncols) # num. of positions of an anget

# must see if agent is inside grid world
inside(w::World, c::Grid) = 0 < c[1] <= w.n_cols && 0 < c[2] <= w.n_rows

# Action space
const ACTION_NAMES = SVector("up", "down", "right", "left", "catch")
const ACTION_DIRS  = SVector(Grid(0,1), Grid(0,-1), Grid(1,0), Grid(-1,0), Grid(0,0))

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

###############################################
# What's needed for MDP solver

# STATES (S)
states(mdp::PursueMDP) = states(mdp.world)

function states(w::World)
    vec = Array{PursueState}(npos(w)^2+1)

    for i in 1:w.ncols, j in 1:w.nrows, k in 1:w.ncols, l in 1:w.nrows
        s = PursueState(Grid(i,j), Grid(k,l), false)
        vec[state_index(w, s)] = s
    end
    vec[end] = PursueState(Grid(1,1), Grid(1,1), true)
    return vec
end

state_index(mdp::PursueMDP, s::PursueState) = state_index(mdp.world, s)

function state_index(w::World, s::PursueState)
    r = w.nrows
    c = w.ncols
    if s.terminal
       return npos(w)^2 + 1
    else
       a = s.agent
       t = s.target
       return sub2ind((c,r,c,r), a[1], a[2], t[1], t[2])
    end
end

n_states(mdp::PursueState) = npos(mdp.world)^2 + 1

# ACTION (A)
n_actions(mdp::PursueMDP) = 5;
actions(mdp::PursueMDP) = 1:n_actions(mdp);
# function action_index(mdp::PursueMDP, a::Symbol)

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
