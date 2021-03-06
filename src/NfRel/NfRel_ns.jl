################################################################################
#
#  NfRel/NfRel_ns.jl : non-simple relative fields
#
# This file is part of Hecke.
#
# Copyright (c) 2015, 2016, 2017: Claus Fieker, Tommy Hofmann
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#
#  Copyright (C) 2017 Tommy Hofmann, Claus Fieker
#
################################################################################

#= trivial example
Qx, x = PolynomialRing(FlintQQ)
QQ = number_field(x-1)[1]
QQt, t = QQ["t"]
K, gK = number_field([t^2-2, t^2-3, t^2-5, t^2-7])
[ minpoly(x) for x = gK]
S, mS = Hecke.simple_extension(K)
mS(gen(S))
mS\gens(K)[2]
=#

function Nemo.PolynomialRing(R::Nemo.Ring, n::Int, s::String="x"; cached::Bool = true, ordering::Symbol = :lex)
  return Nemo.PolynomialRing(R, ["$s$i" for i=1:n], cached = cached, ordering = ordering)
end                                      

#to make the MPoly module happy, divrem needs it...
function Nemo.div(a::nf_elem, b::nf_elem)
  return a//b
end

function Nemo.rem(a::nf_elem, b::nf_elem)
  return parent(a)(0)
end

#non-simple fields are quotients by multivariate polynomials
#this could be extended to arbitrary zero-dimensional quotients, but
#I don't need this here.

mutable struct NfRel_ns{T} <: Nemo.Field 
  base_ring::Nemo.Field
  pol::Array{Nemo.GenMPoly{T}, 1}
  S::Array{Symbol, 1}

  function NfRel_ns(f::Array{Nemo.GenMPoly{T}, 1}, S::Array{Symbol, 1}; cached::Bool = false) where T
    r = new{T}()
    r.pol = f
    r.base_ring = base_ring(f[1])
    r.S = S
    return r
  end
end

#mostly copied from NfRel I am afraid..

mutable struct NfRel_nsElem{T} <: Nemo.FieldElem
  data::Nemo.GenMPoly{T}
  parent::NfRel_ns{T}

  NfRel_nsElem{T}(g::GenMPoly{T}) where {T} = new{T}(g)
end

################################################################################
#
#  Copy
#
################################################################################

function Base.deepcopy_internal(a::NfRel_nsElem{T}, dict::ObjectIdDict) where T
  z = NfRel_nsElem{T}(Base.deepcopy_internal(data(a), dict))
  z.parent = parent(a)
  return z
end

#julia's a^i needs copy
function Base.copy(a::NfRel_nsElem)
  return parent(a)(a.data)
end

################################################################################
#
#  Comply with Nemo ring interface
#
################################################################################

Nemo.elem_type{T}(::Type{NfRel_ns{T}}) = NfRel_nsElem{T}

Nemo.elem_type{T}(::NfRel_ns{T}) = NfRel_nsElem{T}

Nemo.parent_type{T}(::Type{NfRel_nsElem{T}}) = NfRel_ns{T}

Nemo.needs_parentheses(::NfRel_nsElem) = true

Nemo.isnegative(x::NfRel_nsElem) = Nemo.isnegative(data(x))

Nemo.show_minus_one{T}(::Type{NfRel_nsElem{T}}) = true

function Nemo.iszero(a::NfRel_nsElem)
  reduce!(a)
  return iszero(data(a))
end

function Nemo.isone(a::NfRel_nsElem)
  reduce!(a)
  return isone(data(a))
end

Nemo.zero(K::NfRel_ns) = K(Nemo.zero(parent(K.pol[1])))

Nemo.one(K::NfRel_ns) = K(Nemo.one(parent(K.pol[1])))
Nemo.one(a::NfRel_nsElem) = one(a.parent)

################################################################################
#
#  Promotion
#
################################################################################

Nemo.promote_rule{T <: Integer, S}(::Type{NfRel_nsElem{S}}, ::Type{T}) = NfRel_nsElem{S}

Nemo.promote_rule(::Type{NfRel_nsElem{T}}, ::Type{fmpz}) where {T} = NfRel_nsElem{T}

