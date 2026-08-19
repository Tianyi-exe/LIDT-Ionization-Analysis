"""Standalone fluence-threshold comparison for ZnSe, ZnS, BaF2, and NaCl.

The model is evaluated in SI units:

    F_th = [3 n_a lambda / (16 pi)] (epsilon_b + E_g)

where n_a is the total atomic number density (m^-3), lambda is the vacuum
wavelength (m), and epsilon_b and E_g are energies in joules.  F_th is
reported in J/m^2 and J/cm^2, together with the dimensionless ratio F0/F_th.

This file is intentionally independent of the Keldysh PI/II model. It uses
only the case-input fluence and the threshold-fluence model inputs. The LWIR
cases use lambda = 9.2 um and the user-supplied 2 ps LIDT fluences where
available. Pulse duration is retained as case metadata only: it does not
enter the Gamaly fluence formula.
"""

from __future__ import annotations

from math import pi
from pathlib import Path
from typing import Any, Dict, Iterable, List


AVOGADRO = 6.02214076e23  # mol^-1
E_CHARGE = 1.602176634e-19  # J/eV

# Keep the material colors consistent with the Keldysh comparison figures.
MATERIAL_COLORS = {
    "ZnSe": "#0072BD",
    "ZnS": "#D95319",
    "BaF2": "#77AC30",
    "NaCl": "#7E2F8E",
}

# NIR uses an eight-ray asterisk (米字星); LWIR uses a solid five-point star.
NIR_MARKER = (8, 2, 0)
LWIR_MARKER = (5, 1, 0)

MaterialDict = Dict[str, Any]
CaseDict = Dict[str, Any]


# Enter energies on a per-atom basis.  Density is in kg/m^3 and molar mass is
# in kg/mol.  ``atoms_per_formula_unit`` converts formula-unit density to the
# total atomic number density required by the threshold model.
MATERIALS: Dict[str, MaterialDict] = {
    "ZnSe": {
        "molar_mass_kg_mol": 0.14434,
        "atoms_per_formula_unit": 2,
        "mass_density_kg_m3": 5270.0,
        "binding_energy_ev_per_atom": 2.755,
        "bandgap_ev": 2.7,
        "input_status": "Inputs confirmed in Threshold_Fluence_Parameter.docx.",
    },
    "ZnS": {
        "molar_mass_kg_mol": 0.09744,
        "atoms_per_formula_unit": 2,
        "mass_density_kg_m3": 4090.0,
        "binding_energy_ev_per_atom": 3.55,
        "bandgap_ev": 3.6,
        "input_status": "Inputs confirmed in Threshold_Fluence_Parameter.docx.",
    },
    "BaF2": {
        "molar_mass_kg_mol": 0.175323806,
        "atoms_per_formula_unit": 3,
        "mass_density_kg_m3": 4890.0,
        "binding_energy_ev_per_atom": 6.013333333333334,
        "bandgap_ev": 10.6,
        "input_status": (
            "Binding energy = 18.04 eV per BaF2 formula unit / 3 atoms."
        ),
    },
    "NaCl": {
        "molar_mass_kg_mol": 0.058443,
        "atoms_per_formula_unit": 2,
        "mass_density_kg_m3": 2165.0,
        "binding_energy_ev_per_atom": 3.2,
        "bandgap_ev": 8.5,
        "input_status": (
            "Eg = 8.5 eV from NaCl_Keldysh_Parameter.docx; cohesive/binding "
            "energy = 3.2 eV/atom, as specified in "
            "Gamaly_Threshold_Fluence_Parameter.docx."
        ),
    },
}


