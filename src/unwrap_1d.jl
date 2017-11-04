function unwrap!(A::AbstractVector,
                 wrap_around::NTuple{1, Bool}=(false,),
                 seed::Int=-1)
    @inbounds previous_element = A[1]
    difference = zero(previous_element)
    periods = 0
    @inbounds for i in 2:length(A)
        difference = A[i] - previous_element
        if difference > π
            periods -= 1
        elseif difference < -π
            periods += 1
        end
        previous_element = A[i]
        A[i] = previous_element + 2 * one(previous_element) * π * periods
    end
    return A
end
