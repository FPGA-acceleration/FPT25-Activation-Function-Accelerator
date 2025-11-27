# Directory Structure
- `acc_finalv2.xsa`: The xsa file generate by the vivado.
- `acc.ipynb`: The python code in jupyter notebook.
- `config.so`: The **C** Library to config the PL. It is used in the `acc.ipynb`.
- `result.npy`: The calculate result exported from the `acc.ipynb`
- `X_test_tensor_bf16.bin` The source data.
- `Y_test_tensor_bf16.bin` The data used for the element wise add and mul.