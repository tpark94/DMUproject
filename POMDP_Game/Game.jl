__precompile__()

module Game

# Many parts of this implementation is inspired & taken from
# https://github.com/zsunberg/LaserTag.jl.git

# install the POMDPs.jl interface
#=
Pkg.clone("https://github.com/sisl/POMDPs.jl.git")
Pkg.clone("https://github.com/JuliaArrays/StaticArrays.jl")
Pkg.add("Parameters")
Pkg.add("Distributions")
Pkg.add("AutoHashEquals")
Pkg.add("StatsBase")
=#

using StaticArrays
using Parameters
using Distributions
using AutoHashEquals
using StatsBase

importall POMDPs

export
    Grid,
    GameState,
    GamePOMDP,

    GameVis,
    BayesianUpdater,
    GameTypeBelief,
    pdf
#####################################################
const Grid = SVector{2, Int64} # {col, row}

# State space -- agent position (xa, ya) & target position (xt, yt)
@auto_hash_equals immutable GameState
    agent::Grid
    target::Grid
    gametype::Symbol
    terminal::Bool
end
# tar_intent of GameState is NOT target's true intention, but rather
# modeled based on a history of observations

# grid world
immutable World
    nrows::Int64
    ncols::Int64
end

# must see if agent is inside grid world
inside(w::World, c::Grid) = 0 < c[1] <= w.ncols && 0 < c[2] <= w.nrows

# POMDP{state, action, observation}
# @with_kw immutable GamePOMDP <: POMDP{GameState, Symbol, Symbol}
@with_kw immutable GamePOMDP <: POMDP{GameState, Symbol, Grid}
    r_move::Float64       = -1 # reward for moving
    r_capture::Float64    = 100.0   # reward for capturing target
    r_caught::Float64     = -100.0
    discount::Float64     = 0.9 # gamma
    world::World          = World(15, 15)
    true_gametype::Symbol = :pursue
    init_agent::Grid      = (1,2)
    init_target::Grid     = (10,8)
    tp::Float64           = 0.4 # governs transition probability of the target
end

ncols(pomdp::GamePOMDP) = pomdp.world.ncols
nrows(pomdp::GamePOMDP) = pomdp.world.nrows

isterminal(pomdp::GamePOMDP, s::GameState) = s.terminal
discount(pomdp::GamePOMDP) = pomdp.discount

###################################################
# What's needed for POMDP solver
include("states.jl")
include("actions.jl")
include("transition.jl")
include("observations.jl")

function reward(pomdp::GamePOMDP, s::GameState, a::Symbol, sp::GameState)

    if s.gametype == :pursue # pursue
        if s.agent == s.target
            @assert sp.terminal
            return pomdp.r_capture
        elseif action_index(pomdp, a) <= 4
            return pomdp.r_move
        else
            return 0.
        end
    else # evade
        if s.agent == s.target
            @assert sp.terminal
            return pomdp.r_caught
        end
        if action_index(pomdp, a) <= 4
            return pomdp.r_move
        else
            return 0.
        end
    end
end

include("updater.jl")
include("initial.jl")
include("GameVis.jl")

#######################################

end