# F0 values are case-input fluences in J/cm^2. Do not interpret every F0
# value as a directly measured damage threshold. The BaF2 and NaCl LWIR
# entries below are the user-supplied LIDT fluences at 9.2 um, 2 ps.
CASES: List[CaseDict] = [
    {"short": "ZnSe_NIR", "material": "ZnSe", "region": "NIR", "wavelength_um": 0.8, "F0_jcm2": 0.150},
    {"short": "ZnS_NIR", "material": "ZnS", "region": "NIR", "wavelength_um": 0.8, "F0_jcm2": 0.170},
    {"short": "ZnSe_LWIR", "material": "ZnSe", "region": "LWIR", "wavelength_um": 9.2, "F0_jcm2": 0.83},
    {"short": "ZnS_LWIR", "material": "ZnS", "region": "LWIR", "wavelength_um": 9.2, "F0_jcm2": 1.19},
    {"short": "BaF2_NIR", "material": "BaF2", "region": "NIR", "wavelength_um": 0.8, "F0_jcm2": 0.9441088},
    {"short": "NaCl_NIR", "material": "NaCl", "region": "NIR", "wavelength_um": 0.8, "F0_jcm2": 0.3922889852754974},
    {
        "short": "BaF2_LWIR",
        "material": "BaF2",
        "region": "LWIR",
        "wavelength_um": 9.2,
        "pulse_duration_ps": 2.0,
        "F0_jcm2": 2.62,
        "input_status": "User-supplied LWIR LIDT fluence: 9.2 um, 2 ps.",
    },
    {
        "short": "NaCl_LWIR",
        "material": "NaCl",
        "region": "LWIR",
        "wavelength_um": 9.2,
        "pulse_duration_ps": 2.0,
        "F0_jcm2": 4.57,
        "input_status": "User-supplied LWIR LIDT fluence: 9.2 um, 2 ps.",
    },
]


def total_atomic_density_m3(material: MaterialDict) -> float:
    """Return total atomic density n_a from density and formula composition."""

    density = material["mass_density_kg_m3"]
    if density is None:
        raise ValueError("mass_density_kg_m3 is not set.")

    molar_mass = float(material["molar_mass_kg_mol"])
    atoms_per_formula_unit = int(material["atoms_per_formula_unit"])
    if float(density) <= 0.0 or molar_mass <= 0.0 or atoms_per_formula_unit <= 0:
        raise ValueError("Density, molar mass, and atom count must be positive.")

    return float(atoms_per_formula_unit * float(density) * AVOGADRO / molar_mass)


def gamaly_threshold_fluence_jcm2(material: MaterialDict, wavelength_um: float) -> float:
    """Return the Gamaly threshold fluence F_th in J/cm^2 at one wavelength."""

    wavelength_m = float(wavelength_um) * 1.0e-6
    if wavelength_m <= 0.0:
        raise ValueError("wavelength_um must be positive.")
    energy_j = (
        float(material["binding_energy_ev_per_atom"])
        + float(material["bandgap_ev"])
    ) * E_CHARGE
    Fth_jm2 = 3.0 * total_atomic_density_m3(material) * wavelength_m * energy_j / (
        16.0 * pi
    )
    return Fth_jm2 * 1.0e-4


def calculate_case(case: CaseDict) -> Dict[str, Any]:
    """Calculate F_th and F0/F_th for one material and laser condition."""

    material = MATERIALS[case["material"]]
    missing = [
        key
        for key in ("mass_density_kg_m3", "binding_energy_ev_per_atom")
        if material[key] is None
    ]
    result: Dict[str, Any] = dict(case)
    result["missing_inputs"] = missing
    if missing:
        return result

    n_a_m3 = total_atomic_density_m3(material)
    Fth_jcm2 = gamaly_threshold_fluence_jcm2(
        material, float(case["wavelength_um"])
    )
    Fth_jm2 = Fth_jcm2 * 1.0e4
    F0_jcm2 = float(case["F0_jcm2"])

    result.update(
        {
            "n_a_m3": n_a_m3,
            "Fth_jm2": Fth_jm2,
            "Fth_jcm2": Fth_jcm2,
            "F0_over_Fth": F0_jcm2 / Fth_jcm2,
        }
    )
    return result


def calculate_all(cases: Iterable[CaseDict] = CASES) -> List[Dict[str, Any]]:
    """Calculate all configured material/laser cases."""

    return [calculate_case(case) for case in cases]


