using TikzPictures

type GameVis
    m::GamePOMDP
    a::Nullable{Any}
    r::Nullable{Any}
    s::Nullable{Any}
    o::Nullable{Any}
    b::Nullable{Any}
end
GameVis(m; s=nothing, a=nothing, o=nothing, b=nothing, r=nothing) = GameVis(m, a, r, s, o, b)
GameVis(m::GamePOMDP, arsobp::Tuple) = GameVis(m, arsobp...)

Base.show(io::IO, mime::MIME"image/svg+xml", v::GameVis) = show(io, mime, tikz_pic(v))

#############################################
# Functions
function Base.show(io::IO, mime::MIME"image/png", v::GameVis)
    fname = tempname()
    save(PDF(fname), tikz_pic(v))
    run(`convert -flatten $(fname*".pdf") $(fname*".png")`)
    open(fname*".png") do f
        write(io, readstring(f))
    end
    run(`rm $(fname*".pdf")`)
    run(`rm $(fname*".png")`)
    return io
end

function fill_square(o::IO, x, y, color, opacity=0.5) # maybe opacity should be a keyword
    sqsize = 1.0
    println(o, "\\fill[$(color), opacity=$opacity] ($((x-1) * sqsize),$((y-1) * sqsize)) rectangle +($sqsize,$sqsize);")
end

function tikz_pic(v::GameVis)
    m = v.m
    w = m.world
    o = IOBuffer()
    sqsize=1

    println(o, "\\begin{scope}")

    println(o, "\\clip (0,0) rectangle ($(w.ncols*sqsize),$(w.nrows*sqsize));")

    if !isnull(v.s)
        s = get(v.s)
        target = s.target
        agent = s.agent
        fill_square(o, target[1], target[2], "orange")
        fill_square(o, agent[1], agent[2], "green")

        if !isnull(v.a)
            aname = ACTION_NAMES[action_index(m, get(v.a))]
            println(o, "\\node[above right] at ($((agent[1]-1) * sqsize), $((agent[2]-1) * sqsize)) {$aname};")
        end
        if !isnull(v.r)
            rtext = @sprintf("%0.2f", get(v.r))
            println(o, "\\node[below right] at ($((agent[1]-1) * sqsize), $((agent[2]-1) * sqsize)) {$rtext};")
        end

    end

    # # possibly for later: text in a square
    # vs = @sprintf("%0.2f", V[i])
    # println(o, "\\node[above right] at ($((xval-1) * sqsize), $((yval-1) * sqsize)) {\$$(vs)\$};")

    println(o, "\\draw[black] grid($(w.ncols), $(w.nrows));")

    println(o, "\\end{scope}")

    tikzDeleteIntermediate(true)
    return TikzPicture(String(take!(o)), options="scale=1.25")
end

function Base.show(io::IO, mime::MIME"text/plain", v::GameVis)
    for y in nrows(v.m):-1:1
        for x in 1:ncols(v.m)
            printed = false
            if !isnull(v.s)
                s = get(v.s)
                if Grid(x,y) == s.agent
                    print(io, 'A')
                    printed = true
                elseif Grid(x,y) == s.target
                    print(io, 'O')
                    printed = true
                end
            end
            if !printed
                print(io, '.')
            end
        end
        print(io, '\n')
    end
end
