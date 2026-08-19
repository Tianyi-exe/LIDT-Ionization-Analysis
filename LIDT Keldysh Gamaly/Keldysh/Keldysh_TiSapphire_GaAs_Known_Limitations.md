# Ti:Sapphire and GaAs Keldysh workflow: known limitations

The cross-material master record is `Keldysh_Known_Limitations.md`. In
particular, see recorded issues 4 and 5 for GaAs direct absorption at 800 nm
and the reuse of the transition reduced mass in the Drude/avalanche term, and
issue 6 for the Ti:Sapphire Al2O3-host-only diagnostic approximation.

The two standalone scripts deliberately retain the zero-dimensional calculation
structure used by `Keldsyh_II_NaCl.py` and `Keldsyh_II_BaF2.py`:

\[
\frac{dn_e}{dt}=W_{\rm PI}(I)+W_{\rm av}(I,n_e).
\]

They do not include propagation, carrier depletion/saturation, recombination,
heating, or a separate conductivity effective mass in the legacy Drude/
avalanche term. These omissions are recorded rather than changed so that the
new scripts remain comparable to the existing NaCl and BaF2 workflows.

The inherited `qfun_keldysh()` series termination also requires a future
benchmark against an independent Keldysh implementation. Nonmonotonic features
in a rate scan should not be assigned physical meaning until that comparison is
complete.

## GaAs at 800 nm

800 nm photons are above the 300 K direct GaAs band gap. The current script
records \(n+i\kappa=3.682+0.069i\), but uses only \(\operatorname{Re}(n)\) in
the Keldysh field conversion. It does not yet include direct one-photon
interband generation or depth-dependent attenuation. Therefore its electron
density and avalanche results are **diagnostic only**.

Future extension: add a complex-index propagation equation, linear interband
absorption/generation, a density cap derived from the relevant valence states,
and a conduction-band conductivity mass for the Drude term.

## Ti:Sapphire

The current model uses the Al2O3 host gap and a reference electron-hole reduced
effective mass of \(1m_0\). It does not model Ti3+ concentration, absorption,
gain/inversion, orientation, polarization dependence, or a band-specific
electron-hole reduced mass. Its output is therefore also **diagnostic only**.

Future extension: specify the actual transition and its electron/hole masses,
then add dopant-resolved absorption/gain and anisotropic optical propagation.
