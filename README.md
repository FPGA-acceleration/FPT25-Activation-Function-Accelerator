# 🧠 LLM Activation Accelerator on FPGA

## 📘 Project Overview
This project implements a **hardware accelerator** for activation functions used in **Large Language Models (LLMs)** — Include SoftMax, RMSNorm, LayerNorm, GELU, ReLU, SiLU,  element wise ADD and Mul— on FPGA.  
The goal is to **reduce inference time** and **power consumption** by offloading non-linear computation from CPU/GPU to a dedicated FPGA module.

Key features:
- Support for multiple activation types.
- Caculate based on the hardware friendly format - bf16
- Tool chain to config the data stream.
- High-throughput parallel mode

---

## 🧩 System Architecture
The accelerator consists of:
1. **Input interface (AXI-Stream)** — receives activation input vectors  
2. **Reconfigable calculate datastream** — performs parallelized computation  
3. **Lookup Table (LUT) + Approximation Unit** — for non-linear functions (e.g., GELU, Softmax)

---

## 💻 Runtime Environment and Toolchain

| Category | Detailed Description |
| :--- | :--- |
| **Target Hardware (FPGA)** | Xilinx KV260 Zynq UltraScale+ MPSoC|
| **Design Language** |Verilog HDL|
| **Development Toolchain** | **Xilinx Vivado 2024.02, Jupyter Notebook** |
| **Operating System** | Linux (Ubuntu 22.04) |

---
