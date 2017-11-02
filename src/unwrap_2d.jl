mutable struct UnwrapParameters{T}
    mod::T
    x_connectivity::Bool
    y_connectivity::Bool
    num_edges::Int64
end

mutable struct Pixel{T}
    periods::Int64
    num_pixels_in_group::Int64
    val::T
    reliability::Float64
    id_group::Int64
    id_newgroup::Int64
end
Pixel(v) = Pixel(0, 1, v, rand(), 0, -1)

mutable struct Edge{T}
    reliability::Float64
    pixel_1::Pixel{T}
    pixel_2::Pixel{T}
    periods::Int64
end
Base.isless(e1::Edge, e2::Edge) = isless(e1.reliability, e2.reliability)

function unwrap!(wrapped_image::AbstractMatrix)

    mod = convert(eltype(wrapped_image), 2π)
    params = UnwrapParameters(mod, false, false, 0)
    pixel_image = initialise_pixels(wrapped_image)
    calculate_reliability(pixel_image, params)
    edges_h = calculate_reliability_horizontal_edges(pixel_image, params)
    edges_v = calculate_reliability_vertical_edges(pixel_image, params)

    sort(edges)

    gather_pixels()

    unwrap_image!(wrapped_image, pixel_image)

    return wrapped_image
end

# initialises the pixel array, benchmarked against CartesianRange
function initialise_pixels(wrapped_image)
    pixel_image = Pixel.(wrapped_image)
    return pixel_image
end

# calculate the reliability of the pixels
function calculate_reliability(pixel_image, params)
    const left_pixel = CartesianIndex(0, -1)
    const right_pixel = CartesianIndex(0, 1)
    const top_pixel = CartesianIndex(1, 0)
    const bot_pixel = CartesianIndex(-1, 0)
    # inner loop
    for i in CartesianRange(CartesianIndex(2,2), CartesianIndex(size(pixel_image)[1]-1, size(pixel_image)[2]-1))
        H = wrap(pixel_image[i+left_pixel].val - pixel_image[i].val)
        V = wrap(pixel_image[i+right_pixel].val - pixel_image[i].val)
        D1 = wrap(pixel_image[i+top_pixel].val - pixel_image[i].val)
        D2 = wrap(pixel_image[i+bot_pixel].val - pixel_image[i].val)
        pixel_image[i].reliability = H*H + V*V + D1*D1 + D2*D2
    end
end

# calculate reliability of horizontal edges
function calculate_reliability_horizontal_edges(pixel_image, params)
    e_size = (size(pixel_image)[1]-1, size(pixel_image)[2])
    edges_horizontal = Array{Edge{typeof(pixel_image[1].val)}}(e_size)

    for i in CartesianRange(size(edges_horizontal))
        edges_horizontal[i] = Edge((pixel_image[i].reliability
                                        + pixel_image[i+CartesianIndex(1, 0)].reliability),
                                    pixel_image[i],
                                    pixel_image[i+CartesianIndex(1,0)],
                                    find_period(pixel_image[i].val,
                                               pixel_image[i+CartesianIndex(1, 0)].val)
                                   )
        params.num_edges += 1
    end

    return edges_horizontal
end

function calculate_reliability_vertical_edges(pixel_image, params)
    e_size = (size(pixel_image)[1], size(pixel_image)[2]-1)
    edges_vertical = Array{Edge{typeof(pixel_image[1].val)}}(e_size)

    for i in CartesianRange(size(edges_vertical))
        edges_vertical[i] = Edge((pixel_image[i].reliability
                                        + pixel_image[i+CartesianIndex(0, 1)].reliability),
                                    pixel_image[i],
                                    pixel_image[i+CartesianIndex(0, 1)],
                                    find_period(pixel_image[i].val,
                                                pixel_image[i+CartesianIndex(0, 1)].val)
                                   )
        params.num_edges += 1
    end

    return edges_vertical
end

function gather_pixels(edges, params)
    for edge in edges
        if edge.pixel_1.id_group != edge.pixel_2.id_group
            # pixel 2 is alone in group
            if edge.pixel_2.num_pixels_in_group == 1
                merge_pixels!(edge.pixel_1, edge.pixel_2)
            end
        end
    end
end

function unwrap_image!(image, pixel_image)
    @. image = 2π * pixel_image.periods + pixel_image.val
    return image
end

function wrap(val)
    wrapped_val = val
    if val > π
        wrapped_val = val - 2π
    elseif val < -π
        wrapped_val = val + 2π
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

function merge_pixels!(pixel_1, pixel_2)
    pixel_1.num_pixels_in_group += 1
    pixel_2.num_pixels_in_group += 1

end
