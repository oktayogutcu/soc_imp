# SoC Implementations and Verification Repository

This repository is dedicated to the implementation and verification of System on Chip (SoC) designs using the Universal VHDL Verification Methodology (UVVM) library. It contains multiple SoC implementations along with their verification environments, leveraging ModelSim 20.1 for all simulation and verification tasks.

## Getting Started with UVVM

For the verification process of SoC designs, the UVVM library is essential. If the UVVM library has not been installed, it can be downloaded from its official GitHub repository:

- [UVVM GitHub Repository](https://github.com/UVVM/UVVM)

Downloading the repository is a prerequisite for proceeding with the subsequent steps for simulation and verification.

## Compilation of Sources

After obtaining the UVVM library, the next step involves compiling all sources to be used with ModelSim. Execute the following command in the ModelSim terminal to compile the sources:

```bash
do ./UVVM/script/compile_all.do ./UVVM ./<target_location>
```

It is necessary to replace `<target_location>` with the directory path where the compiled sources will be stored. This step is crucial for preparing the sources for simulation.

## Configuring ModelSim for UVVM

After compilation, configuring ModelSim to recognize the UVVM libraries for new projects is necessary. This is achieved by updating the `modelsim.ini` file located in the root directory of the ModelSim installation. Typically, for a Windows system equipped with Intel FPGA software version 20.1, the path to this file would be:

```plaintext
C:\intelFPGA\20.1\modelsim_ase\modelsim.ini
```

Adding the paths to the compiled UVVM libraries in this `modelsim.ini` file enables ModelSim to locate and utilize these libraries for simulation.

## Conclusion

Following the outlined steps prepares users for simulating and verifying SoC designs using the UVVM library within ModelSim 20.1. This setup facilitates thorough testing and verification of SoC implementations, ensuring their utmost reliability and performance.

Appreciation is extended to all visitors of this repository, hoping this guide proves helpful in SoC design and verification projects.




## Projects

- [Testing UVVM Library](https://github.com/oktayogutcu/soc_imp/tree/main/uvvm_test)
- [Testing AXI4-Lite Interface with UVVM Library](https://github.com/oktayogutcu/soc_imp/tree/main/axi_lite_test)
