# GMSK Demo Project

This project demonstrates the setup, tooling, and structure required for the design and simulation of a **GMSK receiver** in the TSMC 65nm technology node. The focus is on providing a hands-on experience with analog, digital, and mixed-signal flows. **Note:** The chip design is intentionally nonsensical and is not intended for practical use.


## Chip Overview

![Chip Structure](img/chip.png)

The **GMSK chip** comprises two primary components:

### **Analog Part (anatop)**
-   A **comparator** to convert the input signal into a digital bitstream.
-   A switchable **capacitor bank** that can modify the input signal.

### **Digital Part (digitop)**
- An **up/down counter** controlled by the input bitstream.  
- Counter output is bitwise-**inverted** and **delayed** by 2 clock cycles.
-  A **toggled loop detector** feeds back to the capacitor bank of anatop.

### Testbench Components

-   **Analog:** `anatop_driver`, `biasing`.
-   **Digital:** `clk_gen`.


## Tooling

The project requires access to the following on **ESAT server infrastructure**:
-   **Cadence Virtuoso Studio 23.10.020** (Analog design and simulation)
-   **Cadence Spectre 23.10.242** (Analog simulation)
-   **Cadence Xcelium 23.09.008** (Digital and mixed-signal simulation)
-   **TSMC 65nm** (PDK access)


## Directory Structure

The project files are organized as follows:
```
analog/                   - Analog source files organized as a Cadence library
digital/                  - Digital design files (hierarchically structured)
  ├── rtl/                - RTL source files for digital blocks
  └── tb/                 - Digital testbench files
chiptop/                  - Mixed-signal chiptop design and test files
  ├── rtl/                - RTL source files for chiptop
  └── tb/                 - Testbench files for mixed-signal simulation
run/                      - Run-directory (from where you should execute simulations)
  └── commands/           - Example shell scripts for running simulations
  └── cds.lib             - Cadence library file
  └── clean               - Shell script to clean Run-directory
scripts/                  - Helper scripts
  └── SpectreNetlister.sh - Netlisting tool for mixed-signal simulations
setup                     - Environment setup
```


## Setup and Workflow
### **Environment Setup**

1.  Source the environment setup script before starting:
```bash
source setup
```
2. Switch to the `run` directory to ensure clean execution without cluttering the repository:
```bash
cd $WORK_DIR/run
```

### **Simulation Instructions**

#### **Analog Flow**
-   Use **Cadence Virtuoso** for analog design and simulation.
-   The design library (`gmsk`) is mapped to `$WORK_DIR/analog`.
-   Design and simulate using the **Schematic Editor** and **ADE Explorer**.

#### **Digital Flow**
-   Simulate the digital design using **Cadence Xcelium** (`xrun`).
-   Edit files using your preferred text editor (e.g., Vim, VS Code).

#### **Mixed-Signal Flow**
-   Mixed-signal simulations use **Xcelium AMS**, which interfaces with **Spectre** for analog components.
-   Netlist the analog blocks using **SpectreNetlister** tool.
-   Write `amscf.scs` to control the analog part of the simulation.
-   Define analog-to-digital or digital-to-analog interfaces with `amsd`-blocks.
-   Use **Cadence Simvision** to inspect analog/digital waves.

#### **Example Simulation Commands**
The `run/commands` directory contains pre-configured shell scripts to help you execute simulations for each flow.
These scripts are executable and serve as examples for running various simulations.
