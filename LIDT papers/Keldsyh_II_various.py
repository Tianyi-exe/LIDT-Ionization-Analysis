# Converted from Keldsyh_II_various.ipynb
# Source notebook: C:\Users\Faculty\OneDrive - The City University of New York\Tasks\BNL2026\LIDT2026\LIDT papers\Keldsyh_II_various.ipynb

# %%
# Cell 0
"""
Reconciled Keldysh + avalanche ionization model for ZnSe and ZnS.

The script evaluates
--------------------
1. Full Keldysh photoionization rate, W_PI.
2. Avalanche/impact ionization using a Drude absorption cross section,

       W_av(I, n_e) = [sigma(I, n_e) I / E_g] n_e,

   with

       sigma = e^2/(c eps0 n0 m_r) * tau_C/(1 + omega^2 tau_C^2),

       tau_C = 16 pi eps0^2 sqrt[m_r (0.1 E_g)^3]
               / [sqrt(2) e^4 n_e].

3. Time-dependent carrier-density growth,

       dn_e/dt = W_PI(t) + W_av(I(t), n_e(t)).

Model assumptions
-----------------
* Recombination and trapping are neglected.
* Carrier depletion and saturation are neglected.
* Propagation, self-focusing, and laser-induced changes in optical constants
  are neglected.
* The same linear refractive index is used in the Keldysh and Drude terms.
* The temporal pulse is Gaussian and centered at t = 0.
* The integration window is from -3 tau to +3 tau, where tau is the
  intensity FWHM duration.

Units
-----
* Internal calculations: SI units.
* Input fluence: J/cm^2.
* Input irradiance for scaling plots: W/cm^2.
* Wavelength: micrometers.
* Pulse duration: femtoseconds.
* Summary densities: cm^-3.
* Final rate plot: cm^-3 fs^-1.

Default workflow
----------------
The default execution produces:
1. The first graph set: Keldysh photoionization-rate curves.
2. The density-growth summary table.
3. The total-ionization 3D surface grid.
"""


from __future__ import annotations

import csv
import json
import os
import pickle
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence, Tuple, Union

# CODEX MODIFICATION START: shared colormap normalization for 3D colorbar
from matplotlib import cm, colors
# CODEX MODIFICATION END: shared colormap normalization for 3D colorbar
import matplotlib.pyplot as plt
import numpy as np
from scipy.integrate import solve_ivp
from scipy.special import dawsn, ellipe, ellipk

try:
    import pandas as pd
except ImportError:
    pd = None

try:
    from IPython.display import display as ipython_display
except ImportError:
    ipython_display = None


# ============================================================
# Constants
# ============================================================

C0 = 3.0e8
EPS0 = 8.85e-12
E_CHARGE = 1.6e-19
HBAR = 1.054e-34
ME0 = 9.11e-31

CM3_PER_M3 = 1.0e-6
WCM2_PER_WM2 = 1.0e-4
WM2_PER_WCM2 = 1.0e4
RATE_CM3_FS_PER_M3_S = 1.0e-21

CaseDict = Dict[str, Any]
ArrayLike = Union[np.ndarray, float]

# CODEX MODIFICATION START: optional deferred Matplotlib display
DEFER_FIGURE_SHOW = False
# CODEX MODIFICATION END: optional deferred Matplotlib display

# CODEX MODIFICATION START: optional editable figure exports
SAVE_EDITABLE_FIGURES = False
# CODEX MODIFICATION END: optional editable figure exports

# CODEX MODIFICATION START: optional open saved image preview
OPEN_SAVED_FIGURES = False
# CODEX MODIFICATION END: optional open saved image preview


# ============================================================
# Material properties
# ============================================================

def material_flag1(
    mat_flag: int,
    wavelength_um: float,
) -> Tuple[float, float, float, float, float]:
    """
    Return wavelength-dependent material parameters for ZnSe or ZnS.

    Parameters
    ----------
    mat_flag:
        Material selector: 1 for ZnSe and 2 for ZnS.
    wavelength_um:
        Vacuum wavelength in micrometers.

    Returns
    -------
    n0:
        Linear refractive index.
    n2:
        Nonlinear refractive index in m^2/W.
    Eg_J:
        Bandgap energy in joules.
    mred:
        Reduced electron-hole effective mass in kilograms.
    trans:
        Approximate transmission factor, 1 - R.

    Raises
    ------
    ValueError
        If the material flag is not 1 or 2, or if the Sellmeier expression
        becomes nonphysical at the requested wavelength.
    """

    lam = float(wavelength_um)
    if lam <= 0.0:
        raise ValueError("wavelength_um must be positive.")

    if mat_flag == 1:
        bandgap_ev = 2.7
        mred = 0.17 * ME0
        n_squared = (
            1.0
            + 4.45813734 * lam**2 / (lam**2 - 0.200859853**2)
            + 0.467216334 * lam**2 / (lam**2 - 0.391371166**2)
            + 2.89566290 * lam**2 / (lam**2 - 47.1362108**2)
        )
        if lam < 2.0:
            n2 = 2.3e-18
            reflectance = 0.32949
        else:
            n2 = 6.5e-19
            reflectance = 0.31059

    elif mat_flag == 2:
        bandgap_ev = 3.60
        mred = 0.34 * ME0
        n_squared = (
            8.393
            + 0.14383 / (lam**2 - 0.2421**2)
            + 4430.99 / (lam**2 - 36.71**2)
        )
        if lam < 2.0:
            n2 = 6.8e-19
            reflectance = 0.38251
        else:
            n2 = 4.0e-19
            reflectance = 0.26693

    else:
        raise ValueError("mat_flag must be 1 for ZnSe or 2 for ZnS.")

    if not np.isfinite(n_squared) or n_squared <= 0.0:
        raise ValueError(
            f"Nonphysical Sellmeier result n^2={n_squared!r} at {lam} um."
        )

    n0 = np.sqrt(n_squared)
    Eg_J = bandgap_ev * E_CHARGE
    trans = 1.0 - reflectance

    return float(n0), float(n2), float(Eg_J), float(mred), float(trans)


# ============================================================
# Case definitions
# ============================================================

def get_cases() -> List[CaseDict]:
    """
    Return the default ZnSe/ZnS NIR and LWIR LIDT cases.

    Returns
    -------
    list of dict
        Four material/laser case dictionaries.
    """

    return [
        {
            "name": r"ZnSe, 0.8 $\mu$m",
            "short": "ZnSe_NIR",
            "material": "ZnSe",
            "region": "NIR",
            "mat_flag": 1,
            "wavelength_um": 0.8,
            "tau_fs": 100.0,
            "F0_jcm2": 0.112,
        },
        {
            "name": r"ZnS, 0.8 $\mu$m",
            "short": "ZnS_NIR",
            "material": "ZnS",
            "region": "NIR",
            "mat_flag": 2,
            "wavelength_um": 0.8,
            "tau_fs": 100.0,
            "F0_jcm2": 0.170,
        },
        {
            "name": r"ZnSe, 9.2 $\mu$m",
            "short": "ZnSe_LWIR",
            "material": "ZnSe",
            "region": "LWIR",
            "mat_flag": 1,
            "wavelength_um": 9.2,
            "tau_fs": 2000.0,
            "F0_jcm2": 0.83,
        },
        {
            "name": r"ZnS, 9.2 $\mu$m",
            "short": "ZnS_LWIR",
            "material": "ZnS",
            "region": "LWIR",
            "mat_flag": 2,
            "wavelength_um": 9.2,
            "tau_fs": 2000.0,
            "F0_jcm2": 1.19,
        },
    ]


# ============================================================
# Laser pulse conversion
# ============================================================

def peak_intensity_from_fluence_wm2(F0_jcm2: float, tau_fs: float) -> float:
    """
    Convert peak fluence to peak intensity for a Gaussian temporal pulse.

    For a Gaussian intensity envelope with FWHM duration tau,

        I0 = (2 F0 / tau) sqrt[ln(2)/pi].

    Parameters
    ----------
    F0_jcm2:
        Peak fluence in J/cm^2.
    tau_fs:
        Intensity FWHM duration in femtoseconds.

    Returns
    -------
    float
        Peak intensity in W/m^2.
    """

    F0_jm2 = float(F0_jcm2) * 1.0e4
    tau_s = float(tau_fs) * 1.0e-15

    if F0_jm2 < 0.0:
        raise ValueError("Fluence must be nonnegative.")
    if tau_s <= 0.0:
        raise ValueError("Pulse duration must be positive.")

    return float((2.0 * F0_jm2 / tau_s) * np.sqrt(np.log(2.0) / np.pi))


def gaussian_intensity_time(t_s: float, I0_wm2: float, tau_s: float) -> float:
    """
    Evaluate a Gaussian temporal intensity profile.

    The profile is

        I(t) = I0 exp[-4 ln(2) (t/tau)^2],

    where tau is the intensity FWHM duration.

    Parameters
    ----------
    t_s:
        Time in seconds.
    I0_wm2:
        Peak intensity in W/m^2.
    tau_s:
        Intensity FWHM duration in seconds.

    Returns
    -------
    float
        Instantaneous intensity in W/m^2.
    """

    if tau_s <= 0.0:
        raise ValueError("tau_s must be positive.")

    return float(I0_wm2 * np.exp(-4.0 * np.log(2.0) * (t_s / tau_s) ** 2))


# ============================================================
# Keldysh photoionization model
# ============================================================

