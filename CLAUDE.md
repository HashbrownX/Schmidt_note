# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a MATLAB-based implementation of Schmidt theory analysis for β-type Stirling engines. The codebase performs thermodynamic performance calculations and generates p-V diagrams for Stirling engine cycles.

## Running the Code

**Execute the main analysis:**
```matlab
matlab -batch "run('Stirling_beta_schmidt.m')"
```

Or open MATLAB and run:
```matlab
Stirling_beta_schmidt
```

**Key parameters** (lines 2-9 in Stirling_beta_schmidt.m):
- `T_h`: Hot-end temperature [K]
- `T_c`: Cold-end temperature [K]
- `p_mean`: Mean pressure [Pa]
- `V_SE`: Expansion space swept volume [m³]
- `V_SC`: Compression space swept volume [m³]
- `alpha_deg`: Phase angle [degrees]
- `n_rpm`: Rotational speed [rpm]
- `V_R`: Regenerator volume [m³]

## Code Architecture

**Single-file structure:**
- Main script (lines 1-10): Parameter definition and function call
- Function `schmidt_stirling_analysis` (lines 11-134): Complete Schmidt theory implementation

**Calculation flow:**
1. **Input validation** (lines 24-38): Display design parameters
2. **Intermediate parameters** (lines 39-56): Calculate κ, χ, χ_B, δ, φ
3. **Performance metrics** (lines 57-90): Compute W_E, W_C, W_i, L_i, η, pressure ratios
4. **Visualization** (lines 91-133): Generate three p-V diagrams and efficiency curve

**Key formulas implemented:**
- Overlap volume V_B (line 43): Geometric calculation from phase angle
- Pressure fluctuation parameter δ (line 48): B/S ratio
- Phase offset φ (line 49): `atan2(κ·sin(α), 1-τ-κ·cos(α))`
- Expansion work W_E (line 62): Positive work output
- Compression work W_C (line 65): Negative work (stored as absolute value, then negated)
- Thermal efficiency η (line 73): `1 - τ` (equals Carnot efficiency under ideal assumptions)

## Physics Model

**Schmidt theory assumptions:**
- Ideal gas behavior
- Isothermal expansion/compression spaces
- Perfect regenerator (100% heat recovery, no pressure drop)
- Sinusoidal piston motion
- Steady-state periodic operation

**Critical relationship:** W_i = W_E + W_C, where W_C is negative (compression consumes work)

## Output

The code generates:
1. Console output with all calculated parameters
2. Three figures: Expansion space p-V, Compression space p-V, Total volume p-V
3. Efficiency vs. temperature ratio curve

## Documentation

See `note.md` for detailed mathematical derivations of:
- Volume equations for V_E(θ) and V_C(θ)
- Pressure equation p(θ) derivation
- Work integral calculations
- All dimensionless parameters (τ, κ, χ, δ, φ)
