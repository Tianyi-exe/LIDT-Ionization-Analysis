# Keldysh workflow: recorded open issues

Last reviewed: 2026-08-13

Status: **recorded; do not change the present calculation logic yet.**

This file is the central record for unresolved issues that apply across the
material-specific Keldysh scripts. The current outputs may be used for
cross-material diagnostic comparison only within the documented assumptions.

## 1. ZnS/ZnSe effective-mass definition

**Search key:** `ZNS_ZNSE_MASS_DEFINITION`

Current behavior:

- `Keldsyh_II_various.py` uses `0.17 m0` for ZnSe and `0.34 m0` for ZnS.
- The input documents currently label these values as electron-hole reduced
  effective masses.

Unresolved point:

- These numerical values are also commonly reported as electron effective
  masses. The original source and the exact meaning of `m_r^e` must be checked
  before deciding whether the code needs an electron mass or an electron-hole
  transition reduced mass.

Current decision:

- Keep `0.17 m0` and `0.34 m0` unchanged until the original source definition
  is confirmed.

## 2. Interface transmission is not applied to the calculated intensity

**Search key:** `TRANSMISSION_NOT_APPLIED`

**Problem and impact:** The experimental fluence has been confirmed to be the incident fluence arriving at the sample surface before reflection. However, the current zero-dimensional solver converts that fluence directly into peak intensity and uses it in the Keldysh and avalanche equations. Although the code calculates `T = 1 - R`, it only exports this value and does not apply it to the internal intensity. The model therefore behaves as if the entrance transmission were unity and includes energy that would physically be reflected at the surface. This overestimates the effective internal intensity and electric field, underestimates the Keldysh parameter, and can nonlinearly overestimate photoionization, avalanche ionization, and the final electron density. Because the ionization rates are highly nonlinear functions of intensity, the density results cannot be corrected afterward by simply multiplying them by a transmission factor; introducing reflection requires recomputing the complete time-dependent rate and density evolution. If reflection continues to be neglected, all outputs must be identified as diagnostic results based on a surface-equivalent effective intensity, not as reflection-corrected internal material responses.

Current behavior:

- The scripts calculate `T = 1 - R` and export it.
- The Keldysh and avalanche calculations use the peak intensity obtained from
  the supplied fluence/intensity without multiplying it by `T`.

Unresolved point:

- The inputs do not yet state consistently whether fluence is incident on the
  sample or is already the internal/transmitted fluence.

Current decision:

- Do not apply `T` until the experimental fluence definition is confirmed.

## 3. ZnS/ZnSe hard-coded reflectance is not ordinary single-interface Fresnel reflectance

**Search key:** `HARDCODED_REFLECTANCE_NOT_FRESNEL`

**Problem and impact:** The reflectance values in the ZnS and ZnSe script are assigned directly in the NIR and LWIR branches. They are not calculated from the current refractive index `n0`, and they differ substantially from the normal-incidence, air-to-material, single-entrance-surface Fresnel reflectance. It is currently unclear whether these values represent one-surface reflectance, two-surface loss, total sample loss including absorption, or an experimental fitting parameter. They therefore cannot be used as `R_entry`, or converted to an internal-intensity correction through `T = 1 - R`, until their source and geometry are identified. Treating total sample loss as entrance-surface reflection would underestimate the intensity entering the material, whereas completely neglecting the true entrance reflection would overestimate it. Either interpretation changes gamma, the ionization rates, and the electron density, and can introduce a material-dependent systematic bias into the ZnS/ZnSe comparison.

Current behavior:

- ZnSe uses `R = 0.32949` in the NIR branch and `R = 0.31059` in the LWIR
  branch.
- ZnS uses `R = 0.38251` in the NIR branch and `R = 0.26693` in the LWIR
  branch.
- These values are assigned directly and are not calculated from `n0`.

Unresolved point:

- The values differ substantially from normal-incidence, air-to-material,
  single-interface Fresnel reflectance calculated from the coded refractive
  indices. They may represent total sample loss, two surfaces, measured
  reflectance, or another experimental definition.

Current decision:

- Keep the assigned values unchanged, but do not describe them as verified
  single-interface Fresnel reflectance until their source and geometry are
  identified.

## 4. GaAs at 800 nm omits direct one-photon interband absorption

**Search key:** `GAAS_800NM_DIRECT_ABSORPTION_OMITTED`

