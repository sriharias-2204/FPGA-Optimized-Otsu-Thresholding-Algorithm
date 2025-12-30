# FPGA-Optimized-Otsu-Thresholding-Algorithm

A synthesizable SystemVerilog implementation of the Otsu Image Thresholding algorithm designed for FPGA and ASIC flows. This project features a streaming pixel interface, an FSM-based architecture, and a Python-based verification environment.

## Features
- **Streaming Architecture:** Processes pixels on-the-fly, suitable for real-time video processing.
- **Hardware Optimized:** Uses bit-shifting and resource sharing to avoid massive hardware overhead.
- **Precision Handling:** Implements bit-width expansion (up to 64-bit) to prevent arithmetic overflow during variance calculation.
- **Verification Suite:** Includes a Python script for "Golden Model" generation and a SystemVerilog Testbench for RTL verification.

## Repository Structure
├── rtl/

│   └── otsu_thresholding_fpga.sv  # Main RTL Module

├── tb/

│   └── otsu_tb.sv                 # SystemVerilog Testbench

├── python/

│   ├── front.py              # Image to Hex converter & OpenCV Golden Model

│   └── image.png            # Sample test image

├── docs/

│   └── report.pdf                 # Detailed Technical Report

└── README.md

Markdown## 🛠️ Getting Started

### Prerequisites
- **HDL Simulator:** ModelSim, Questa, or Vivado Xsim.
- **Python 3.x:** With `opencv-python` and `numpy` installed.

### Execution Flow
1. **Prepare Data:** Run the Python script to convert your image to a `.hex` file.
   ```bash
   python python/image_prep.py
Simulate RTL: Load the RTL and Testbench into your simulator. Ensure image_in.hex is in the simulation directory.Verify: Compare the threshold output in the simulator console with the Python output. 

### Results
Image      Python(Golden)  Hardware(RTL)  Status

Cameraman       86              86         Pass
