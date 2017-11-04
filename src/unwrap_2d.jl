struct UnwrapParameters
    x_connectivity::Bool
    y_connectivity::Bool
end

mutable struct Pixel{T}
    periods::Int
    val::T
    reliability::Float64
    id_group::Int
    id_newgroup::Int
    group::Vector{Pixel{T}}
    Pixel{T}(periods, val, rel, id_group, id_newgroup) where T = (
            p = new(periods, val, rel, id_group, id_newgroup);
            p.group = [p];
            p
        )
end
Pixel(v) = Pixel{typeof(v)}(0, v, rand(), 0, -1)


mutable struct Edge{T}
    reliability::Float64
    pixel_1::Pixel{T}
    pixel_2::Pixel{T}
    periods::Int
end
Edge(g1, g2) = Edge(g1.reliability + g2.reliability,
                    g1,
                    g2,
                    find_period(g1.val, g2.val))
Base.isless(e1::Edge, e2::Edge) = isless(e1.reliability, e2.reliability)

function unwrap!(wrapped_image::AbstractMatrix,
                 wrap_around::NTuple{2, Bool}=(false, false),
                 seed::Int=-1)

    if seed != -1
        srand(seed)
    end

    mod = 2 * convert(eltype(wrapped_image), π)
    params = UnwrapParameters(wrap_around[1], wrap_around[2])
    # image is transferred to array of tuple (pixel, pixel_list)
    pixel_image = broadcast(init_pixels, wrapped_image)
    calculate_reliability(pixel_image, params)
    edges = Edge{eltype(wrapped_image)}[]
    populate_horizontal_edges!(edges, pixel_image, params)
    populate_vertical_edges!(edges, pixel_image, params)

    sort!(edges)

    gather_pixels!(edges, params)

    unwrap_image!(wrapped_image, pixel_image)

    return wrapped_image
end

# function to broadcast
function init_pixels(pixel_value)
    p = Pixel(pixel_value)
    p
end

# calculate the reliability of the pixels
function calculate_reliability(pixel_image, params)
    # get the shifted pixel indices in CartesinanIndex form
    pixel_shifts = CartesianIndex.(((0, -1), (0, 1), (1, 0), (-1, 0)))
    size_y, size_x = size(pixel_image)
    # inner loop
    for i in CartesianRange(CartesianIndex(2, 2), CartesianIndex(size_y-1, size_x-1))
        pixel_image[i].reliability = calculate_pixel_reliability(pixel_image, i, pixel_shifts)
    end

    if params.x_connectivity
        # left border
        pixel_shifts = CartesianIndex.(((0, size_x-1), (0, 1), (1, 0), (-1, 0)))
        for i in CartesianRange(CartesianIndex(2, 1), CartesianIndex(size_y-1, 1))
            pixel_image[i].reliability = calculate_pixel_reliability(pixel_image, i, pixel_shifts)
        end
        # right border
        pixel_shifts = CartesianIndex.(((0, -1), (0, -size_x+1), (1, 0), (-1, 0)))
        for i in CartesianRange(CartesianIndex(2, size_x), CartesianIndex(size_y-1, size_x))
            pixel_image[i].reliability = calculate_pixel_reliability(pixel_image, i, pixel_shifts)
        end
    end
    if params.y_connectivity
        # top border
        pixel_shifts = CartesianIndex.(((0, -1), (0, 1), (-size_y+1, 0), (-1, 0)))
        for i in CartesianRange(CartesianIndex(size_y, 2), CartesianIndex(size_y, size_x-1))
            pixel_image[i].reliability = calculate_pixel_reliability(pixel_image, i, pixel_shifts)
        end
        # bottom border
        pixel_shifts = CartesianIndex.(((0, -1), (0, 1), (1, 0), (size_y-1, 0)))
        for i in CartesianRange(CartesianIndex(1, 2), CartesianIndex(1, size_x-1))
            pixel_image[i].reliability = calculate_pixel_reliability(pixel_image, i, pixel_shifts)
        end
    end
end

