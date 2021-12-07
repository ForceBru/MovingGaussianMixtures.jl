"""
Settings to control fitting of Gaussian mixture models.

- Initialization is controlled by derivatives of `Settings.AbstractInitStrategy`,
types whose names look like `Settings.Init[something]`.
- Stopping criteria are controlled by `Settings.AbstractStopping`
- Regularization (to prevent zero variance, for example) is set up by `Settings.AbstractRegularization`.

Details are available in documentation of each type.
"""
module Settings

using DocStringExtensions

"""
$(TYPEDEF)

Controls the initialization strategy of the EM algorithm.
"""
abstract type AbstractInitStrategy end

"""
$(TYPEDEF)

Initialize posteriors randomly from `Dirichlet(a)`
"""
struct InitRandomPosterior{T<:Real} <: AbstractInitStrategy
    "Parameter of the Dirichlet distribution"
    a::T

    function InitRandomPosterior(a::T) where T<:Real
        @assert a > 0

        new{T}(a)
    end
end

"""
$(TYPEDEF)

Keep the posteriors unchanged.
Initialize parameter estimates using these posteriors in the usual M-step.
"""
struct InitKeepPosterior <: AbstractInitStrategy end

"""
$(TYPEDEF)

Keep the parameter estimates unchanged.
Initialize posteriors using these parameter estimates in the usual E-step.
"""
struct InitKeepParameters <: AbstractInitStrategy end

"""
$(TYPEDEF)

Controls the ctopping criterion of the EM algorithm.
"""
abstract type AbstractStopping end

"""
$(TYPEDEF)
Consider EM converged when the absolute difference in ELBO
stays less than `tol` during the last `n_iter` iterations.

$(TYPEDFIELDS)
"""
struct StoppingELBO{T<:Real} <: AbstractStopping
    "Minimum required change in ELBO"
    tol::T
    "Stop the algorithm if ELBO hasn't changed much during the last `n_iter` iterations"
    n_iter::Int

    function StoppingELBO(tol::T, n_iter::Integer) where T<:Real
        @assert tol > 0
        @assert n_iter > 0

        new{T}(tol, n_iter)
    end
end

"""
$(TYPEDEF)

Controls the regularization of the EM algorithm.
Regularization is needed mainly to prevent the algorithm
from zeroing-out components' variances.
"""
abstract type AbstractRegularization end
abstract type AbstractRegPosterior <: AbstractRegularization end
abstract type AbstractRegPrior <: AbstractRegularization end

const MaybeRegularization = Union{AbstractRegularization, Nothing}

"""
$(TYPEDEF)
Regularize posterior q(z) such that `q(z) >= eps` for any `z`.
This simple version does this by using this as `q(z)`:

```math
q(z) = [p(z|x, \\theta) + s] / [1 + s * K]
```

Here `s` is a number computed from `eps`
and `K` is the number of mixture components.

$(TYPEDFIELDS)
"""
struct RegPosteriorSimple{T<:Real} <: AbstractRegPosterior
    "Minimum probability in the posterior distribution q(z)"
    eps::T

    function RegPosteriorSimple(eps::T) where T<:Real
        @assert eps >= 0

        new{T}(eps)
    end
end

"""
$(TYPEDEF)
Keep components' variances away from zero
by adding a small positive number to them:

```math
var[k] = var[k] + \\epsilon
```

$(TYPEDFIELDS)
"""
struct RegVarianceSimple{T<:Real} <: AbstractRegPrior
    "Small value to add to components' variances"
    eps::T

    function RegVarianceSimple(eps::T) where T<:Real
        @assert eps > 0
        new{T}(eps)
    end
end

end