def print_report(results: Iterable[Dict[str, Any]]) -> None:
    """Print a compact, unit-labeled threshold-fluence report."""

    print("Fluence Threshold: F_th = [3 n_a lambda/(16 pi)] (epsilon_b + E_g)\n")
    for result in results:
        label = f"{result['short']} ({result['material']}, {result['wavelength_um']:g} um)"
        if result["missing_inputs"]:
            missing = ", ".join(result["missing_inputs"])
            print(f"{label}: not calculated; set {missing}.")
            continue

        print(label)
        print(f"  n_a       = {result['n_a_m3']:.4e} m^-3")
        print(f"  F_th      = {result['Fth_jm2']:.4e} J/m^2 = {result['Fth_jcm2']:.4f} J/cm^2")
        print(f"  F0/F_th   = {result['F0_over_Fth']:.4f}\n")


def plot_threshold_vs_wavelength(
    results: Iterable[Dict[str, Any]], output_path: Path | None = None
) -> Path:
    """Save all wavelength-dependent Gamaly thresholds on one set of axes.

    Each solid curve is F_th(lambda).  Stars are the configured case-input
    fluences, plotted at their respective wavelengths; they are not additional
    threshold measurements.
    """

    try:
        import matplotlib.pyplot as plt
    except ModuleNotFoundError as exc:
        raise RuntimeError(
            "Plotting requires matplotlib. Install it in the Python environment "
            "used to run this script."
        ) from exc

    results = list(results)
    wavelength_grid = [0.7 + 10.3 * index / 400 for index in range(401)]
    material_order = ["ZnSe", "ZnS", "BaF2", "NaCl"]
    fig, ax = plt.subplots(figsize=(9.0, 6.2))

    for material_name in material_order:
        material = MATERIALS[material_name]
        color = MATERIAL_COLORS[material_name]
        thresholds = [
            gamaly_threshold_fluence_jcm2(material, wavelength_um)
            for wavelength_um in wavelength_grid
        ]
        ax.plot(
            wavelength_grid,
            thresholds,
            color=color,
            linewidth=2.5,
            label=f"{material_name} Gamaly threshold",
        )

        for result in results:
            if result["material"] != material_name or result["missing_inputs"]:
                continue
            is_nir = result["region"] == "NIR"
            marker = NIR_MARKER if is_nir else LWIR_MARKER
            ax.plot(
                result["wavelength_um"],
                result["F0_jcm2"],
                marker=marker,
                markersize=11,
                color=color,
                markeredgecolor=color,
                markeredgewidth=0.6,
                markerfacecolor="none" if is_nir else color,
                linestyle="None",
            )

    ax.plot(
        [], [], marker=NIR_MARKER, markersize=11, color="black", markeredgecolor="black",
        markerfacecolor="none", linestyle="None", label="NIR case-input fluence, F0",
    )
    ax.plot(
        [], [], marker=LWIR_MARKER, markersize=11, color="black", markeredgecolor="black",
        markerfacecolor="black", linestyle="None", label="LWIR case-input fluence, F0",
    )
    ax.set_xlim(0.7, 11.0)
    ax.set_ylim(1.0e-2, 1.0e1)
    ax.set_yscale("log")
    ax.set_xlabel("Wavelength λ (µm)")
    ax.set_ylabel("Fluence (J/cm²)")
    ax.set_title("Gamaly fluence threshold versus wavelength", fontweight="bold")
    ax.legend(frameon=False, loc="upper left")
    ax.grid(which="major", alpha=0.35)
    ax.grid(which="minor", alpha=0.18, linestyle=":")
    fig.text(
        0.5,
        0.01,
        "BaF₂ and NaCl LWIR stars use the supplied 9.2-µm, 2-ps LIDT fluences.",
        ha="center",
        va="bottom",
        fontsize=8,
    )
    fig.tight_layout(rect=(0.0, 0.05, 1.0, 1.0))

    if output_path is None:
        output_path = Path(__file__).resolve().parent / "figures_Gamaly_Fluence_Threshold" / (
            "Gamaly_threshold_vs_wavelength_all_materials.png"
        )
    output_path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(output_path, dpi=300, bbox_inches="tight")
    plt.close(fig)
    return output_path


if __name__ == "__main__":
    all_results = calculate_all()
    print_report(all_results)
    wavelength_figure_path = plot_threshold_vs_wavelength(all_results)
    print(f"Saved wavelength comparison: {wavelength_figure_path}")
