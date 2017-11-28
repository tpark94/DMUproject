# STATES (S)
states(mdp::EvadeMDP) = states(mdp.world)

npos(w::World) = (w.nrows * w.ncols) # num. of positions of an anget

# possible states depending on agent & target's positions
function states(w::World)
    vec = Array{EvadeState}(npos(w)^2+1)

    for i in 1:w.ncols, j in 1:w.nrows, k in 1:w.ncols, l in 1:w.nrows
        s = EvadeState(Grid(i,j), Grid(k,l), false)
        vec[state_index(w, s)] = s
    end
    vec[end] = EvadeState(Grid(1,1), Grid(1,1), true)
    return vec
end

state_index(mdp::EvadeMDP, s::EvadeState) = state_index(mdp.world, s)

function state_index(w::World, s::EvadeState)
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

n_states(mdp::EvadeMDP) = npos(mdp.world)^2 + 1
