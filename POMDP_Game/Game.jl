__precompile__()

module Pursue

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
    PursueState,
    PursueMDP,

    PursueVis

#####################################################
const Grid = SVector{2, Int64} # {col, row}

# State space -- agent position (xa, ya) & target position (xt, yt)
@auto_hash_equals immutable GameState
    agent::Grid
    target::Grid
    intention::Bool # true - pursue, false - evade
    terminal::Bool
end

# grid world
immutable World
    nrows::Int64
    ncols::Int64
end

# must see if agent is inside grid world
inside(w::World, c::Grid) = 0 < c[1] <= w.ncols && 0 < c[2] <= w.nrows

# POMDP{state, action, observation}
@with_kw immutable GamePOMDP <: POMDP{GameState, Symbol}
    r_move::Float64    = -0.1 # reward for moving
    r_capture::Float64 = 100.0   # reward for capturing target
    r_caught::Float64  = -100.0
    discount::Float64  = 0.95 # gamma
    world::World       = World(15, 15)
end


ncols(pomdp::GamePOMDP) = pomdp.world.ncols
nrows(pomdp::GamePOMDP) = pomdp.world.nrows

isterminal(podp::GamePOMDP, s::GameState) = s.terminal
discount(pomdp::GamePOMDP) = pomdp.discount

###################################################
# What's needed for POMDP solver
include("states.jl")
include("actions.jl")
include("transition.jl")

function reward(pomdp::GamePOMDP, s::GameState, a::Symbol, sp::GameState)

    if a==:stay && s.agent == s.target
        @assert sp.terminal
        return pomdp.r_capture
    elseif action_index(mdp, a) <= 4
        return pomdp.r_move
    else
        return 0.
    end
end

initial_state(pomdp::GamePOMDP, rng::AbstractRNG) = GameState((1,2), (10,8), false)

include("GameVis.jl")

#######################################

end
