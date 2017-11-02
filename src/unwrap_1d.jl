function unwrap!(A::AbstractVector)
    previous_element = A[1]
    difference = zero(previous_element)
    periods = 0
    for i in 2:length(A)
        difference = A[i] - previous_element
        if difference > π
            periods -= 1
        elseif difference < -π
            periods += 1
        end
        previous_element = A[i]
        A[i] = previous_element + 2 * π * periods
    end
    return A
end
