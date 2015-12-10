"""
`HBlkDiag` - a homogeneous block diagonal matrix, i.e. all the diagonal blocks are the same size

A matrix consisting of k diagonal blocks of size `r×s` is stored as an `r×s×k` array.
"""
immutable HBlkDiag{T} <: AbstractMatrix{T}
    arr::Array{T,3}
end

function Base.cholfact!(A::HBlkDiag,uplo::Symbol=:U)
    Aa = A.arr
    r,s,k = size(Aa)
    if r != s
        throw(ArgumentError("A must be square"))
    end
    for j in 1:k
        cholfact!(sub(Aa,:,:,j),uplo)
    end
    A
end

Base.copy!{T}(d::HBlkDiag{T},s::HBlkDiag{T}) = (copy!(d.arr,s.arr); d)

Base.copy{T}(s::HBlkDiag{T}) = HBlkDiag(copy(s.arr))

Base.eltype{T}(A::HBlkDiag{T}) = T

function Base.full(A::HBlkDiag)
    aa = A.arr
    res = zeros(eltype(aa),size(A))
    p,q,l = size(aa)
    for b in 1:l
        bm1 = b - 1
        for j in 1:q
            for i in 1:p
                res[bm1*p+i,bm1*q+j] = aa[i,j,b]
            end
        end
    end
    res
end

function Base.getindex{T}(A::HBlkDiag{T},i::Integer,j::Integer)
    Aa = A.arr
    r,s,k = size(Aa)
    bi,ri = divrem(i-1,r)
    bj,rj = divrem(j-1,s)
    if bi ≠ bj  # i and j are not in a diagonal block
        return zero(T)
    end
    Aa[ri+1,rj+1,bi+1]
end

Base.size(A::HBlkDiag) = ((r,s,k) = size(A.arr); (r*k,s*k))

function Base.size(A::HBlkDiag,i::Integer)
    i < 1 && throw(BoundsError())
    i > 2 && return 1
    r,s,k = size(A.arr)
    (i == 1 ? r : s)*k
end

function Base.LinAlg.A_ldiv_B!{T}(A::UpperTriangular{T,HBlkDiag{T}},B::DenseVecOrMat{T})
    Aa = A.data.arr
    r,s,k = size(Aa)
    if r ≠ s
        throw(ArgumentError("A must be square"))
    end
    m,n = size(B,1),size(B,2)  # need to call size twice in case B is a vector
    if r*k ≠ m
        throw(DimensionMismatch("size(A,2) ≠ size(B,1)"))
    end
    for b in 1:k
        Base.LinAlg.A_ldiv_B!(UpperTriangular(sub(Aa,:,:,b)), sub(B,(1:r)+(b-1)*r,:))
    end
    A
end