function calculate_pixel_reliability(pixel_image::AbstractArray{T, 3}, pixel_index, pixel_shifts) where T
    sum_val = zero(fieldtype(T, :val))
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[1]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[2]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[3]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[4]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[5]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[6]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[7]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[8]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[9]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[10]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[11]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[12]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[13]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[15]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[17]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[18]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[19]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[20]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[21]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[22]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[23]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[24]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[25]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[26]].val - pixel_image[pixel_index].val))^2
    @inbounds sum_val += (wrap_val(pixel_image[pixel_index+pixel_shifts[27]].val - pixel_image[pixel_index].val))^2
    return sum_val
end
