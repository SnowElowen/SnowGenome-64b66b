# SnowGenome-64b66b
## A reproducible FPGA genomics streaming front-end for 64b/66b-style ingress, 2-bit DNA tokenization, rolling k-mer screening, and motif convolution scoring.

## Open-source FPGA genomics streaming front-end for 64b/66b-style ingest, 2-bit DNA encoding, rolling k-mer generation, 
target screening,and motif scoring.
Built with reproducible RTL, testbench, XDC, Tcl flow, and Vivado timing evidence。
# SnowGenome-64b66b

SnowGenome-64b66b is an open-source FPGA genomics streaming front-end designed to explore deterministic hardware acceleration for high-throughput sequencing data.

The project focuses on the early streaming stage of genomic data processing: accepting a 64b/66b-style input stream, converting packed DNA bases into a 2-bit hardware representation, generating rolling k-mers, applying target screening, and producing candidate biological events for downstream software or hardware pipelines.

This repository is not a complete base-caller, aligner, variant caller, or medical diagnostic system. Instead, it provides a reproducible FPGA foundation for genomics stream filtering, k-mer processing, and motif-style scoring. The goal is to make low-level FPGA acceleration for genomics easier to study, reproduce, extend, and benchmark.

The first public release includes synthesizable Verilog RTL, simulation testbenches, XDC timing constraints, Vivado Tcl scripts, synthetic input data, and a reproducible project structure targeting Xilinx UltraScale+ class devices.

## The final Vision

Modern sequencing platforms can generate massive amounts of biological data, but turning raw reads into useful candidate signals still requires significant computation. SnowGenome-64b66b explores how deterministic FPGA hardware can help move part of that early filtering work closer to the data stream itself.

The long-term vision is to build an open and reproducible hardware foundation for genomic stream acceleration: from DNA base tokenization, rolling k-mer generation, and target-panel screening, toward larger filters, motif scoring, and hardware-assisted preprocessing for downstream bioinformatics workflows.

This project is built as an engineering contribution rather than a medical claim. It aims to provide transparent RTL, constraints, test data, timing reports, and implementation methodology so that researchers, engineers, and students can inspect the hardware, reproduce the results, and adapt the pipeline for their own genomic workloads.