Nemo.promote_rule(::Type{NfRel_nsElem{T}}, ::Type{fmpq}) where {T} = NfRel_nsElem{T}

Nemo.promote_rule(::Type{NfRel_nsElem{T}}, ::Type{T}) where {T} = NfRel_nsElem{T}

function Nemo.promote_rule1(::Type{NfRel_nsElem{T}}, ::Type{NfRel_nsElem{U}}) where {T, U}
   Nemo.promote_rule(T, NfRel_nsElem{U}) == T ? NfRel_nsElem{T} : Union{}
end

function Nemo.promote_rule(::Type{NfRel_nsElem{T}}, ::Type{U}) where {T, U} 
   Nemo.promote_rule(T, U) == T ? NfRel_nsElem{T} : Nemo.promote_rule1(U, NfRel_nsElem{T})
end

################################################################################
#
#  Field access
#
################################################################################

@inline Nemo.base_ring{T}(a::NfRel_ns{T}) = a.base_ring::parent_type(T)

@inline Nemo.data(a::NfRel_nsElem) = a.data

@inline Nemo.parent{T}(a::NfRel_nsElem{T}) = a.parent::NfRel_ns{T}

################################################################################
#
#  Reduction
#
################################################################################

function reduce!(a::NfRel_nsElem)
  q, a.data = divrem(a.data, parent(a).pol)
  return a
end
 
################################################################################
#
#  String I/O
#
################################################################################

function Base.show(io::IO, a::NfRel_ns)
  print(io, "non-simple Relative number field over\n")
  print(io, a.base_ring, "\n")
  print(io, " with defining polynomials ", a.pol)
end

#TODO: this is a terrible show func.
function Base.show(io::IO, a::NfRel_nsElem)
  f = data(a)
  for i=1:length(f)
    if i>1
      print(io, " + ")
    end
    print(io, "(", f.coeffs[i], ")*")
    print(io, "$(a.parent.S[1])^$(Int(f.exps[1, i]))")
    for j=2:length(a.parent.pol)
      print(io, " * $(a.parent.S[j])^$(Int(f.exps[j, i]))")
    end
  end
end

################################################################################
#
#  Constructors and parent object overloading
#
################################################################################

function Hecke.number_field(f::Array{GenPoly{T}, 1}, s::String="_\$") where T
  S = Symbol(s)
  R = base_ring(f[1])
  Rx, x = PolynomialRing(R, length(f), s)
  K = NfRel_ns([f[i](x[i]) for i=1:length(f)], [Symbol("$s$i") for i=1:length(f)])
  return K, gens(K)
end

Nemo.gens(K::NfRel_ns) = [K(x) for x = gens(parent(K.pol[1]))]

function (K::NfRel_ns{T})(a::GenMPoly{T}) where T
  q, w = divrem(a, K.pol)
  z = NfRel_nsElem{T}(w)
  z.parent = K
  return z
end

function (K::NfRel_ns{T})(a::T) where T
  parent(a) != base_ring(parent(K.pol[1])) == error("Cannot coerce")
  z = NfRel_nsElem{T}(parent(K.pol[1])(a))
  z.parent = K
  return z
end

(K::NfRel_ns)(a::Integer) = K(parent(K.pol[1])(a))

(K::NfRel_ns)(a::Rational{T}) where {T <: Integer} = K(parent(K.pol)(a))

(K::NfRel_ns)(a::fmpz) = K(parent(K.pol)(a))

(K::NfRel_ns)(a::fmpq) = K(parent(K.pol)(a))

(K::NfRel_ns)() = zero(K)

Nemo.gen(K::NfRel_ns) = K(Nemo.gen(parent(K.pol)))

################################################################################
#
#  Unary operators
#
################################################################################

function Base.:(-)(a::NfRel_nsElem)
  return parent(a)(-data(a))
end

################################################################################
#
#  Binary operators
#
################################################################################

function Base.:(+)(a::NfRel_nsElem{T}, b::NfRel_nsElem{T}) where {T}
  return parent(a)(data(a) + data(b))
end

