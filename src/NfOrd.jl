################################################################################
#
#  NfOrd.jl
#
################################################################################
#
# Copyright (c) 2015: Tommy Hofmann
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
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

add_verbose_scope(:NfOrd)
add_assert_scope(:NfOrd)

include("NfOrd/NfOrd.jl")
include("NfOrd/Elem.jl")
include("NfOrd/Ideal.jl")
include("NfOrd/FracIdeal.jl")
include("NfOrd/Zeta.jl")
include("NfOrd/Clgp.jl")
include("NfOrd/Unit.jl")
include("NfOrd/ResidueField.jl")
include("NfOrd/ResidueRing.jl")
include("NfOrd/ResidueRingMultGrp.jl")
include("NfOrd/FactorBaseBound.jl")
include("NfOrd/FacElem.jl")
include("NfOrd/LinearAlgebra.jl")
include("NfOrd/Narrow.jl")
include("NfOrd/norm_eqn.jl")
include("NfOrd/RayClass.jl")
include("NfOrd/RayClassFacElem.jl")
include("NfOrd/DedekindCriterion.jl")
include("NfOrd/TorsionUnits.jl")