function calculate_pixel_reliability(pixel_image, pixel_index, pixel_shifts)
    H = wrap_val(pixel_image[pixel_index+pixel_shifts[1]].val - pixel_image[pixel_index].val)
    V = wrap_val(pixel_image[pixel_index+pixel_shifts[2]].val - pixel_image[pixel_index].val)
    D1 = wrap_val(pixel_image[pixel_index+pixel_shifts[3]].val - pixel_image[pixel_index].val)
    D2 = wrap_val(pixel_image[pixel_index+pixel_shifts[4]].val - pixel_image[pixel_index].val)
    return H*H + V*V + D1*D1 + D2*D2
end

# calculate reliability of horizontal edges
function populate_horizontal_edges!(edges, pixel_image, params)
    size_y, size_x = size(pixel_image)
    edge_horizontal_domain = (size_y, size_x-1)
    for i in CartesianRange(edge_horizontal_domain)
        push!(edges, Edge(pixel_image[i],
                          pixel_image[i+CartesianIndex(0,1)]
                         ))
    end
    if params.x_connectivity
        for i in CartesianRange(CartesianIndex(1,size_x), CartesianIndex(size_y,size_x))
            push!(edges, Edge(pixel_image[i],
                              pixel_image[i+CartesianIndex(0,-size_x+1)]
                             ))
        end
    end
end

function populate_vertical_edges!(edges, pixel_image, params)
    size_y, size_x = size(pixel_image)
    edge_vertical_domain = (size_y-1, size_x)
    for i in CartesianRange(edge_vertical_domain)
        push!(edges, Edge(pixel_image[i],
                          pixel_image[i+CartesianIndex(1,0)]
                         ))
    end
    if params.y_connectivity
        for i in CartesianRange(CartesianIndex(size_y,1), CartesianIndex(size_y,size_x))
            push!(edges, Edge(pixel_image[i],
                              pixel_image[i+CartesianIndex(-size_y+1,0)]
                             ))
        end
    end
end

function gather_pixels!(edges, params)
    for edge in edges
        merge_groups!(edge)
    end
end

function unwrap_image!(image, pixel_image)
    T = typeof(pixel_image[1,1].val)
    @. image = 2 * convert(T, π) * getfield(pixel_image, :periods) + getfield(pixel_image, :val)
end

function wrap_val(val)
    wrapped_val = val
    if val > π
        wrapped_val = val - 2 * convert(typeof(val), π)
    elseif val < -π
        wrapped_val = val + 2 * convert(typeof(val), π)
    end
    return wrapped_val
end

function find_period(val_left, val_right)
    difference = val_left - val_right
    period = 0
    if difference > π
        period = -1
    elseif difference < -π
        period = 1
    end
    return period
end

function merge_groups!(edge)
    pixel_1 = edge.pixel_1
    pixel_2 = edge.pixel_2
    if pixel_1.group !== pixel_2.group
        # pixel 2 is alone in group
        if is_pixelalone(pixel_2)
            merge_pixels!(pixel_1, pixel_2, -edge.periods)
        elseif is_pixelalone(pixel_1)
            merge_pixels!(pixel_2, pixel_1, edge.periods)
        else
            if length(pixel_1.group) > length(pixel_2.group)
                merge_into_group!(pixel_1, pixel_2, -edge.periods)
            else
                merge_into_group!(pixel_2, pixel_1, edge.periods)
            end
        end
    end
end

function is_pixelalone(pixel)
    return length(pixel.group) == 1
end

function merge_pixels!(pixel_base, pixel_target, periods)
    append!(pixel_base.group, pixel_target.group)
    pixel_target.group = pixel_base.group
    pixel_target.periods = pixel_base.periods + periods
end

function merge_into_group!(pixel_base, pixel_target, periods)
    add_periods = pixel_base.periods + periods - pixel_target.periods
    for pixel in pixel_target.group
        # merge all pixels in pixel_target's group to pixel_base's group
        if pixel !== pixel_target
            pixel.periods += add_periods
            pixel.group = pixel_base.group
        end
    end
    # assign pixel_target to pixel_base's group last
    merge_pixels!(pixel_base, pixel_target, periods)
end
