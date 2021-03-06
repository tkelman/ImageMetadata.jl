using ImageMetadata, Colors, ColorVectorSpace, Base.Test

@testset "operations" begin
    function checkmeta(A, B)
        @test isa(A, ImageMeta)
        @test A == B
        nothing
    end
    for A in (rand(Bool, 3, 5), rand(3, 5),
              rand(Gray{U8}, 3, 5), rand(RGB{U8}, 3, 5))
        M = ImageMeta(A)
        checkmeta(-M, -A)
        checkmeta(M + zero(eltype(M)), M)
        checkmeta(zero(eltype(M)) + M, M)
        checkmeta(M - zero(eltype(M)), M)
        checkmeta(zero(eltype(M)) - M, -M)
        B = falses(size(M))
        for op in (+, .+)
            if !(eltype(A) <: RGB)
                checkmeta(op(M, B), M)
                checkmeta(op(B, M), M)
            end
            @test_throws ErrorException op(M, M)
            checkmeta(op(A, M), A+A)
            checkmeta(op(M, A), A+A)
        end
        for op in (-, .-)
            if !(eltype(A) <: RGB)
                checkmeta(op(M, B), M)
                checkmeta(op(B, M), -M)
            end
            @test_throws ErrorException op(M, M)
            checkmeta(op(A, M), 0*M)
            checkmeta(op(M, A), 0*M)
        end
        checkmeta(M*2, 2*M)
        checkmeta(2.*M, 2*M)
        checkmeta(M.*2, 2*M)
        checkmeta(M/2, M/2)
        checkmeta(M./2, M/2)
        checkmeta(M.*B, 0*M)
        checkmeta(B.*M, 0*M)
        if !(eltype(A) <: RGB)
            @test_throws ErrorException M.*M
            checkmeta(A.*M, A.*A)
            checkmeta(M.*A, A.*A)
            checkmeta(M.^1, M)
        end
        B1 = trues(size(M))
        checkmeta(M./B1, M)
        @test_throws ErrorException M./M
        if !(eltype(A) <: RGB)
            checkmeta(M + 0.0, M)
            checkmeta(0.0 + M, M)
            checkmeta(M .+ 0.0, M)
            checkmeta(0.0 .+ M, M)
            if eltype(A) == Float64
                checkmeta(M./A, ones(size(M)))
            end
            @test (M .< 0.5) == (A .< 0.5)
            @test (M .> 0.5) == (A .> 0.5)
            @test (M .< A) == B
            @test (M .> A) == B
            @test (M .== 0.5) == (A .== 0.5)
            @test (M .== A) == B1
        end
    end
end

M = ImageMeta([1,2,3,4])
@test minimum(M) == 1
@test maximum(M) == 4
Mp = M'
@test ndims(Mp) == 2
Ms = squeeze(Mp, 1)
@test Ms == M

nothing
