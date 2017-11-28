const ACTION_DIR = SVector(Grid(0,1), Grid(1,0), Grid(0,-1), Grid(-1,0), Grid(0,0))
const ACTION_NAMES = SVector("UP", "RIGHT", "DOWN", "LEFT", "STAY")

# ACTION (A)
n_actions(mdp::EvadeMDP) = 5;
actions(mdp::EvadeMDP) = [:up, :right, :down, :left, :stay];
function action_index(mdp::EvadeMDP, a::Symbol)

    if a == :up
        return 1
    elseif a == :right
        return 2
    elseif a == :down
        return 3
    elseif a == :left
        return 4
    elseif a == :stay
        return 5
    end
end