**Problem and impact:** The 800 nm photon energy exceeds the 300 K direct band gap of GaAs, so direct one-photon interband absorption is energetically allowed. The current script nevertheless retains the zero-dimensional transparent-medium Keldysh/avalanche structure, uses only the real part of the complex refractive index, and omits linear absorption determined by `kappa` or an absorption coefficient, direct one-photon carrier generation, and propagation with depth-dependent attenuation. The model therefore omits a carrier-generation channel that should exist and may dominate, while applying an unattenuated surface-equivalent intensity to the entire zero-dimensional volume. The calculated GaAs gamma is consequently only a supplementary diagnostic quantity. The electron density, avalanche contribution, and LIDT cannot be interpreted as complete quantitative predictions for GaAs at 800 nm, and a value of gamma below unity alone does not establish that the real response is tunneling dominated.

Current behavior:

- At 800 nm, the photon energy is above the 300 K GaAs direct band gap.
- The script records `n + i*kappa = 3.682 + 0.069i` but uses only `Re(n)`.
- Direct one-photon generation, complex-index propagation, and depth-dependent
  attenuation are not included.

Consequence:

- GaAs carrier-density and avalanche outputs at 800 nm are diagnostic only and
  must not be interpreted as a complete physical LIDT prediction.

Current decision:

- Retain the present BaF2/NaCl-style calculation for comparison and keep the
  diagnostic warning enabled.

## 5. The Drude/avalanche term reuses the Keldysh transition reduced mass

**Search key:** `DRUDE_USES_TRANSITION_REDUCED_MASS`

**Problem and impact:** The current code uses the same `mred` in the Keldysh interband-transition term, the collision-time model, and the Drude absorption cross section. An interband transition reduced mass and the conductivity or Drude effective mass that describes free-carrier acceleration are not necessarily the same physical quantity. Because this mass enters the collision time, the Drude prefactor, and the avalanche rate, the avalanche contribution can be systematically overestimated or underestimated even when the photoionization term uses an appropriate transition mass. The relative avalanche strength of different materials may also change. Reusing `mred` is currently retained only for consistency with the legacy BaF2 and NaCl workflows. All avalanche-density results should therefore be treated as diagnostic quantities that are sensitive to this mass assumption until a separate, documented conductivity mass is supplied for each material.

Current behavior:

- The same `mred` is used in the Keldysh transition term, collision-time model,
  and Drude absorption cross section.

Unresolved point:

- A transition reduced mass and a conductivity/Drude effective mass are not
  generally interchangeable. A material-specific conductivity mass may be
  required.

Current decision:

- Preserve the inherited calculation logic for present cross-material
  comparison. Introduce a separate conductivity mass only after selecting and
  documenting a defensible value for each material.

## 6. Ti:Sapphire is currently an Al2O3-host diagnostic model

**Search key:** `TISAPPHIRE_HOST_ONLY_DIAGNOSTIC`

**Problem and impact:** The current Ti:Sapphire script uses the Al2O3 host band gap, a sapphire refractive index, and the temporary value `mred = 1.0 m0`. It does not include Ti concentration, Ti3+ impurity states, Ti3+ absorption or emission, pump-dependent population inversion or gain, crystal cut, propagation direction, or polarization. The calculation therefore represents strong-field ionization of the Al2O3 host in a Ti-doped crystal rather than a complete Ti3+:Al2O3 optical and carrier-dynamics model. This may serve as a first approximation for a lightly doped, unpumped crystal at intensities where host multiphoton ionization dominates. It cannot predict concentration-dependent absorption and heating, additional carriers generated through Ti-related states, pump-dependent absorption or gain, or anisotropy caused by crystal orientation and polarization. The present Ti:Sapphire electron-density and LIDT outputs must therefore be described as host diagnostic results, not as quantitative predictions for a real Ti:Sapphire sample with a specified dopant concentration, crystal orientation, polarization, and pump state.

Current behavior:

- The model uses the Al2O3 host gap and ordinary refractive index.
- The unresolved electron-hole reduced mass is temporarily set to `1.0 m0`.
- Ti concentration, Ti3+ absorption/emission, gain/inversion, crystal cut,
  polarization, and impurity-state excitation channels are omitted.

Current decision:

- Keep the present host calculation for comparison with BaF2 and NaCl.
- Label all Ti:Sapphire density and LIDT outputs as host diagnostic results.
- Do not replace the Al2O3 band gap with a Ti-level energy difference; add Ti
  absorption/excitation as a separate channel when sample-specific inputs are
  available.

## Next review order

1. Verify the original definition and source of ZnS/ZnSe `m_r^e`.
2. Define every fluence as incident or internal before applying transmission.
3. Identify the source and physical geometry of the hard-coded ZnS/ZnSe `R`.
4. Add direct absorption and propagation before treating GaAs 800 nm outputs
   as physical predictions.
5. Separate transition and conductivity masses in the Drude/avalanche model.
6. Add Ti concentration, orientation, polarization, and Ti3+ optical channels
   before treating Ti:Sapphire outputs as sample-specific predictions.