def qfun_keldysh(
    gamma: np.ndarray,
    x: np.ndarray,
    Kg: np.ndarray,
    Eg: np.ndarray,
    K1: np.ndarray,
    E1: np.ndarray,
    tol: float = 1.0e-3,
    max_terms: int = 10000,
) -> np.ndarray:
    """
    Evaluate the Keldysh Q-function series.

    Parameters
    ----------
    gamma:
        Keldysh parameter array.
    x:
        Effective photon-order argument.
    Kg, Eg, K1, E1:
        Complete elliptic-integral terms appearing in the Keldysh expression.
    tol:
        Absolute change in the partial sum used as the convergence criterion.
    max_terms:
        Maximum number of series terms.

    Returns
    -------
    np.ndarray
        Keldysh Q-function values.
    """

    gamma = np.atleast_1d(np.asarray(gamma, dtype=float))
    x = np.atleast_1d(np.asarray(x, dtype=float))
    Kg = np.atleast_1d(np.asarray(Kg, dtype=float))
    Eg = np.atleast_1d(np.asarray(Eg, dtype=float))
    K1 = np.atleast_1d(np.asarray(K1, dtype=float))
    E1 = np.atleast_1d(np.asarray(E1, dtype=float))

    arrays = [gamma, x, Kg, Eg, K1, E1]
    if len({arr.size for arr in arrays}) != 1:
        raise ValueError("All qfun_keldysh input arrays must have the same size.")

    q_values = np.zeros_like(gamma)

    for i in range(gamma.size):
        values = [gamma[i], x[i], Kg[i], Eg[i], K1[i], E1[i]]
        if not all(np.isfinite(v) for v in values) or K1[i] <= 0.0 or E1[i] <= 0.0:
            continue

        q_prefactor = np.sqrt(np.pi / (2.0 * K1[i]))
        q_sum = 0.0

        for j in range(max_terms):
            old_sum = q_sum
            exponent = -np.pi * (Kg[i] - Eg[i]) * j / E1[i]
            arg_inside = (
                np.pi**2
                * (2.0 * np.floor(x[i] + 1.0) - 2.0 * x[i] + j)
                / (2.0 * K1[i] * E1[i])
            )
            arg_inside = max(float(arg_inside), 0.0)

            with np.errstate(over="ignore", invalid="ignore", under="ignore"):
                term = np.exp(exponent) * dawsn(np.sqrt(arg_inside))

            if not np.isfinite(term):
                term = 0.0

            q_sum += float(term)

            if abs(q_sum - old_sum) <= tol:
                break

        q_values[i] = q_prefactor * q_sum

    return np.nan_to_num(q_values, nan=0.0, posinf=0.0, neginf=0.0)


def keldysh_full_rate_m3_s(
    omega: float,
    mred: float,
    delta_J: float,
    n0: float,
    intensity_wm2: ArrayLike,
) -> ArrayLike:
    """
    Evaluate the full Keldysh photoionization rate.

    Parameters
    ----------
    omega:
        Laser angular frequency in rad/s.
    mred:
        Reduced electron-hole effective mass in kg.
    delta_J:
        Bandgap energy in J.
    n0:
        Linear refractive index.
    intensity_wm2:
        Scalar or array of laser intensities in W/m^2.

    Returns
    -------
    float or np.ndarray
        Photoionization rate in m^-3 s^-1.
    """

    intensity = np.asarray(intensity_wm2, dtype=float)
    scalar_input = intensity.ndim == 0
    intensity = np.atleast_1d(intensity)

    rate = np.zeros_like(intensity)
    positive = np.isfinite(intensity) & (intensity > 0.0)

    if np.any(positive):
        I = intensity[positive]

        with np.errstate(divide="ignore", invalid="ignore", over="ignore", under="ignore"):
            electric_field = np.sqrt((2.0 * I) / (C0 * n0 * EPS0))
            gamma = (omega / (E_CHARGE * electric_field)) * np.sqrt(mred * delta_J)
            gamma_sq = gamma**2

            gg = gamma_sq / (1.0 + gamma_sq)
            g1 = 1.0 / (1.0 + gamma_sq)

            Kg = ellipk(gg)
            Eg = ellipe(gg)
            K1 = ellipk(g1)
            E1 = ellipe(g1)

            delta_tilde = (
                2.0
                * delta_J
                * np.sqrt(1.0 + gamma_sq)
                * E1
                / (np.pi * gamma)
            )
            x_order = delta_tilde / (HBAR * omega)
            X = np.floor(x_order + 1.0)

            prefactor = (
                2.0
                * omega
                / (9.0 * np.pi)
                * (
                    (np.sqrt(1.0 + gamma_sq) * mred * omega)
                    / (gamma * HBAR)
                )
                ** 1.5
            )

            q_values = qfun_keldysh(gamma, x_order, Kg, Eg, K1, E1)
            exponential = np.exp(-np.pi * X * (Kg - Eg) / E1)
            rate_positive = prefactor * q_values * exponential

        rate[positive] = np.nan_to_num(
            rate_positive,
            nan=0.0,
            posinf=0.0,
            neginf=0.0,
        )

    if scalar_input:
        return float(rate[0])
    return rate


# ============================================================
# Avalanche / impact-ionization model
# ============================================================

def collision_time_s(ne_m3: float, mred: float, delta_J: float) -> float:
    """
    Evaluate the electron collision time used in the Drude model.

    Parameters
    ----------
    ne_m3:
        Conduction-band electron density in m^-3.
    mred:
        Reduced electron-hole effective mass in kg.
    delta_J:
        Bandgap energy in J.

    Returns
    -------
    float
        Collision time in seconds. Returns infinity at zero density.
    """

    ne = max(float(ne_m3), 0.0)
    if ne <= 0.0:
        return np.inf

    numerator = 16.0 * np.pi * EPS0**2 * np.sqrt(mred * (0.1 * delta_J) ** 3)
    denominator = np.sqrt(2.0) * E_CHARGE**4 * ne
    tau_c = numerator / denominator

    if not np.isfinite(tau_c) or tau_c <= 0.0:
        return np.inf

    return float(tau_c)


def drude_cross_section_m2(
    omega: float,
    mred: float,
    n0: float,
    tau_c_s: float,
) -> float:
    """
    Evaluate the Drude single-photon absorption cross section safely.

    The direct expression is

        sigma = e^2/(c eps0 n0 m_r) * tau_C/(1 + omega^2 tau_C^2).

    To avoid overflow for very large collision times, it is evaluated as

        sigma = [e^2/(c eps0 n0 m_r)] / omega
                * [(omega tau_C)/(1 + (omega tau_C)^2)].

    Parameters
    ----------
    omega:
        Angular frequency in rad/s.
    mred:
        Reduced electron-hole effective mass in kg.
    n0:
        Linear refractive index.
    tau_c_s:
        Collision time in seconds.

    Returns
    -------
    float
        Drude absorption cross section in m^2.
    """

    tau_c = float(tau_c_s)

    if (
        not np.isfinite(tau_c)
        or tau_c <= 0.0
        or not np.isfinite(omega)
        or omega <= 0.0
        or mred <= 0.0
        or n0 <= 0.0
    ):
        return 0.0

    prefactor = E_CHARGE**2 / (C0 * EPS0 * n0 * mred)
    x = omega * tau_c

    if not np.isfinite(x) or x <= 0.0:
        return 0.0

    if x > 1.0e100:
        drude_factor = 1.0 / x
    else:
        drude_factor = x / (1.0 + x * x)

    sigma = (prefactor / omega) * drude_factor

    if not np.isfinite(sigma) or sigma < 0.0:
        return 0.0

    return float(sigma)


def avalanche_generation_rate_m3_s(
    intensity_wm2: float,
    ne_m3: float,
    omega: float,
    mred: float,
    delta_J: float,
    n0: float,
) -> float:
    """
    Evaluate the avalanche/impact-ionization carrier-generation rate.

    The implemented relation is

        W_av = (sigma I / E_g) n_e.

    Parameters
    ----------
    intensity_wm2:
        Instantaneous laser intensity in W/m^2.
    ne_m3:
        Instantaneous electron density in m^-3.
    omega:
        Laser angular frequency in rad/s.
    mred:
        Reduced electron-hole effective mass in kg.
    delta_J:
        Bandgap energy in J.
    n0:
        Linear refractive index.

    Returns
    -------
    float
        Avalanche generation rate in m^-3 s^-1.
    """

    I = max(float(intensity_wm2), 0.0)
    ne = max(float(ne_m3), 0.0)

    if I <= 0.0 or ne <= 0.0 or delta_J <= 0.0:
        return 0.0

    tau_c = collision_time_s(ne, mred, delta_J)
    sigma = drude_cross_section_m2(
        omega=omega,
        mred=mred,
        n0=n0,
        tau_c_s=tau_c,
    )

    if sigma <= 0.0:
        return 0.0

    W_av = (sigma * I / delta_J) * ne

    if not np.isfinite(W_av) or W_av < 0.0:
        return 0.0

    return float(W_av)


# ============================================================
# General helpers
# ============================================================

def positive_for_log(y: np.ndarray, min_value: float = 1.0e-300) -> np.ndarray:
    """
    Replace nonfinite and nonpositive values with NaN for logarithmic plotting.
    """

    y_plot = np.asarray(y, dtype=float).copy()
    y_plot[~np.isfinite(y_plot)] = np.nan
    y_plot[y_plot <= min_value] = np.nan
    return y_plot


def case_lidt_peak_intensity_wcm2(case: CaseDict) -> float:
    """
    Return the Gaussian peak intensity at the measured LIDT in W/cm^2.
    """

    return (
        peak_intensity_from_fluence_wm2(
            F0_jcm2=case["F0_jcm2"],
            tau_fs=case["tau_fs"],
        )
        * WCM2_PER_WM2
    )


def interpolate_log_y(
    x: np.ndarray,
    y: np.ndarray,
    x0: float,
) -> Optional[float]:
    """
    Interpolate y(x0) in log-log space.

    Returns None when x0 lies outside the valid positive data range.
    """

    x_arr = np.asarray(x, dtype=float)
    y_arr = np.asarray(y, dtype=float)
    valid = np.isfinite(x_arr) & np.isfinite(y_arr) & (x_arr > 0.0) & (y_arr > 0.0)

    if np.count_nonzero(valid) < 2:
        return None

    x_valid = x_arr[valid]
    y_valid = y_arr[valid]
    order = np.argsort(x_valid)
    x_valid = x_valid[order]
    y_valid = y_valid[order]

    if x0 < x_valid[0] or x0 > x_valid[-1]:
        return None

    log_y0 = np.interp(
        np.log10(x0),
        np.log10(x_valid),
        np.log10(y_valid),
    )
    return float(10.0**log_y0)


def save_or_show(
    fig: plt.Figure,
    save_dir: Optional[Path],
    filename: str,
    apply_tight_layout: bool = True,
) -> None:
    """
    Apply tight layout and either save or display a Matplotlib figure.
    """

    # CODEX MODIFICATION START: allow manually arranged 3D figures
    if apply_tight_layout:
        fig.tight_layout()
    # CODEX MODIFICATION END: allow manually arranged 3D figures

    if save_dir is not None:
        save_dir.mkdir(parents=True, exist_ok=True)
        output_path = save_dir / filename
        fig.savefig(output_path, dpi=300, bbox_inches="tight")
        print(f"Saved {output_path}")
        # CODEX MODIFICATION START: optional open saved image preview
        if OPEN_SAVED_FIGURES and hasattr(os, "startfile"):
            os.startfile(output_path)
        # CODEX MODIFICATION END: optional open saved image preview
        # CODEX MODIFICATION START: optional editable figure exports
        if SAVE_EDITABLE_FIGURES:
            editable_path = output_path.with_suffix(".mplfig.pkl")
            with editable_path.open("wb") as editable_file:
                pickle.dump(fig, editable_file)
            print(f"Saved editable Matplotlib figure {editable_path}")
        # CODEX MODIFICATION END: optional editable figure exports
        # CODEX MODIFICATION START: allow saved figures to display at end
        if DEFER_FIGURE_SHOW:
            print(f"Prepared saved figure for display: {filename}")
        else:
            plt.close(fig)
        # CODEX MODIFICATION END: allow saved figures to display at end
    else:
        # CODEX MODIFICATION START: optional deferred Matplotlib display
        if DEFER_FIGURE_SHOW:
            print(f"Prepared figure for display: {filename}")
        else:
            plt.show()
        # CODEX MODIFICATION END: optional deferred Matplotlib display


