mutable struct Pixel{T}
    periods::Int
    val::T
    reliability::Float64
    groupsize::Int
    head::Pixel{T}
    last::Pixel{T}
    next::Union{Void, Pixel{T}}
    function Pixel{T}(periods, val, rel, gs) where T
        pixel = new(periods, val, rel, gs)
        pixel.head = pixel
        pixel.last = pixel
        pixel.next = nothing
        return pixel
    end
end
Pixel(v) = Pixel{typeof(v)}(0, v, rand(), 1)
@inline Base.length(p::Pixel) = p.head.groupsize

struct Edge{T}
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

# function to broadcast
function init_pixels(wrapped_image)
    pixel_image = similar(wrapped_image, Pixel{eltype(wrapped_image)})
    @Threads.threads for i in eachindex(wrapped_image)
        @inbounds pixel_image[i] = Pixel(wrapped_image[i])
    end
    return pixel_image
end

function gather_pixels!(edges, params)
    for edge in edges
        merge_groups!(edge)
    end
end

function unwrap_image!(image, pixel_image)
    T = fieldtype(eltype(pixel_image), :val)
    this_pi = convert(T, π)
    @Threads.threads for i in eachindex(image)
        @inbounds image[i] = 2 * this_pi * pixel_image[i].periods + pixel_image[i].val
    end
end

function wrap_val(val)
    wrapped_val  = val
    wrapped_val += ifelse(val >  π, -2 * convert(typeof(val), π), zero(val))
    wrapped_val += ifelse(val < -π,  2 * convert(typeof(val), π), zero(val))
    return wrapped_val
end

function find_period(val_left, val_right)
    difference = val_left - val_right
    period  = 0
    period += ifelse(difference >  π, -1, 0)
    period += ifelse(difference < -π,  1, 0)
    return period
end

function merge_groups!(edge)
    pixel_1 = edge.pixel_1
    pixel_2 = edge.pixel_2
    if is_differentgroup(pixel_1, pixel_2)
        # pixel 2 is alone in group
        if is_pixelalone(pixel_2)
            merge_pixels!(pixel_1, pixel_2, -edge.periods)
        elseif is_pixelalone(pixel_1)
            merge_pixels!(pixel_2, pixel_1, edge.periods)
        else
            if is_bigger(pixel_1, pixel_2)
                merge_into_group!(pixel_1, pixel_2, -edge.periods)
            else
                merge_into_group!(pixel_2, pixel_1, edge.periods)
            end
        end
    end
end

@inline function is_differentgroup(p1::Pixel, p2::Pixel)
    return p1.head !== p2.head
end

@inline function is_pixelalone(pixel::Pixel)
    return pixel.head === pixel.last
end

@inline function is_bigger(p1::Pixel, p2::Pixel)
    return length(p1) ≥ length(p2)
end

function merge_pixels!(pixel_base::Pixel, pixel_target::Pixel, periods)
    pixel_base.head.groupsize += pixel_target.head.groupsize
    pixel_base.head.last.next = pixel_target.head
    pixel_base.head.last = pixel_target.head.last
    pixel_target.head = pixel_base.head
    pixel_target.periods = pixel_base.periods + periods
end

function merge_into_group!(pixel_base::Pixel, pixel_target::Pixel, periods)
    add_periods = pixel_base.periods + periods - pixel_target.periods
    pixel = pixel_target.head
    while pixel ≠ nothing
        # merge all pixels in pixel_target's group to pixel_base's group
        if pixel !== pixel_target
            pixel.periods += add_periods
            pixel.head = pixel_base.head
        end
        pixel = pixel.next
    end
    # assign pixel_target to pixel_base's group last
    merge_pixels!(pixel_base, pixel_target, periods)
end

function populate_edges!(edges, pixel_image::Array{T, N}, dim, connected) where {T, N}
    size_img       = collect(size(pixel_image))
    size_img[dim] -= 1
    idx_step       = fill(0, N)
    idx_step[dim] += 1
    idx_step       = CartesianIndex{N}(idx_step...)
    idx_size       = CartesianIndex{N}(size_img...)
    for i in CartesianRange(idx_size)
        push!(edges, Edge(pixel_image[i],
                          pixel_image[i+idx_step]
                         ))
    end
    if connected
        idx_step = fill(0, N)
        idx_step[dim] = -size_img[dim]
        idx_step = CartesianIndex{N}(idx_step...)
        edge_begin  = fill(1, N)
        edge_begin[dim] = size(pixel_image)[dim]
        edge_begin = CartesianIndex{N}(edge_begin...)
        for i in CartesianRange(edge_begin, CartesianIndex(size(pixel_image)))
            push!(edges, Edge(pixel_image[i],
                              pixel_image[i+idx_step]
                             ))
        end
    end
end
