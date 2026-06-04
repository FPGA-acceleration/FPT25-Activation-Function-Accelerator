# README Redesign Spec — River: LLM Activation Function Accelerator

**Date:** 2026-06-04
**Status:** Approved

## Goal

Redesign the project README to match the professional quality of top open-source projects like vLLM, emphasizing:

1. **Awards** — FPT 2025 Design Competition First Prize (sole winner), FPGA Innovation Competition National First Prize
2. **Performance** — 30× faster than CPU, 6× faster than GPU, 7.352W total power
3. **Architecture** — Reconfigurable dataflow with primitive operators, not limited to preset functions
4. **Developer experience** — Clear quick start, directory structure, citation

## Design Decisions

| Decision | Choice | Rationale |
|:---|:---|:---|
| Language | English (full) | International audience, aligns with IEEE publication |
| Style | vLLM-style open source | Badges, tables, highlights-first structure |
| Badges | Conference + Awards + Platform + License | Professional appearance, key info at a glance |
| Architecture diagram | Embedded PNG from paper | Visual appeal, shows dataflow topology |
| Project name | "River" | User-chosen project codename |

## README Structure

```
1. Top: Centered title "River" + description + badges
2. 🏆 Awards — FPT First Prize, FPGA Innovation Competition National First Prize
3. 📄 Paper — Title, authors, PDF link, BibTeX
4. 🔥 Highlights — 6 key selling points
5. 📊 Performance — 3 tables (accuracy/latency, cross-platform comparison, resource utilization)
6. 🏗️ Architecture — Diagram + primitive operator table + built-in presets
7. 🚀 Quick Start — Prerequisites, Option A (pre-built), Option B (from source), custom dataflow
8. 📁 Repository Structure — Directory tree
9. 🙏 Acknowledgements — NSFC grants
10. 📜 License — MIT
```

## Content Details

### Badges

- `IEEE FPT 2025` (blue) → links to PDF
- `Award: FPT 2025 Design Competition First Prize` (gold)
- `Award: FPGA Innovation Competition National First Prize` (gold)
- `Platform: Xilinx KV260` (green)
- `License: MIT` (yellow)

### Highlights

1. 30× faster than Intel i7-12700H, 6× faster than NVIDIA RTX 3060
2. Reconfigurable dataflow — compose custom pipelines via primitive operators
3. 7 built-in presets with runtime switching, no bitstream regeneration
4. BF16 precision, microsecond-level latency (2–7 μs)
5. Only 7.352W total power consumption
6. Web-based visual configuration toolchain

### Performance Tables

**Table 1: Latency & Accuracy** (Input: 64×768, BF16, Parallelism=32, 300MHz)

| Function | L2 Relative Error | Latency |
|:---|:---|:---|
| Softmax | 3.36×10⁻³ | 5.78 μs |
| SiLU | 1.00×10⁻⁴ | 5.16 μs |
| GELU | 1.88×10⁻⁴ | 5.34 μs |
| RMSNorm | 3.11×10⁻³ | 6.58 μs |
| LayerNorm | 1.01×10⁻² | 7.40 μs |
| Element-wise Add | 0 | 2.02 μs |
| Element-wise Mul | 0 | 2.02 μs |

**Table 2: Cross-Platform Comparison** (Softmax, 64×768, BF16)

| Platform | L2 Error | Latency | Speedup |
|:---|:---|:---|:---|
| River (FPGA) | 2.4×10⁻³ | 4.9 μs | 1.0× |
| Intel i7-12700H | 1.4×10⁻⁴ | 150.4 μs | 0.033× |
| NVIDIA RTX 3060 | 1.5×10⁻⁴ | 28.2 μs | 0.17× |

**Table 3: FPGA Resource Utilization** (KV260 / XCZU5EV)

| Resource | Used | Available | Utilization |
|:---|:---|:---|:---|
| LUT | 107,301 | 117,120 | 91.62% |
| LUTRAM | 10,009 | 57,600 | 17.38% |
| FF | 122,832 | 234,240 | 52.44% |
| BRAM | 112.5 | 144 | 78.13% |
| DSP | 311 | 1,248 | 24.92% |

### Architecture Section

- Architecture diagram: placeholder PNG path `./docs/architecture.png` (user replaces with paper Fig.1)
- Primitive Operators table: Exp, Accumulator, Reciprocal, InvSqrt, Max, Add/Sub, Multiply, FIFO, AXI Broadcaster
- Built-in Presets table: Softmax, SiLU, GELU, RMSNorm, LayerNorm, Add, Mul with dataflow paths

### Quick Start

- Prerequisites table: Board, Vivado, PYNQ, OS, cross-compiler
- Option A: Pre-built (clone → copy notebook → run)
- Option B: Build from source (Vivado flow)
- Custom dataflow: Web GUI (`Config_Utils/dist`)

### Repository Structure

Standard tree showing: `IEEE_FPT_Conference.pdf`, `vivado_prj/`, `Config_Utils/`, `notebook/`, `ErrTest/`

### Acknowledgements

NSFC Grant 62174084 and 62341408.

### Citation

BibTeX entry for the FPT 2025 paper.

### License

MIT License.

## Action Items

1. Write the new README.md content
2. Create `docs/` directory and placeholder for architecture.png
3. User action: export Fig.1 from paper as `docs/architecture.png`
4. User action: add LICENSE file if not present
