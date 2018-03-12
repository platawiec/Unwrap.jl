struct UnwrapParameters
    x_connectivity::Bool
    y_connectivity::Bool
end

function unwrap!(wrapped_image::AbstractMatrix,
                 wrap_around::NTuple{2, Bool}=(false, false),
                 seed::Int=-1)

    if seed != -1
        srand(seed)
    end

    params = UnwrapParameters(wrap_around...)
    pixel_image = init_pixels(wrapped_image)
    calculate_reliability(pixel_image, params)
    edges = Edge{eltype(wrapped_image)}[]
    sizex, sizey = size(wrapped_image)
    sizehint!(edges, (sizex-1)*sizey + sizex*(sizey-1)
                      + params.x_connectivity*sizey
                      + params.y_connectivity*sizex)
    populate_horizontal_edges!(edges, pixel_image, params)
    populate_vertical_edges!(edges, pixel_image, params)

    sort!(edges, alg=MergeSort)

    gather_pixels!(edges, params)

    unwrap_image!(wrapped_image, pixel_image)

    return wrapped_image
end

# function to broadcast
function init_pixels(wrapped_image)
    pixel_image = similar(wrapped_image, Pixel{eltype(wrapped_image)})
    @Threads.threads for i in eachindex(wrapped_image)
        @inbounds pixel_image[i] = Pixel(wrapped_image[i])
    end
    return pixel_image
end

function calculate_reliability(pixel_image, params)
    # get the shifted pixel indices in CartesinanIndex form
    pixel_shifts = CartesianIndex.(((0, -1), (0, 1), (1, 0), (-1, 0)))
    size_y, size_x = size(pixel_image)
    # inner loop
    for i in CartesianRange(CartesianIndex(2, 2), CartesianIndex(size_y-1, size_x-1))
        @inbounds pixel_image[i].reliability = calculate_pixel_reliability(pixel_image, i, pixel_shifts)
    end

    if params.x_connectivity
        # left border
        pixel_shifts = CartesianIndex.(((0, size_x-1), (0, 1), (1, 0), (-1, 0)))
        for i in CartesianRange(CartesianIndex(2, 1), CartesianIndex(size_y-1, 1))
            @inbounds pixel_image[i].reliability = calculate_pixel_reliability(pixel_image, i, pixel_shifts)
        end
        # right border
        pixel_shifts = CartesianIndex.(((0, -1), (0, -size_x+1), (1, 0), (-1, 0)))
        for i in CartesianRange(CartesianIndex(2, size_x), CartesianIndex(size_y-1, size_x))
            @inbounds pixel_image[i].reliability = calculate_pixel_reliability(pixel_image, i, pixel_shifts)
        end
    end
    if params.y_connectivity
        # top border
        pixel_shifts = CartesianIndex.(((0, -1), (0, 1), (-size_y+1, 0), (-1, 0)))
        for i in CartesianRange(CartesianIndex(size_y, 2), CartesianIndex(size_y, size_x-1))
            @inbounds pixel_image[i].reliability = calculate_pixel_reliability(pixel_image, i, pixel_shifts)
        end
        # bottom border
        pixel_shifts = CartesianIndex.(((0, -1), (0, 1), (1, 0), (size_y-1, 0)))
        for i in CartesianRange(CartesianIndex(1, 2), CartesianIndex(1, size_x-1))
            @inbounds pixel_image[i].reliability = calculate_pixel_reliability(pixel_image, i, pixel_shifts)
        end
    end
end

function calculate_pixel_reliability(pixel_image, pixel_index, pixel_shifts)
    @inbounds H = wrap_val(pixel_image[pixel_index+pixel_shifts[1]].val - pixel_image[pixel_index].val)
    @inbounds V = wrap_val(pixel_image[pixel_index+pixel_shifts[2]].val - pixel_image[pixel_index].val)
    @inbounds D1 = wrap_val(pixel_image[pixel_index+pixel_shifts[3]].val - pixel_image[pixel_index].val)
    @inbounds D2 = wrap_val(pixel_image[pixel_index+pixel_shifts[4]].val - pixel_image[pixel_index].val)
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