# ============================================================
# Time-dependent dynamics
# ============================================================

def solve_dynamics_from_peak_intensity(
    case: CaseDict,
    I0_wcm2: float,
    n_time_points: int = 1000,
) -> Dict[str, Any]:
    """
    Solve total carrier-density dynamics at a specified peak intensity.

    Parameters
    ----------
    case:
        Material/laser case dictionary.
    I0_wcm2:
        Peak laser intensity in W/cm^2.
    n_time_points:
        Number of points used for post-processing the dense ODE solution.

    Returns
    -------
    dict
        Time-dependent photoionization, avalanche, total rates, and density.
    """

    if I0_wcm2 < 0.0:
        raise ValueError("I0_wcm2 must be nonnegative.")
    if n_time_points < 2:
        raise ValueError("n_time_points must be at least 2.")

    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    tau_s = float(case["tau_fs"]) * 1.0e-15
    I0_wm2 = float(I0_wcm2) * WM2_PER_WCM2

    n0, _n2, Eg_J, mred, _trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )

    t0 = -3.0 * tau_s
    t1 = +3.0 * tau_s

    def intensity_at_time(t: float) -> float:
        return gaussian_intensity_time(t, I0_wm2, tau_s)

    def photo_rate_at_time(t: float) -> float:
        return float(
            keldysh_full_rate_m3_s(
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
                intensity_wm2=intensity_at_time(t),
            )
        )

    def rhs_total(t: float, y: np.ndarray) -> List[float]:
        ne = max(float(y[0]), 0.0)
        I_now = intensity_at_time(t)
        W_pi = photo_rate_at_time(t)
        W_av = avalanche_generation_rate_m3_s(
            intensity_wm2=I_now,
            ne_m3=ne,
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
        )

        derivative = W_pi + W_av
        if not np.isfinite(derivative) or derivative < 0.0:
            derivative = 0.0

        return [float(derivative)]

    solution = solve_ivp(
        rhs_total,
        (t0, t1),
        y0=[0.0],
        method="BDF",
        rtol=1.0e-5,
        atol=1.0e6,
        max_step=tau_s / 350.0,
        dense_output=True,
    )

    t_eval = np.linspace(t0, t1, n_time_points)

    if solution.sol is not None:
        ne = np.maximum(solution.sol(t_eval)[0], 0.0)
    else:
        ne = np.maximum(np.interp(t_eval, solution.t, solution.y[0]), 0.0)

    intensity = np.asarray([intensity_at_time(t) for t in t_eval], dtype=float)
    Wpi = np.asarray([photo_rate_at_time(t) for t in t_eval], dtype=float)
    Wav = np.asarray(
        [
            avalanche_generation_rate_m3_s(
                intensity_wm2=I_now,
                ne_m3=ne_now,
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
            )
            for I_now, ne_now in zip(intensity, ne)
        ],
        dtype=float,
    )
    Wtotal = Wpi + Wav

    return {
        "case": case,
        "t_s": t_eval,
        "intensity_wm2": intensity,
        "Wpi_m3_s": Wpi,
        "Wav_m3_s": Wav,
        "Wtotal_m3_s": Wtotal,
        "Wpi_cm3_fs": Wpi * RATE_CM3_FS_PER_M3_S,
        "Wav_cm3_fs": Wav * RATE_CM3_FS_PER_M3_S,
        "Wtotal_cm3_fs": Wtotal * RATE_CM3_FS_PER_M3_S,
        "ne_m3": ne,
        "ne_cm3": ne * CM3_PER_M3,
        "solver_success": bool(solution.success),
        "solver_message": str(solution.message),
    }


SCALING_CACHE: Dict[Tuple[str, int, float, float, int], Dict[str, np.ndarray]] = {}


def compute_case_scaling(
    case: CaseDict,
    I_values_wcm2: np.ndarray,
    n_time_points: int = 600,
) -> Dict[str, np.ndarray]:
    """
    Compute the peak total ionization rate versus peak laser intensity.

    Parameters
    ----------
    case:
        Material/laser case dictionary.
    I_values_wcm2:
        One-dimensional array of peak intensities in W/cm^2.
    n_time_points:
        Number of post-processing time points per ODE solution.

    Returns
    -------
    dict
        Intensity array and peak total ionization-rate array.
    """

    intensity_values = np.asarray(I_values_wcm2, dtype=float)

    if intensity_values.ndim != 1 or intensity_values.size == 0:
        raise ValueError("I_values_wcm2 must be a nonempty one-dimensional array.")
    if np.any(~np.isfinite(intensity_values)) or np.any(intensity_values <= 0.0):
        raise ValueError("All intensity values must be finite and positive.")

    cache_key = (
        str(case["short"]),
        int(intensity_values.size),
        float(intensity_values[0]),
        float(intensity_values[-1]),
        int(n_time_points),
    )

    if cache_key in SCALING_CACHE:
        return SCALING_CACHE[cache_key]

    Wtotal_peak = np.zeros_like(intensity_values)
    print(f"\nComputing intensity scaling for {case['short']} ...")

    report_interval = max(1, intensity_values.size // 10)

    for index, I0_wcm2 in enumerate(intensity_values):
        if index % report_interval == 0 or index == intensity_values.size - 1:
            print(
                f"  {index + 1:3d}/{intensity_values.size}: "
                f"I0 = {I0_wcm2:.3e} W/cm^2"
            )

        result = solve_dynamics_from_peak_intensity(
            case=case,
            I0_wcm2=float(I0_wcm2),
            n_time_points=n_time_points,
        )

        if not result["solver_success"]:
            print(
                f"  WARNING: solver for {case['short']} at "
                f"{I0_wcm2:.3e} W/cm^2 reported: {result['solver_message']}"
            )

        Wtotal_peak[index] = np.nanmax(
            np.nan_to_num(
                result["Wtotal_cm3_fs"],
                nan=0.0,
                posinf=0.0,
                neginf=0.0,
            )
        )

    output = {
        "I_wcm2": intensity_values,
        "Wtotal_peak_cm3_fs": Wtotal_peak,
    }
    SCALING_CACHE[cache_key] = output
    return output


def solve_density_case(case: CaseDict) -> Dict[str, Any]:
    """
    Solve photoionization-only and photoionization-plus-avalanche density growth.

    Parameters
    ----------
    case:
        Material/laser case dictionary.

    Returns
    -------
    dict
        Material parameters, peak intensity, final densities, and solver status.
    """

    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    tau_s = float(case["tau_fs"]) * 1.0e-15
    I0_wm2 = peak_intensity_from_fluence_wm2(
        F0_jcm2=float(case["F0_jcm2"]),
        tau_fs=float(case["tau_fs"]),
    )

    n0, n2, Eg_J, mred, trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )

    t0 = -3.0 * tau_s
    t1 = +3.0 * tau_s

    def intensity_at_time(t: float) -> float:
        return gaussian_intensity_time(t, I0_wm2, tau_s)

    def photo_rate_at_time(t: float) -> float:
        return float(
            keldysh_full_rate_m3_s(
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
                intensity_wm2=intensity_at_time(t),
            )
        )

    def rhs_photo(t: float, _y: np.ndarray) -> List[float]:
        return [photo_rate_at_time(t)]

    def rhs_total(t: float, y: np.ndarray) -> List[float]:
        ne = max(float(y[0]), 0.0)
        I_now = intensity_at_time(t)
        W_pi = photo_rate_at_time(t)
        W_av = avalanche_generation_rate_m3_s(
            intensity_wm2=I_now,
            ne_m3=ne,
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
        )
        derivative = W_pi + W_av
        return [float(max(derivative, 0.0)) if np.isfinite(derivative) else 0.0]

    photo_solution = solve_ivp(
        rhs_photo,
        (t0, t1),
        y0=[0.0],
        method="RK45",
        rtol=1.0e-6,
        atol=1.0e6,
        max_step=tau_s / 200.0,
    )

    total_solution = solve_ivp(
        rhs_total,
        (t0, t1),
        y0=[0.0],
        method="BDF",
        rtol=1.0e-6,
        atol=1.0e6,
        max_step=tau_s / 500.0,
    )

    ne_photo_final_m3 = float(max(photo_solution.y[0, -1], 0.0))
    ne_total_final_m3 = float(max(total_solution.y[0, -1], 0.0))

    return {
        "case": case,
        "n0": n0,
        "n2": n2,
        "trans": trans,
        "Eg_eV": Eg_J / E_CHARGE,
        "mred_over_me": mred / ME0,
        "I0_wm2": I0_wm2,
        "I0_wcm2": I0_wm2 * WCM2_PER_WM2,
        "ne_photo_m3": ne_photo_final_m3,
        "ne_total_m3": ne_total_final_m3,
        "ne_photo_cm3": ne_photo_final_m3 * CM3_PER_M3,
        "ne_total_cm3": ne_total_final_m3 * CM3_PER_M3,
        "ne_avalanche_added_cm3": (
            max(ne_total_final_m3 - ne_photo_final_m3, 0.0) * CM3_PER_M3
        ),
        "sol_photo_success": bool(photo_solution.success),
        "sol_photo_message": str(photo_solution.message),
        "sol_total_success": bool(total_solution.success),
        "sol_total_message": str(total_solution.message),
    }


# ============================================================
# Summary table
# ============================================================

