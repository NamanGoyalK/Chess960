# Resource Efficient FPGA Realization of Chess960 Position Generator

This repository contains the **hardware and software implementation** of a **Chess960 starting position generator**, as presented in the IEEE SISIMPACT 2025 paper.

The work focuses on a **resource efficient FPGA based realization** of Chess960 position generation with **deterministic timing, low power consumption, and minimal logic utilization**, targeting embedded and covert communication systems.

This is **not a full steganographic protocol**. It is a **foundational hardware module**.

---

## What This Project Actually Does

* Generates **all 960 valid Chess960 starting positions**
* Deterministic generation from a **10 bit seed 0 to 959**
* Enforces all Chess960 constraints in hardware
* Implemented and validated on **Xilinx Zynq 7020 FPGA**
* Benchmarked against optimized software implementations

---

## Key Contributions

* FPGA based Chess960 position generator
* **2.17 percent LUT utilization**
* **0.566 W total power consumption**
* **Fixed latency of 451 cycles**
* Deterministic timing suitable for embedded systems
* Hardware and software performance comparison

---

## Architecture Overview

* Input interface accepts a 10 bit seed
* Constraint based position generation logic
* Finite state control logic
* Output interface for position formatting
* Verified via simulation and real hardware deployment

---

## Use Cases

* Embedded steganographic systems
* Covert communication primitives
* Hardware based random position generation
* Cryptographic preprocessing and key derivation research
* FPGA accelerated chess related systems

---

## What This Project Does NOT Do

* No full steganographic protocol
* No encryption or authentication layer
* No data compression pipeline
* No distributed storage system

Those are **future work**, not claims.

---

## Paper

**Resource Efficient FPGA Realization of Chess960 Position Generator for Future Covert Communication Systems**
IEEE SISIMPACT 2025

---

## Citation

If you use this work, **cite the paper**.

### BibTeX

```bibtex
@inproceedings{goyal2025chess960,
  title={Resource-Efficient FPGA Realization of Chess960 Position Generator for Future Covert Communication Systems},
  author={Goyal, Naman and Gogoi, Partha Pratim and Tripathi, Abhishek Narayan and Laskar, Naushad Manzoor},
  booktitle={2025 IEEE 1st International Conference on Smart Innovations in Systems, Infrastructure, Mechanical, Power, AI and Computing Technologies (SISIMPACT)},
  year={2025},
  publisher={IEEE}
}
```

---

## License

Apache License 2.0
