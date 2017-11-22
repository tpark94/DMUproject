const ACTION_DIR = SVector(Grid(0,1), Grid(0,-1), Grid(1,0), Grid(-1,0), Grid(0,0))

# ACTION (A)
n_actions(mdp::PursueMDP) = 5;
actions(mdp::PursueMDP) = [:up, :down, :right, :left, :catch];
function action_index(mdp::PursueMDP, a::Symbol)

    if a == :up
        return 1
    elseif a == :down
        return 2
    elseif a == :right
        return 3
    elseif a == :left
        return 4
    else
        return 5
    end
end