def build_summary_table(results: Sequence[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Convert density-solver results into rows for display.
    """

    rows: List[Dict[str, Any]] = []

    for result in results:
        case = result["case"]
        rows.append(
            {
                "Case": case["short"],
                "Material": case["material"],
                "Regime": case["region"],
                "lambda_um": case["wavelength_um"],
                "tau_fs": case["tau_fs"],
                "F0_Jcm2": case["F0_jcm2"],
                "I0_Wcm2": result["I0_wcm2"],
                "n_photo_cm3": result["ne_photo_cm3"],
                "n_avalanche_added_cm3": result["ne_avalanche_added_cm3"],
                "n_total_cm3": result["ne_total_cm3"],
                "n0": result["n0"],
                "Eg_eV": result["Eg_eV"],
                "mred_over_me": result["mred_over_me"],
                "solver": (
                    "OK"
                    if result["sol_photo_success"] and result["sol_total_success"]
                    else "CHECK"
                ),
            }
        )

    return rows


def display_summary_table(rows: Sequence[Dict[str, Any]]) -> None:
    """
    Display the density-growth summary table in Jupyter or plain text.
    """

    print("\n================ Density-growth summary table ================\n")

    if pd is None:
        for row in rows:
            print(row)
        return

    dataframe = pd.DataFrame(rows)
    display_frame = dataframe.copy()

    scientific_columns = [
        "I0_Wcm2",
        "n_photo_cm3",
        "n_avalanche_added_cm3",
        "n_total_cm3",
    ]
    compact_columns = [
        "lambda_um",
        "tau_fs",
        "F0_Jcm2",
        "n0",
        "Eg_eV",
        "mred_over_me",
    ]

    for column in scientific_columns:
        display_frame[column] = display_frame[column].map(lambda value: f"{value:.4e}")

    for column in compact_columns:
        display_frame[column] = display_frame[column].map(lambda value: f"{value:.4g}")

    if ipython_display is not None:
        ipython_display(display_frame)
    else:
        print(display_frame.to_string(index=False))


# ============================================================
# First graph set: Keldysh photoionization curves
# ============================================================

def plot_keldysh_rate_curves(
    cases: Sequence[CaseDict],
    save_dir: Optional[Path] = None,
) -> None:
    """
    Plot Keldysh photoionization-rate curves for all default cases.

    The measured LIDT peak intensity is marked by a black cross.
    """

    I_values_wm2 = np.logspace(14, 19, 900)
    fig, axes = plt.subplots(2, 2, figsize=(12, 8))
    axes_flat = axes.ravel()

    for ax, case in zip(axes_flat, cases):
        wavelength_um = float(case["wavelength_um"])
        omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
        n0, _n2, Eg_J, mred, _trans = material_flag1(
            mat_flag=int(case["mat_flag"]),
            wavelength_um=wavelength_um,
        )

        Wpi = np.asarray(
            keldysh_full_rate_m3_s(
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
                intensity_wm2=I_values_wm2,
            ),
            dtype=float,
        )

        keep = np.isfinite(Wpi) & (Wpi > 0.0)

        ax.loglog(
            I_values_wm2[keep],
            Wpi[keep],
            linewidth=2.4,
            label=r"$W_{\rm PI}$",
        )

        I_lidt_wm2 = case_lidt_peak_intensity_wcm2(case) * WM2_PER_WCM2

        if np.any(keep):
            W_lidt = interpolate_log_y(
                x=I_values_wm2[keep],
                y=Wpi[keep],
                x0=I_lidt_wm2,
            )
            if W_lidt is not None:
                ax.plot(
                    I_lidt_wm2,
                    W_lidt,
                    "kx",
                    markersize=9,
                    markeredgewidth=2,
                    label=r"$I_0$ at LIDT",
                )

        ax.set_title(case["name"])
        ax.set_xlabel(r"Laser intensity $I$ (W/m$^2$)")
        ax.set_ylabel(r"$W_{\rm PI}$ (m$^{-3}$ s$^{-1}$)")
        ax.grid(True, which="both", alpha=0.25)
        ax.legend(frameon=False)

    for ax in axes_flat[len(cases):]:
        ax.set_visible(False)

    fig.suptitle("Keldysh photoionization-rate curves", fontsize=15)
    save_or_show(
        fig=fig,
        save_dir=save_dir,
        filename="01_first_graph_set_keldysh_rate_curves.png",
    )


# ============================================================
# ZnS-reference Keldysh parameter axis
# ============================================================

def gamma_zns_reference_from_intensity_wcm2(
    I_wcm2: ArrayLike,
    wavelength_um: float,
    include_field_factor_two: bool = False,
) -> ArrayLike:
    """
    Evaluate the Keldysh parameter using ZnS as the reference material.

    Parameters
    ----------
    I_wcm2:
        Scalar or array of intensities in W/cm^2.
    wavelength_um:
        Wavelength in micrometers.
    include_field_factor_two:
        If True, include the factor of two associated with
        I = (1/2) c n eps0 E^2 in the denominator.

    Returns
    -------
    float or np.ndarray
        Keldysh parameter values.
    """

    intensity = np.asarray(I_wcm2, dtype=float)
    scalar_input = intensity.ndim == 0
    intensity = np.atleast_1d(intensity)

    gamma = np.full_like(intensity, np.inf)
    valid = np.isfinite(intensity) & (intensity > 0.0)

    if np.any(valid):
        I_wm2 = intensity[valid] * WM2_PER_WCM2
        n_zns, _n2, Eg_zns_J, mred_zns, _trans = material_flag1(2, wavelength_um)
        omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
        field_factor = 2.0 if include_field_factor_two else 1.0

        with np.errstate(divide="ignore", invalid="ignore", over="ignore"):
            gamma_valid = (omega / E_CHARGE) * np.sqrt(
                (mred_zns * C0 * n_zns * EPS0 * Eg_zns_J)
                / (field_factor * I_wm2)
            )

        gamma[valid] = np.nan_to_num(
            gamma_valid,
            nan=np.inf,
            posinf=np.inf,
            neginf=np.inf,
        )

    if scalar_input:
        return float(gamma[0])
    return gamma


def intensity_wcm2_from_gamma_zns_reference(
    gamma: ArrayLike,
    wavelength_um: float,
    include_field_factor_two: bool = False,
) -> ArrayLike:
    """
    Convert a ZnS-reference Keldysh parameter to intensity in W/cm^2.
    """

    gamma_values = np.asarray(gamma, dtype=float)
    scalar_input = gamma_values.ndim == 0
    gamma_values = np.atleast_1d(gamma_values)

    intensity = np.full_like(gamma_values, np.inf)
    valid = np.isfinite(gamma_values) & (gamma_values > 0.0)

    if np.any(valid):
        n_zns, _n2, Eg_zns_J, mred_zns, _trans = material_flag1(2, wavelength_um)
        omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
        field_factor = 2.0 if include_field_factor_two else 1.0

        with np.errstate(divide="ignore", invalid="ignore", over="ignore"):
            I_wm2 = (
                (omega / E_CHARGE) ** 2
                * (mred_zns * C0 * n_zns * EPS0 * Eg_zns_J)
                / (field_factor * gamma_values[valid] ** 2)
            )

        intensity[valid] = I_wm2 * WCM2_PER_WM2

    if scalar_input:
        return float(intensity[0])
    return intensity


def add_zns_gamma_top_axis(
    ax: plt.Axes,
    wavelength_um: float,
    gamma_ticks: Tuple[float, ...],
    include_field_factor_two: bool = False,
) -> None:
    """
    Add a ZnS-reference Keldysh-parameter axis above an intensity axis.
    """

    ax_top = ax.twiny()
    ax_top.set_xscale("log")
    ax_top.set_xlim(ax.get_xlim())

    tick_positions = np.asarray(
        intensity_wcm2_from_gamma_zns_reference(
            gamma=np.asarray(gamma_ticks, dtype=float),
            wavelength_um=wavelength_um,
            include_field_factor_two=include_field_factor_two,
        ),
        dtype=float,
    )

    x_min, x_max = ax.get_xlim()
    valid_ticks: List[float] = []
    valid_labels: List[str] = []

    for gamma_value, tick_position in zip(gamma_ticks, tick_positions):
        if np.isfinite(tick_position) and x_min <= tick_position <= x_max:
            valid_ticks.append(float(tick_position))
            valid_labels.append(f"{gamma_value:g}")

    ax_top.set_xticks(valid_ticks)
    ax_top.set_xticklabels(valid_labels)
    ax_top.set_xlabel(r"Keldysh parameter $\gamma$ (ZnS reference)")
    ax_top.tick_params(axis="x", which="both", direction="in")


# ============================================================
# Last graph set: total ionization comparison
# ============================================================

def plot_total_ionization_nir_lwir_comparison_with_gamma_axis(
    cases: Sequence[CaseDict],
    n_intensity_points: int = 50,
    I_min_wcm2: float = 5.0e10,
    I_max_wcm2: float = 1.0e15,
    y_min: float = 1.0e0,
    y_max: float = 1.0e30,
    include_field_factor_two: bool = False,
    save_dir: Optional[Path] = None,
) -> None:
    """
    Plot peak total ionization rate for ZnSe and ZnS in NIR and LWIR.

    Each panel includes a ZnS-reference Keldysh-parameter top axis and a
    dashed vertical line at gamma = 1.
    """

    if n_intensity_points < 2:
        raise ValueError("n_intensity_points must be at least 2.")
    if I_min_wcm2 <= 0.0 or I_max_wcm2 <= I_min_wcm2:
        raise ValueError("Intensity limits must satisfy 0 < I_min < I_max.")

    I_values_wcm2 = np.logspace(
        np.log10(I_min_wcm2),
        np.log10(I_max_wcm2),
        n_intensity_points,
    )

    regime_order = ["NIR", "LWIR"]
    panel_labels = {"NIR": "(a) NIR", "LWIR": "(b) LWIR"}
    gamma_ticks_by_regime = {
        "NIR": (10.0, 3.0, 1.0, 0.3),
        "LWIR": (1.0, 0.3, 0.1),
    }
    material_order = {"ZnSe": 0, "ZnS": 1}

    fig, axes = plt.subplots(1, 2, figsize=(13.5, 5.2), sharey=True)

    print("\nCalculating NIR/LWIR total-ionization comparison ...\n")

    for ax, regime in zip(axes, regime_order):
        regime_cases = sorted(
            [case for case in cases if case["region"] == regime],
            key=lambda case: material_order.get(case["material"], 99),
        )

        if not regime_cases:
            raise ValueError(f"No cases were supplied for regime {regime!r}.")

        wavelength_um = float(regime_cases[0]["wavelength_um"])

        for case in regime_cases:
            print(f"  {regime}: {case['short']}")
            scaling = compute_case_scaling(
                case=case,
                I_values_wcm2=I_values_wcm2,
                n_time_points=600,
            )

            I = scaling["I_wcm2"]
            Wtotal = scaling["Wtotal_peak_cm3_fs"]

            ax.loglog(
                I,
                positive_for_log(Wtotal),
                linewidth=2.6,
                label=case["material"],
            )

            I_lidt = case_lidt_peak_intensity_wcm2(case)
            W_lidt = interpolate_log_y(I, Wtotal, I_lidt)

            if W_lidt is not None:
                ax.plot(
                    I_lidt,
                    W_lidt,
                    "kx",
                    markersize=8.5,
                    markeredgewidth=2.0,
                )

        I_gamma_1 = float(
            intensity_wcm2_from_gamma_zns_reference(
                gamma=1.0,
                wavelength_um=wavelength_um,
                include_field_factor_two=include_field_factor_two,
            )
        )

        if I_min_wcm2 <= I_gamma_1 <= I_max_wcm2:
            ax.axvline(
                I_gamma_1,
                color="k",
                linestyle="--",
                linewidth=1.7,
            )
            ax.text(
                I_gamma_1 * 1.12,
                y_max / 8.0,
                r"$\gamma=1$",
                fontsize=11,
                verticalalignment="center",
            )

        ax.text(
            0.03,
            0.90,
            panel_labels[regime],
            transform=ax.transAxes,
            fontsize=14,
            fontweight="bold",
        )
        ax.set_xlabel(r"Laser intensity $I$ (W/cm$^2$)")
        ax.set_xlim(I_min_wcm2, I_max_wcm2)
        ax.set_ylim(y_min, y_max)
        ax.grid(True, which="major", alpha=0.28)
        ax.grid(True, which="minor", alpha=0.14, linestyle=":")
        ax.legend(frameon=False, fontsize=14, loc="lower right")

        add_zns_gamma_top_axis(
            ax=ax,
            wavelength_um=wavelength_um,
            gamma_ticks=gamma_ticks_by_regime[regime],
            include_field_factor_two=include_field_factor_two,
        )

    axes[0].set_ylabel(
        r"Peak total ionization rate $W_{\rm total}$ (cm$^{-3}$ fs$^{-1}$)"
    )

    fig.suptitle(
        r"Total ionization including avalanche: "
        r"$W_{\rm total}=W_{\rm PI}+(\sigma I/E_g)n_e$",
        fontsize=14,
    )

    save_or_show(
        fig=fig,
        save_dir=save_dir,
        filename="02_last_graph_set_total_ionization_gamma_axis.png",
    )



# ============================================================
# ZnSe/ZnS plots 
# ============================================================

COMPONENT_SCALING_CACHE: Dict[
    Tuple[str, int, float, float, int], Dict[str, np.ndarray]
] = {}

SURFACE_DATA_CACHE: Dict[
    Tuple[str, int, int, float, float, float, float], Dict[str, np.ndarray]
] = {}


def normalize_curve(values: np.ndarray) -> np.ndarray:
    """Normalize a nonnegative curve to its maximum value."""

    array = np.asarray(values, dtype=float)
    array = np.nan_to_num(array, nan=0.0, posinf=0.0, neginf=0.0)
    maximum = float(np.max(array)) if array.size else 0.0
    if maximum <= 0.0:
        return np.zeros_like(array)
    return array / maximum


def compute_case_scaling_components(
    case: CaseDict,
    I_values_wcm2: np.ndarray,
    n_time_points: int = 700,
) -> Dict[str, np.ndarray]:
    """
    Compute peak photoionization, avalanche, total rates, and density.

    Parameters
    ----------
    case:
        Material/laser case dictionary.
    I_values_wcm2:
        Peak intensities in W/cm^2.
    n_time_points:
        Number of time samples used to post-process each ODE solution.

    Returns
    -------
    dict
        Arrays of peak W_PI, W_av, W_total, and maximum electron density.
    """

    intensities = np.asarray(I_values_wcm2, dtype=float)
    if intensities.ndim != 1 or intensities.size == 0:
        raise ValueError("I_values_wcm2 must be a nonempty one-dimensional array.")
    if np.any(~np.isfinite(intensities)) or np.any(intensities <= 0.0):
        raise ValueError("All intensities must be finite and positive.")

    cache_key = (
        str(case["short"]),
        int(intensities.size),
        float(intensities[0]),
        float(intensities[-1]),
        int(n_time_points),
    )
    if cache_key in COMPONENT_SCALING_CACHE:
        return COMPONENT_SCALING_CACHE[cache_key]

    Wpi_peak = np.zeros_like(intensities)
    Wav_peak = np.zeros_like(intensities)
    Wtotal_peak = np.zeros_like(intensities)
    ne_max = np.zeros_like(intensities)

    print(f"\nComputing rate-component scaling for {case['short']} ...")
    report_interval = max(1, intensities.size // 10)

    for index, I0_wcm2 in enumerate(intensities):
        if index % report_interval == 0 or index == intensities.size - 1:
            print(
                f"  {index + 1:3d}/{intensities.size}: "
                f"I0 = {I0_wcm2:.3e} W/cm^2"
            )

        result = solve_dynamics_from_peak_intensity(
            case=case,
            I0_wcm2=float(I0_wcm2),
            n_time_points=n_time_points,
        )

        if not result["solver_success"]:
            print(
                f"  WARNING: solver for {case['short']} at "
                f"{I0_wcm2:.3e} W/cm^2: {result['solver_message']}"
            )

        Wpi_peak[index] = np.nanmax(
            np.nan_to_num(result["Wpi_cm3_fs"], nan=0.0, posinf=0.0, neginf=0.0)
        )
        Wav_peak[index] = np.nanmax(
            np.nan_to_num(result["Wav_cm3_fs"], nan=0.0, posinf=0.0, neginf=0.0)
        )
        Wtotal_peak[index] = np.nanmax(
            np.nan_to_num(result["Wtotal_cm3_fs"], nan=0.0, posinf=0.0, neginf=0.0)
        )
        ne_max[index] = np.nanmax(
            np.nan_to_num(result["ne_cm3"], nan=0.0, posinf=0.0, neginf=0.0)
        )

    output = {
        "I_wcm2": intensities,
        "Wpi_peak_cm3_fs": Wpi_peak,
        "Wav_peak_cm3_fs": Wav_peak,
        "Wtotal_peak_cm3_fs": Wtotal_peak,
        "ne_max_cm3": ne_max,
    }
    COMPONENT_SCALING_CACHE[cache_key] = output
    return output


def _case_with_derived_labels(case: CaseDict) -> Dict[str, Any]:
    """Return case labels plus derived material/LIDT values for saved data."""

    wavelength_um = float(case["wavelength_um"])
    n0, n2, Eg_J, mred, trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )
    I_lidt_wcm2 = case_lidt_peak_intensity_wcm2(case)
    return {
        "short": str(case["short"]),
        "name": str(case["name"]),
        "material": str(case["material"]),
        "region": str(case["region"]),
        "mat_flag": int(case["mat_flag"]),
        "wavelength_um": wavelength_um,
        "tau_fs": float(case["tau_fs"]),
        "F0_jcm2": float(case["F0_jcm2"]),
        "I_lidt_wcm2": float(I_lidt_wcm2),
        "gamma_lidt_zns_reference": float(
            gamma_zns_reference_from_intensity_wcm2(I_lidt_wcm2, wavelength_um)
        ),
        "n0": float(n0),
        "n2_m2_W": float(n2),
        "Eg_eV": float(Eg_J / E_CHARGE),
        "mred_over_me": float(mred / ME0),
        "transmission_factor": float(trans),
    }


def compute_total_ionization_surface_data(
    case: CaseDict,
    n_intensity_points: int = 80,
    n_density_points: int = 80,
    I_min_wcm2: float = 1.0e10,
    I_max_wcm2: float = 1.0e15,
    ne_min_cm3: float = 1.0e10,
    ne_max_cm3: float = 1.0e22,
) -> Dict[str, np.ndarray]:
    """
    Compute 3D total-ionization surface arrays without plotting.

    This stores the same numerical quantities used by the 3D surface plot:
    I0 grid, electron-density grid, W_PI, W_av, W_total, and log10 axes.
    """

    if n_intensity_points < 2:
        raise ValueError("n_intensity_points must be at least 2.")
    if n_density_points < 2:
        raise ValueError("n_density_points must be at least 2.")
    if I_min_wcm2 <= 0.0 or I_max_wcm2 <= I_min_wcm2:
        raise ValueError("Require 0 < I_min_wcm2 < I_max_wcm2.")
    if ne_min_cm3 <= 0.0 or ne_max_cm3 <= ne_min_cm3:
        raise ValueError("Require 0 < ne_min_cm3 < ne_max_cm3.")

    cache_key = (
        str(case["short"]),
        int(n_intensity_points),
        int(n_density_points),
        float(I_min_wcm2),
        float(I_max_wcm2),
        float(ne_min_cm3),
        float(ne_max_cm3),
    )
    if cache_key in SURFACE_DATA_CACHE:
        return SURFACE_DATA_CACHE[cache_key]

    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    n0, _n2, Eg_J, mred, _trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )

    I_values_wcm2 = np.logspace(
        np.log10(I_min_wcm2),
        np.log10(I_max_wcm2),
        n_intensity_points,
    )
    ne_values_cm3 = np.logspace(
        np.log10(ne_min_cm3),
        np.log10(ne_max_cm3),
        n_density_points,
    )
    I_grid_wcm2, ne_grid_cm3 = np.meshgrid(I_values_wcm2, ne_values_cm3)
    I_grid_wm2 = I_grid_wcm2 * WM2_PER_WCM2
    ne_grid_m3 = ne_grid_cm3 / CM3_PER_M3

    Wpi_grid_m3_s = np.asarray(
        keldysh_full_rate_m3_s(
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
            intensity_wm2=I_grid_wm2,
        ),
        dtype=float,
    )

    Wav_grid_m3_s = np.zeros_like(I_grid_wm2)
    for row_index in range(I_grid_wm2.shape[0]):
        for column_index in range(I_grid_wm2.shape[1]):
            Wav_grid_m3_s[row_index, column_index] = avalanche_generation_rate_m3_s(
                intensity_wm2=I_grid_wm2[row_index, column_index],
                ne_m3=ne_grid_m3[row_index, column_index],
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
            )

    Wtotal_grid_cm3_fs = (Wpi_grid_m3_s + Wav_grid_m3_s) * RATE_CM3_FS_PER_M3_S
    Wtotal_grid_cm3_fs = np.maximum(
        np.nan_to_num(Wtotal_grid_cm3_fs, nan=0.0, posinf=0.0, neginf=0.0),
        1.0e-300,
    )

    output = {
        "I_values_wcm2": I_values_wcm2,
        "ne_values_cm3": ne_values_cm3,
        "I_grid_wcm2": I_grid_wcm2,
        "ne_grid_cm3": ne_grid_cm3,
        "log10_I_grid_wcm2": np.log10(I_grid_wcm2),
        "log10_ne_grid_cm3": np.log10(ne_grid_cm3),
        "Wpi_grid_cm3_fs": Wpi_grid_m3_s * RATE_CM3_FS_PER_M3_S,
        "Wav_grid_cm3_fs": Wav_grid_m3_s * RATE_CM3_FS_PER_M3_S,
        "Wtotal_grid_cm3_fs": Wtotal_grid_cm3_fs,
        "log10_Wtotal_grid_cm3_fs": np.log10(Wtotal_grid_cm3_fs),
    }
    SURFACE_DATA_CACHE[cache_key] = output
    return output


def save_pi_ii_14_plot_variables(
    cases: Sequence[CaseDict],
    output_dir: Path,
    component_n_intensity_points: int = 50,
    total_n_intensity_points: int = 50,
    surface_n_intensity_points: int = 50,
    surface_n_density_points: int = 80,
) -> None:
    """
    Save labeled variables used by the 14 PI/II plot panels.

    Saved files
    -----------
    pi_ii_14_variables.npz
        Machine-readable numpy arrays with explicit names.
    pi_ii_14_manifest.json
        Human-readable variable map, units, cases, and figure-panel usage.
    pi_ii_14_component_scaling_long.csv
        Long-table version of per-case W_PI/W_av/W_total/n_e scaling.
    pi_ii_14_total_comparison_long.csv
        Long-table version of the NIR/LWIR total-rate comparison.

    The data are also sufficient to start new 3D plots because W_PI, W_av,
    W_total, I0 grid, and n_e grid are saved for each case.
    """

    output_dir.mkdir(parents=True, exist_ok=True)

    component_I_values_wcm2 = np.logspace(10, 15, component_n_intensity_points)
    total_I_values_wcm2 = np.logspace(
        np.log10(5.0e10),
        np.log10(1.0e15),
        total_n_intensity_points,
    )

    arrays: Dict[str, np.ndarray] = {
        "component_scaling__I_wcm2": component_I_values_wcm2,
        "total_comparison__I_wcm2": total_I_values_wcm2,
    }
    component_rows: List[Dict[str, Any]] = []
    total_rows: List[Dict[str, Any]] = []
    component_manifest: Dict[str, Any] = {}
    total_manifest: Dict[str, Any] = {}
    surface_manifest: Dict[str, Any] = {}

    print("\nSaving labeled variables for the 14 PI/II plot panels ...")

    for case in cases:
        case_label = _case_with_derived_labels(case)
        short = case_label["short"]
        wavelength_um = float(case["wavelength_um"])

        component = compute_case_scaling_components(
            case=case,
            I_values_wcm2=component_I_values_wcm2,
            n_time_points=600,
        )
        component_manifest[short] = {
            "used_by": [
                f"gruzdev_fig2_{short}.png: panels (a) and (b)",
                f"gruzdev_fig4_{case['material']}.png: material comparison panel(s)",
            ],
            "arrays": {},
        }
        for name, values in component.items():
            array_name = f"component__{short}__{name}"
            arrays[array_name] = np.asarray(values, dtype=float)
            component_manifest[short]["arrays"][name] = array_name

        gamma_component = np.asarray(
            gamma_zns_reference_from_intensity_wcm2(
                component["I_wcm2"],
                wavelength_um,
            ),
            dtype=float,
        )
        arrays[f"component__{short}__gamma_zns_reference"] = gamma_component
        component_manifest[short]["arrays"][
            "gamma_zns_reference"
        ] = f"component__{short}__gamma_zns_reference"

        for index, I_value in enumerate(component["I_wcm2"]):
            row = {
                **case_label,
                "dataset": "component_scaling",
                "point_index": index,
                "I_wcm2": float(I_value),
                "gamma_zns_reference": float(gamma_component[index]),
                "Wpi_peak_cm3_fs": float(component["Wpi_peak_cm3_fs"][index]),
                "Wav_peak_cm3_fs": float(component["Wav_peak_cm3_fs"][index]),
                "Wtotal_peak_cm3_fs": float(component["Wtotal_peak_cm3_fs"][index]),
                "ne_max_cm3": float(component["ne_max_cm3"][index]),
            }
            component_rows.append(row)

        total = compute_case_scaling(
            case=case,
            I_values_wcm2=total_I_values_wcm2,
            n_time_points=600,
        )
        total_manifest[short] = {
            "used_by": [
                "02_last_graph_set_total_ionization_gamma_axis.png",
            ],
            "arrays": {},
        }
        for name, values in total.items():
            array_name = f"total_comparison__{short}__{name}"
            arrays[array_name] = np.asarray(values, dtype=float)
            total_manifest[short]["arrays"][name] = array_name

        gamma_total = np.asarray(
            gamma_zns_reference_from_intensity_wcm2(
                total["I_wcm2"],
                wavelength_um,
            ),
            dtype=float,
        )
        arrays[f"total_comparison__{short}__gamma_zns_reference"] = gamma_total
        total_manifest[short]["arrays"][
            "gamma_zns_reference"
        ] = f"total_comparison__{short}__gamma_zns_reference"

        for index, I_value in enumerate(total["I_wcm2"]):
            row = {
                **case_label,
                "dataset": "total_comparison",
                "point_index": index,
                "I_wcm2": float(I_value),
                "gamma_zns_reference": float(gamma_total[index]),
                "Wtotal_peak_cm3_fs": float(total["Wtotal_peak_cm3_fs"][index]),
            }
            total_rows.append(row)

        surface = compute_total_ionization_surface_data(
            case=case,
            n_intensity_points=surface_n_intensity_points,
            n_density_points=surface_n_density_points,
        )
        surface_manifest[short] = {
            "used_by": [
                "05_total_ionization_3d_2x2_all_cases.png",
                "future custom 3D/surface/contour plots",
            ],
            "arrays": {},
        }
        for name, values in surface.items():
            array_name = f"surface3d__{short}__{name}"
            arrays[array_name] = np.asarray(values, dtype=float)
            surface_manifest[short]["arrays"][name] = array_name

    manifest = {
        "description": (
            "Labeled variables used by the 14 PI/II plot panels in "
            "Keldsyh_II_various.py, plus matching 3D surface variables."
        ),
        "source_script": "Keldsyh_II_various.py",
        "units": {
            "I_wcm2": "W/cm^2",
            "ne_cm3": "cm^-3",
            "Wpi_cm3_fs": "cm^-3 fs^-1",
            "Wav_cm3_fs": "cm^-3 fs^-1",
            "Wtotal_cm3_fs": "cm^-3 fs^-1",
            "wavelength_um": "um",
            "tau_fs": "fs",
            "F0_jcm2": "J/cm^2",
            "gamma_zns_reference": "dimensionless",
        },
        "cases": [_case_with_derived_labels(case) for case in cases],
        "settings": {
            "component_n_intensity_points": component_n_intensity_points,
            "component_I_min_wcm2": 1.0e10,
            "component_I_max_wcm2": 1.0e15,
            "total_n_intensity_points": total_n_intensity_points,
            "total_I_min_wcm2": 5.0e10,
            "total_I_max_wcm2": 1.0e15,
            "surface_n_intensity_points": surface_n_intensity_points,
            "surface_n_density_points": surface_n_density_points,
            "surface_I_min_wcm2": 1.0e10,
            "surface_I_max_wcm2": 1.0e15,
            "surface_ne_min_cm3": 1.0e10,
            "surface_ne_max_cm3": 1.0e22,
            "n_time_points_for_scaling": 600,
        },
        "files": {
            "numpy_arrays": "pi_ii_14_variables.npz",
            "manifest": "pi_ii_14_manifest.json",
            "component_scaling_csv": "pi_ii_14_component_scaling_long.csv",
            "total_comparison_csv": "pi_ii_14_total_comparison_long.csv",
        },
        "figure_panels_14": [
            {
                "figure": "02_last_graph_set_total_ionization_gamma_axis.png",
                "panel": "(a) NIR",
                "dataset": "total_comparison",
                "cases": ["ZnSe_NIR", "ZnS_NIR"],
                "variables": ["I_wcm2", "Wtotal_peak_cm3_fs", "gamma_zns_reference"],
            },
            {
                "figure": "02_last_graph_set_total_ionization_gamma_axis.png",
                "panel": "(b) LWIR",
                "dataset": "total_comparison",
                "cases": ["ZnSe_LWIR", "ZnS_LWIR"],
                "variables": ["I_wcm2", "Wtotal_peak_cm3_fs", "gamma_zns_reference"],
            },
            *[
                {
                    "figure": f"gruzdev_fig2_{case['short']}.png",
                    "panel": "(a) rate components",
                    "dataset": "component_scaling",
                    "cases": [case["short"]],
                    "variables": [
                        "I_wcm2",
                        "Wpi_peak_cm3_fs",
                        "Wav_peak_cm3_fs",
                        "Wtotal_peak_cm3_fs",
                    ],
                }
                for case in cases
            ],
            *[
                {
                    "figure": f"gruzdev_fig2_{case['short']}.png",
                    "panel": "(b) density and total rate",
                    "dataset": "component_scaling",
                    "cases": [case["short"]],
                    "variables": ["I_wcm2", "ne_max_cm3", "Wtotal_peak_cm3_fs"],
                }
                for case in cases
            ],
            {
                "figure": "gruzdev_fig4_ZnSe.png",
                "panel": "(a) electron density",
                "dataset": "component_scaling",
                "cases": ["ZnSe_NIR", "ZnSe_LWIR"],
                "variables": ["I_wcm2", "ne_max_cm3"],
            },
            {
                "figure": "gruzdev_fig4_ZnSe.png",
                "panel": "(b) total ionization rate",
                "dataset": "component_scaling",
                "cases": ["ZnSe_NIR", "ZnSe_LWIR"],
                "variables": ["I_wcm2", "Wtotal_peak_cm3_fs"],
            },
            {
                "figure": "gruzdev_fig4_ZnS.png",
                "panel": "(a) electron density",
                "dataset": "component_scaling",
                "cases": ["ZnS_NIR", "ZnS_LWIR"],
                "variables": ["I_wcm2", "ne_max_cm3"],
            },
            {
                "figure": "gruzdev_fig4_ZnS.png",
                "panel": "(b) total ionization rate",
                "dataset": "component_scaling",
                "cases": ["ZnS_NIR", "ZnS_LWIR"],
                "variables": ["I_wcm2", "Wtotal_peak_cm3_fs"],
            },
        ],
        "component_scaling": component_manifest,
        "total_comparison": total_manifest,
        "surface3d": surface_manifest,
    }

    np.savez_compressed(output_dir / "pi_ii_14_variables.npz", **arrays)
    with (output_dir / "pi_ii_14_manifest.json").open("w", encoding="utf-8") as handle:
        json.dump(manifest, handle, indent=2)

    write_csv(output_dir / "pi_ii_14_component_scaling_long.csv", component_rows)
    write_csv(output_dir / "pi_ii_14_total_comparison_long.csv", total_rows)

    print(f"Saved PI/II variables to {output_dir}")


def write_csv(path: Path, rows: Sequence[Dict[str, Any]]) -> None:
    """Write a list of dictionaries as CSV."""

    if not rows:
        return
    fieldnames = list(rows[0].keys())
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def plot_case_figure_1_style(
    case: CaseDict,
    save_dir: Optional[Path] = None,
) -> None:
    """Plot Keldysh photoionization rate versus peak irradiance."""

    I_values_wcm2 = np.logspace(10, 15, 900)
    I_values_wm2 = I_values_wcm2 * WM2_PER_WCM2
    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    n0, _n2, Eg_J, mred, _trans = material_flag1(
        int(case["mat_flag"]), wavelength_um
    )

    Wpi_cm3_fs = np.asarray(
        keldysh_full_rate_m3_s(
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
            intensity_wm2=I_values_wm2,
        ),
        dtype=float,
    ) * RATE_CM3_FS_PER_M3_S

    I_lidt = case_lidt_peak_intensity_wcm2(case)
    fig, ax = plt.subplots(figsize=(7.0, 5.0))
    ax.loglog(
        I_values_wcm2,
        positive_for_log(Wpi_cm3_fs),
        "k-",
        linewidth=2.2,
        label=r"$W_{\rm PI}$",
    )

    W_lidt = interpolate_log_y(I_values_wcm2, Wpi_cm3_fs, I_lidt)
    if W_lidt is not None:
        ax.plot(
            I_lidt,
            W_lidt,
            "kx",
            markersize=9,
            markeredgewidth=2.0,
            label=r"$I_0$ at measured LIDT",
        )

    ax.set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    ax.set_ylabel(r"Photoionization rate $W_{\rm PI}$ (cm$^{-3}$ fs$^{-1}$)")
    ax.set_title(
        rf"{case['material']}: $W_{{\rm PI}}$ vs irradiance, "
        rf"$\lambda={case['wavelength_um']}$ $\mu$m, "
        rf"$\tau={case['tau_fs']:g}$ fs"
    )
    ax.grid(True, which="both", alpha=0.3)
    ax.legend(frameon=False, fontsize=9)
    ax.set_xlim(1.0e10, 1.0e15)

    save_or_show(
        fig,
        save_dir,
        f"gruzdev_fig1_{case['short']}.png",
    )


def plot_case_figure_2_style(
    case: CaseDict,
    n_intensity_points: int = 70,
    save_dir: Optional[Path] = None,
) -> None:
    """
    Plot rate components, electron density, and total rate versus irradiance.
    """

    I_values_wcm2 = np.logspace(10, 15, n_intensity_points)
    scaling = compute_case_scaling_components(
        case=case,
        I_values_wcm2=I_values_wcm2,
        n_time_points=600,
    )

    I = scaling["I_wcm2"]
    Wpi = scaling["Wpi_peak_cm3_fs"]
    Wav = scaling["Wav_peak_cm3_fs"]
    Wtotal = scaling["Wtotal_peak_cm3_fs"]
    ne = scaling["ne_max_cm3"]
    I_lidt = case_lidt_peak_intensity_wcm2(case)

    fig, axes = plt.subplots(1, 2, figsize=(13.0, 5.2))

    ax = axes[0]
    ax.loglog(I, positive_for_log(Wtotal), "b--", linewidth=2.5, label=r"$W_{\rm total}$")
    ax.loglog(I, positive_for_log(Wpi), "k:", linewidth=2.3, label=r"$W_{\rm PI}$")
    ax.loglog(
        I,
        positive_for_log(Wav),
        color="orange",
        linestyle="-.",
        linewidth=2.3,
        label=r"$W_{\rm av}$",
    )
    ax.axvline(I_lidt, color="0.4", linestyle="--", linewidth=1.3, label=r"$I_0$ at LIDT")
    ax.set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    ax.set_ylabel(r"Ionization rate (cm$^{-3}$ fs$^{-1}$)")
    ax.set_title(
        rf"(a) {case['material']}, $\lambda={case['wavelength_um']}$ $\mu$m, "
        rf"$\tau={case['tau_fs']:g}$ fs"
    )
    ax.grid(True, which="both", alpha=0.3)
    ax.legend(frameon=False, fontsize=9)
    ax.set_xlim(1.0e10, 1.0e15)

    ax = axes[1]
    ax_rate = ax.twinx()
    line_density, = ax.loglog(I, positive_for_log(ne), "r-", linewidth=2.5, label=r"$n_e$")
    line_rate, = ax_rate.loglog(
        I,
        positive_for_log(Wtotal),
        "b--",
        linewidth=2.5,
        label=r"$W_{\rm total}$",
    )
    ax.axvline(I_lidt, color="0.4", linestyle="--", linewidth=1.3)
    ax.set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    ax.set_ylabel(r"Electron density $n_e$ (cm$^{-3}$)")
    ax_rate.set_ylabel(r"Total ionization rate (cm$^{-3}$ fs$^{-1}$)")
    ax.set_title("(b) Density and total ionization rate")
    ax.grid(True, which="both", alpha=0.3)
    ax.legend(
        [line_density, line_rate],
        [line_density.get_label(), line_rate.get_label()],
        frameon=False,
        fontsize=9,
    )
    ax.set_xlim(1.0e10, 1.0e15)

    fig.suptitle(f"{case['short']}: irradiance scaling", fontsize=14)
    save_or_show(
        fig,
        save_dir,
        f"gruzdev_fig2_{case['short']}.png",
    )


def plot_case_figure_3_style(
    case: CaseDict,
    intensity_factors: Tuple[float, float, float, float] = (0.25, 0.5, 1.0, 2.0),
    save_dir: Optional[Path] = None,
) -> None:
    """Plot normalized time-domain carrier and ionization dynamics."""

    I_lidt_wcm2 = case_lidt_peak_intensity_wcm2(case)
    fig, axes = plt.subplots(4, 2, figsize=(13.0, 14.0), sharey=True)

    for row, factor in enumerate(intensity_factors):
        result = solve_dynamics_from_peak_intensity(
            case=case,
            I0_wcm2=factor * I_lidt_wcm2,
            n_time_points=1800,
        )

        if float(case["tau_fs"]) >= 1000.0:
            time_axis = result["t_s"] * 1.0e12
            time_label = "Time (ps)"
        else:
            time_axis = result["t_s"] * 1.0e15
            time_label = "Time (fs)"

        I_norm = normalize_curve(result["intensity_wm2"])
        ne_norm = normalize_curve(result["ne_cm3"])
        Wpi_norm = normalize_curve(result["Wpi_cm3_fs"])
        Wav_norm = normalize_curve(result["Wav_cm3_fs"])
        Wtotal_norm = normalize_curve(result["Wtotal_cm3_fs"])

        ax = axes[row, 0]
        ax.plot(time_axis, Wtotal_norm, "b--", linewidth=2.0, label=r"$W_{\rm total}$")
        ax.plot(time_axis, ne_norm, "r-", linewidth=2.0, label=r"$n_e$")
        ax.plot(time_axis, I_norm, "r:", linewidth=2.0, label=r"$I(t)$")
        ax.text(
            0.58,
            0.78,
            rf"$I_0={factor:g}I_{{\rm LIDT}}$",
            transform=ax.transAxes,
            fontsize=10,
            fontweight="bold",
        )
        ax.set_ylabel("Normalized value")
        ax.grid(True, alpha=0.25)
        ax.set_ylim(-0.03, 1.05)
        if row == 0:
            ax.legend(frameon=False, fontsize=8, loc="upper left")

        ax = axes[row, 1]
        ax.plot(time_axis, Wtotal_norm, "b--", linewidth=2.0, label=r"$W_{\rm total}$")
        ax.plot(
            time_axis,
            Wav_norm,
            color="goldenrod",
            linestyle="-.",
            linewidth=2.0,
            label=r"$W_{\rm av}$",
        )
        ax.plot(time_axis, Wpi_norm, "k:", linewidth=2.0, label=r"$W_{\rm PI}$")
        ax.plot(time_axis, I_norm, "r:", linewidth=2.0, label=r"$I(t)$")
        ax.text(
            0.58,
            0.78,
            rf"$I_0={factor:g}I_{{\rm LIDT}}$",
            transform=ax.transAxes,
            fontsize=10,
            fontweight="bold",
        )
        ax.grid(True, alpha=0.25)
        ax.set_ylim(-0.03, 1.05)
        if row == 0:
            ax.legend(frameon=False, fontsize=8, loc="upper left")

    axes[-1, 0].set_xlabel(time_label)
    axes[-1, 1].set_xlabel(time_label)
    fig.suptitle(
        rf"{case['material']} time-domain dynamics, "
        rf"$\lambda={case['wavelength_um']}$ $\mu$m, "
        rf"$\tau={case['tau_fs']:g}$ fs",
        fontsize=14,
    )
    save_or_show(
        fig,
        save_dir,
        f"gruzdev_fig3_{case['short']}.png",
    )


def plot_material_figure_4_style(
    material_name: str,
    material_cases: Sequence[CaseDict],
    n_intensity_points: int = 70,
    save_dir: Optional[Path] = None,
) -> None:
    """Compare NIR and LWIR density/rate scaling for one material."""

    I_values_wcm2 = np.logspace(10, 15, n_intensity_points)
    fig, axes = plt.subplots(1, 2, figsize=(13.0, 5.2))
    linestyles = {"NIR": "-", "LWIR": "-."}

    for case in material_cases:
        scaling = compute_case_scaling_components(
            case=case,
            I_values_wcm2=I_values_wcm2,
            n_time_points=600,
        )
        I = scaling["I_wcm2"]
        ne = scaling["ne_max_cm3"]
        Wtotal = scaling["Wtotal_peak_cm3_fs"]
        label = rf"{case['wavelength_um']:g} $\mu$m, $\tau={case['tau_fs']:g}$ fs"
        style = linestyles.get(case["region"], "-")

        axes[0].loglog(I, positive_for_log(ne), linestyle=style, linewidth=2.3, label=label)
        axes[1].loglog(I, positive_for_log(Wtotal), linestyle=style, linewidth=2.3, label=label)

        I_lidt = case_lidt_peak_intensity_wcm2(case)
        axes[0].axvline(I_lidt, color="0.5", linestyle="--", linewidth=1.0)
        axes[1].axvline(I_lidt, color="0.5", linestyle="--", linewidth=1.0)

    axes[0].set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    axes[0].set_ylabel(r"Electron density $n_e$ (cm$^{-3}$)")
    axes[0].set_title(f"(a) {material_name}: electron density")
    axes[0].grid(True, which="both", alpha=0.3)
    axes[0].legend(frameon=False, fontsize=9)
    axes[0].set_xlim(1.0e10, 1.0e15)

    axes[1].set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    axes[1].set_ylabel(r"Total ionization rate (cm$^{-3}$ fs$^{-1}$)")
    axes[1].set_title(f"(b) {material_name}: total ionization rate")
    axes[1].grid(True, which="both", alpha=0.3)
    axes[1].legend(frameon=False, fontsize=9)
    axes[1].set_xlim(1.0e10, 1.0e15)

    fig.suptitle(
        rf"{material_name}: NIR 100 fs versus LWIR 2 ps irradiance scaling",
        fontsize=14,
    )
    save_or_show(
        fig,
        save_dir,
        f"gruzdev_fig4_{material_name}.png",
    )


def plot_znse_zns_figures(
    cases: Sequence[CaseDict],
    n_intensity_points: int = 70,
    save_dir: Optional[Path] = None,
) -> None:
    """Generate all Figs. 1-4 for ZnSe and ZnS."""

    print("\n============================================================")
    print("Generating ZnSe/ZnS plots")
    print("Cases: 0.8 um, 100 fs and 9.2 um, 2 ps")
    print("============================================================\n")

    for case in cases:
        plot_case_figure_1_style(case, save_dir=save_dir)
        plot_case_figure_2_style(
            case,
            n_intensity_points=n_intensity_points,
            save_dir=save_dir,
        )
        plot_case_figure_3_style(case, save_dir=save_dir)

    for material_name in ("ZnSe", "ZnS"):
        material_cases = [
            case for case in cases if case["material"] == material_name
        ]
        plot_material_figure_4_style(
            material_name=material_name,
            material_cases=material_cases,
            n_intensity_points=n_intensity_points,
            save_dir=save_dir,
        )


# ============================================================
# CODEX MODIFICATION START: 3D total-ionization surface plot
# ============================================================

def plot_total_ionization_3d_surface(
    case: CaseDict,
    save_dir: Optional[Path] = None,
    n_intensity_points: int = 80,
    n_density_points: int = 80,
    I_min_wcm2: float = 1.0e10,
    I_max_wcm2: float = 1.0e15,
    ne_min_cm3: float = 1.0e10,
    ne_max_cm3: float = 1.0e22,
) -> None:
    """
    Plot total ionization rate versus peak laser intensity and electron density.

    Axes are log10(I0), log10(ne), and log10(W_total), where W_total includes
    Keldysh photoionization plus avalanche/impact ionization.
    """

    surface_data = compute_total_ionization_surface_data(
        case=case,
        n_intensity_points=n_intensity_points,
        n_density_points=n_density_points,
        I_min_wcm2=I_min_wcm2,
        I_max_wcm2=I_max_wcm2,
        ne_min_cm3=ne_min_cm3,
        ne_max_cm3=ne_max_cm3,
    )

    X = surface_data["log10_I_grid_wcm2"]
    Y = surface_data["log10_ne_grid_cm3"]
    Z = surface_data["log10_Wtotal_grid_cm3_fs"]

    fig = plt.figure(figsize=(9, 7))
    ax = fig.add_subplot(111, projection="3d")
    surface = ax.plot_surface(
        X,
        Y,
        Z,
        cmap="jet",
        linewidth=0,
        antialiased=True,
        alpha=0.95,
    )

    ax.set_xlabel(r"$\log_{10}(I_0)$  [W/cm$^2$]")
    ax.set_ylabel(r"$\log_{10}(n_e)$  [cm$^{-3}$]")
    ax.set_zlabel(r"$\log_{10}(W_{\rm total})$  [cm$^{-3}$ fs$^{-1}$]")
    ax.set_title(f"Total ionization surface: {case['short']}")

    fig.colorbar(
        surface,
        ax=ax,
        shrink=0.65,
        pad=0.12,
        label=r"$\log_{10}(W_{\rm total})$",
    )

    ax.view_init(elev=28, azim=135)
    fig.tight_layout()
    save_or_show(
        fig=fig,
        save_dir=save_dir,
        filename=f"05_total_ionization_3d_{case['short']}.png",
    )


def plot_total_ionization_3d_surface_grid(
    cases: Sequence[CaseDict],
    save_dir: Optional[Path] = None,
    n_intensity_points: int = 80,
    n_density_points: int = 80,
    I_min_wcm2: float = 1.0e10,
    I_max_wcm2: float = 1.0e15,
    ne_min_cm3: float = 1.0e10,
    ne_max_cm3: float = 1.0e22,
) -> None:
    """Plot all four total-ionization 3D surfaces in one 2x2 figure."""

    if len(cases) != 4:
        raise ValueError("The 2x2 3D grid requires exactly four cases.")
    if n_intensity_points < 2:
        raise ValueError("n_intensity_points must be at least 2.")
    if n_density_points < 2:
        raise ValueError("n_density_points must be at least 2.")
    if I_min_wcm2 <= 0.0 or I_max_wcm2 <= I_min_wcm2:
        raise ValueError("Require 0 < I_min_wcm2 < I_max_wcm2.")
    if ne_min_cm3 <= 0.0 or ne_max_cm3 <= ne_min_cm3:
        raise ValueError("Require 0 < ne_min_cm3 < ne_max_cm3.")

    surface_data_list: List[Dict[str, np.ndarray]] = []
    z_grids: List[np.ndarray] = []
    for case in cases:
        surface_data = compute_total_ionization_surface_data(
            case=case,
            n_intensity_points=n_intensity_points,
            n_density_points=n_density_points,
            I_min_wcm2=I_min_wcm2,
            I_max_wcm2=I_max_wcm2,
            ne_min_cm3=ne_min_cm3,
            ne_max_cm3=ne_max_cm3,
        )
        surface_data_list.append(surface_data)
        Z = surface_data["log10_Wtotal_grid_cm3_fs"]
        z_grids.append(Z)

    z_min = min(float(np.nanmin(Z)) for Z in z_grids)
    z_max = max(float(np.nanmax(Z)) for Z in z_grids)
    norm = colors.Normalize(vmin=z_min, vmax=z_max)
    cmap = plt.get_cmap("jet")

    fig = plt.figure(figsize=(15, 11))
    fig.subplots_adjust(
        left=0.04,
        right=0.88,
        bottom=0.06,
        top=0.92,
        wspace=0.10,
        hspace=0.16,
    )

    for index, (case, surface_data, Z) in enumerate(
        zip(cases, surface_data_list, z_grids)
    ):
        X = surface_data["log10_I_grid_wcm2"]
        Y = surface_data["log10_ne_grid_cm3"]
        ax = fig.add_subplot(2, 2, index + 1, projection="3d")
        ax.plot_surface(
            X,
            Y,
            Z,
            facecolors=cmap(norm(Z)),
            linewidth=0,
            antialiased=True,
            shade=False,
            alpha=0.95,
        )
        ax.set_xlabel(r"$\log_{10}(I_0)$")
        ax.set_ylabel(r"$\log_{10}(n_e)$")
        ax.set_zlabel(r"$\log_{10}(W_{\rm total})$")
        ax.set_title(case["short"])
        ax.view_init(elev=28, azim=135)

    colorbar_axis = fig.add_axes([0.91, 0.18, 0.018, 0.64])
    colorbar_mappable = cm.ScalarMappable(norm=norm, cmap=cmap)
    colorbar_mappable.set_array([])
    fig.colorbar(
        colorbar_mappable,
        cax=colorbar_axis,
        label=r"$\log_{10}(W_{\rm total})$ [cm$^{-3}$ fs$^{-1}$]",
    )

    fig.suptitle(
        "Total ionization surfaces: ZnSe/ZnS NIR and LWIR",
        fontsize=15,
    )
    save_or_show(
        fig=fig,
        save_dir=save_dir,
        filename="05_total_ionization_3d_2x2_all_cases.png",
        apply_tight_layout=False,
    )

# ============================================================
# CODEX MODIFICATION END: 3D total-ionization surface plot
# ============================================================


# ============================================================
# Workflow
# ============================================================

def solve_and_display_summary(cases: Sequence[CaseDict]) -> None:
    """Solve the four LIDT cases and display the summary table."""

    results: List[Dict[str, Any]] = []
    for case in cases:
        print(f"Solving density table entry for {case['short']} ...")
        result = solve_density_case(case)
        results.append(result)

        if not result["sol_photo_success"]:
            print(
                f"  WARNING: photo-only solver for {case['short']}: "
                f"{result['sol_photo_message']}"
            )
        if not result["sol_total_success"]:
            print(
                f"  WARNING: total solver for {case['short']}: "
                f"{result['sol_total_message']}"
            )

    display_summary_table(build_summary_table(results))


def main() -> None:
    """Run the fixed default workflow."""

    cases = get_cases()
    # Keep this multi-material workflow separate from the BaF2 workflow.
    save_dir = Path("figures_Keldsyh_II_various")
    variable_dir = save_dir / "saved_variables"

    plot_keldysh_rate_curves(cases=cases, save_dir=save_dir)
    solve_and_display_summary(cases)
    save_pi_ii_14_plot_variables(
        cases=cases,
        output_dir=variable_dir,
        component_n_intensity_points=50,
        total_n_intensity_points=50,
        surface_n_intensity_points=50,
        surface_n_density_points=80,
    )
    plot_total_ionization_nir_lwir_comparison_with_gamma_axis(
        cases=cases,
        n_intensity_points=50,
        I_min_wcm2=5.0e10,
        I_max_wcm2=1.0e15,
        y_min=1.0e0,
        y_max=1.0e30,
        include_field_factor_two=False,
        save_dir=save_dir,
    )
    plot_znse_zns_figures(
        cases=cases,
        n_intensity_points=50,
        save_dir=save_dir,
    )
    plot_total_ionization_3d_surface_grid(
        cases=cases,
        save_dir=save_dir,
        n_intensity_points=50,
        n_density_points=80,
    )


if __name__ == "__main__":
    main()