function Base.:(-)(a::NfRel_nsElem{T}, b::NfRel_nsElem{T}) where {T}
  return parent(a)(data(a) - data(b))
end

function Base.:(*)(a::NfRel_nsElem{T}, b::NfRel_nsElem{T}) where {T}
  return parent(a)(data(a) * data(b))
end

function Base.:(//)(a::NfRel_nsElem{T}, b::NfRel_nsElem{T}) where {T}
  return div(a, b)
end

function Nemo.div(a::NfRel_nsElem{T}, b::NfRel_nsElem{T}) where {T}
  return a*inv(b)
end

Nemo.divexact(a::NfRel_nsElem, b::NfRel_nsElem) = div(a, b)
################################################################################
#
#  Powering
#
################################################################################
#via julia
################################################################################
#
#  Comparison
#
################################################################################

function Base.:(==)(a::NfRel_nsElem{T}, b::NfRel_nsElem{T}) where T
  reduce!(a)
  reduce!(b)
  return data(a) == data(b)
end

################################################################################
#
#  Unsafe operations
#
################################################################################

function Nemo.mul!(c::NfRel_nsElem{T}, a::NfRel_nsElem{T}, b::NfRel_nsElem{T}) where {T}
  mul!(c.data, a.data, b.data)
  c = reduce!(c)
  return c
end

function Nemo.addeq!(b::NfRel_nsElem{T}, a::NfRel_nsElem{T}) where {T}
  addeq!(b.data, a.data)
  b = reduce!(b)
  return b
end

function Base.hash(a::NfRel_nsElem{nf_elem}, b::UInt)
  reduce!(a)
  return hash(a.data, b)
end

###############################################################################
# other stuff, trivia and non-trivia
###############################################################################

function Nemo.degree(K::NfRel_ns)
  return prod([total_degree(x) for x=K.pol])
end

function total_degree(f::GenMPoly)
  return Int(maximum([sum(f.exps[:, i]) for i=1:length(f)]))
end

#non-optimal...
function Hecke.basis(K::NfRel_ns)
  b = NfRel_nsElem[]
  g = gens(K)
  for i=CartesianRange(Tuple(1:total_degree(f) for f = K.pol))
    push!(b, prod(g[j]^(i[j]-1) for j=1:length(i)))
  end
  return b
end

#TODO: a sparse version
function Hecke.elem_to_mat_row!(M::GenMat{T}, i::Int, a::NfRel_nsElem{T}) where T
  K = parent(a)
  C = CartesianRange(Tuple(0:total_degree(f)-1 for f = K.pol))
  C = [UInt[c[i] for i=1:length(K.pol)] for c = C]
  zero = base_ring(K)(0)
  for j=1:cols(M)
    M[i, j] = zero
  end
  for j=1:length(a.data)
    p = findnext(C, a.data.exps[:, j], 1)
    @assert p!=0
    M[i, p] = a.data.coeffs[j]
  end
end

function Hecke.minpoly(a::NfRel_nsElem)
  K = parent(a)
  n = degree(K)
  k = base_ring(K)
  M = MatrixSpace(k, degree(K)+1, degree(K))()
  z = a^0
  elem_to_mat_row!(M, 1, z)
  z *= a
  elem_to_mat_row!(M, 2, z)
  i = 2
  while true
    if n % (i-1) == 0 && rank(M) < i
      N = nullspace(sub(M, 1:i, 1:cols(M))')
      @assert N[1] == 1
      f = k["t"][1]([N[2][j, 1] for j=1:i])
      return f*inv(lead(f))
    end
    z *= a
    elem_to_mat_row!(M, i+1, z)
    i += 1
  end
end

function Hecke.inv(a::NfRel_nsElem)
  if iszero(a)
    error("division by zero")
  end
  f = minpoly(a)
  z = coeff(f, degree(f))
  for i=degree(f)-1:-1:1
    z = z*a + coeff(f, i)
  end
  return -z*inv(coeff(f, 0))
end

function Hecke.charpoly(a::NfRel_nsElem)
  f = minpoly(a)
  return f^div(degree(parent(a)), degree(f))
end

function Hecke.norm(a::NfRel_nsElem)
  f = minpoly(a)
  return (-1)^degree(parent(a)) * coeff(f, 0)^div(degree(parent(a)), degree(f))
end

function Hecke.trace(a::NfRel_nsElem)
  f = minpoly(a)
  return -coeff(f, degree(f)-1)*div(degree(parent(a)), degree(f))
end

#TODO: also provide a sparse version
function Hecke.representation_mat(a::NfRel_nsElem)
  K = parent(a)
  b = basis(K)
  k = base_ring(K)
  M = MatrixSpace(k, degree(K), degree(K))()
  for i=1:degree(K)
    elem_to_mat_row!(M, i, a*b[i])
  end
  return M
end

@inline Hecke.ngens(K::NfRel_ns) = length(K.pol)

mutable struct NfRelToNfRel_nsMor{T} <: Map{Hecke.NfRel{T}, NfRel_ns{T}}
  header::Hecke.MapHeader{Hecke.NfRel{T}, NfRel_ns{T}}
  prim_img::NfRel_nsElem{T}
  emb::Array{Hecke.NfRelElem{T}, 1}
  coeff_aut::Hecke.NfToNfMor

  function NfRelToNfRel_nsMor(K::Hecke.NfRel{T}, L::NfRel_ns{T}, a::NfRel_nsElem{T}, emb::Array{Hecke.NfRelElem{T}, 1}) where {T}
    function image(x::Hecke.NfRelElem{T})
      # x is an element of K
      f = data(x)
      # First evaluate the coefficients of f at a to get a polynomial over L
      # Then evaluate at b
      return f(a)
    end

    function preimage(x::NfRel_nsElem{T})
      return msubst(x.data, emb)
    end

    z = new{T}()
    z.prim_img = a
    z.emb = emb
    z.header = Hecke.MapHeader(K, L, image, preimage)
    return z
  end  
end

Hecke.ngens(R::Nemo.GenMPolyRing) = R.num_vars

#aparently, should be called evaluate, talk to Bill...
function msubst(f::GenMPoly{T}, v::Array{Hecke.NfRelElem{T}, 1}) where T
  k = base_ring(parent(f))
  n = length(v)
  @assert n == ngens(parent(f))
  r = zero(k)
  for i=1:length(f)
    r += f.coeffs[i]*prod(v[j]^f.exps[j, i] for j=1:n)
  end
  return r
end

#find isomorphic simple field AND the map
function simple_extension(K::NfRel_ns)
  n = ngens(K)
  g = gens(K)

  pe = g[1]
  i = 1
  ind = [1]
  local f::GenPoly{nf_elem}
  while i < n
    i += 1
    j = 1
    f = minpoly(pe+j*g[i])
    while degree(f) < prod(total_degree(K.pol[k]) for k=1:i)
      j += 1
      f = minpoly(pe+j*g[i])
    end
    push!(ind, j)
    pe += j*g[i]
  end
  Ka, a = number_field(f)
  k = base_ring(K)
  M = MatrixSpace(k, degree(K), degree(K))()
  z = one(K)
  elem_to_mat_row!(M, 1, z)
  elem_to_mat_row!(M, 2, pe)
  z *= pe
  for i=3:degree(K)
    z *= pe
    elem_to_mat_row!(M, i, z)
  end
  N = MatrixSpace(k, 1, degree(K))()
  b = basis(Ka)
  emb = typeof(b)()
  for i=1:n
    elem_to_mat_row!(N, 1, g[i])
    s = solve(M', N')
    push!(emb, sum(b[j]*s[j,1] for j=1:degree(Ka)))
  end

  return Ka, NfRelToNfRel_nsMor(Ka, K, pe, emb)
end

#trivia, missing in NfRel
function Hecke.basis(K::Hecke.NfRel)
  a = gen(K)
  z = one(K)
  b = [z, a]
  while length(b) < degree(K)
    push!(b, b[end]*a)
  end
  return b
end  

function Base.one(a::Hecke.NfRelElem)
  return one(parent(a))
end

function Base.copy(a::Hecke.NfRelElem)
  return parent(a)(a.data)
end


