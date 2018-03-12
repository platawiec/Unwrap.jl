function calculate_pixel_reliability(pixel_image::AbstractArray{T, 2}, pixel_index, pixel_shifts) where T
    @inbounds D1 = wrap_val(pixel_image[pixel_index+pixel_shifts[2]].val - pixel_image[pixel_index].val)
    @inbounds D2 = wrap_val(pixel_image[pixel_index+pixel_shifts[4]].val - pixel_image[pixel_index].val)
    @inbounds H  = wrap_val(pixel_image[pixel_index+pixel_shifts[6]].val - pixel_image[pixel_index].val)
    @inbounds V  = wrap_val(pixel_image[pixel_index+pixel_shifts[8]].val - pixel_image[pixel_index].val)
    return H*H + V*V + D1*D1 + D2*D2
end
