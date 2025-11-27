# This is the vivado project for the Accelerator hardware design

- **vivado_prj.src** folder include all of the source code(.v file and xilinx ip core)
- **vivado_prj.xpr** is the project file, which can be opened by vivado directly

You can open the xpr file in vivado gui directly, to generate the bitstream and xsa file.

---

# Build the project following the steps:
- Open the xpr file in the vivado gui.
- Generate the output product for the block design.
- Create the HDL wrapper and set it as the top module.
- Run synth->Run impl->Write bitstream->Export the xsa file.

---
**💡Note :** We’ve already built everything and exported the XSA file. You can simply open `../notebook` and use it directly with the PYNQ framework in jupyter notebook