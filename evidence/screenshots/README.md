# Screenshots to include before submission

Recommended screenshots:

1. Directed regression terminal showing all six tests pass.
2. GTKWave VGA timing view with `hcount`, `vcount`, `hsync`, `vsync`, `video_active`, `rgb`, `fb_addr`, `fb_rdata`, and `trap`.
3. GTKWave/SoC activity view showing CPU/VGA activity and `trap = 0`.
4. Questa UVM terminal showing `UVM_ERROR : 0` and `UVM_FATAL : 0`.
5. Yosys ASIC synthesis completion/netlist evidence.
6. One representative animation frame (the PNG files are already under `evidence/frames/`).

FPGA hardware and final routed GDS screenshots are not included because those stages were not completed.
