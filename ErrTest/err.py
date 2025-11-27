import torch
import numpy as np

# === 1. Load ref_softmax.pt ===
ref = torch.load("ref_softmax_bf16.pt", weights_only=True)

# Convert to float32 (bfloat16 cannot be directly computed)
if ref.dtype == torch.bfloat16:
    ref = ref.to(torch.float32)
ref = ref.cpu().numpy()

# === 2. Load result.npy ===
result = np.load("result.npy")

# Check dtype and convert BF16 → FP32
if result.dtype == np.uint16:  # Likely BF16 bit storage
    def bf16_to_fp32(bf16_array):
        fp32 = bf16_array.astype(np.uint32) << 16  # High 16 bits
        return fp32.view(np.float32)
    result = bf16_to_fp32(result)
elif result.dtype == np.float16:
    result = result.astype(np.float32)
else:
    result = result.astype(np.float32)

# === 3. Check shape consistency ===
assert ref.shape == result.shape, f"Shape mismatch: {ref.shape} vs {result.shape}"

# === 4. Remove NaN and Inf ===
ref = np.nan_to_num(ref, nan=0.0, posinf=0.0, neginf=0.0)
result = np.nan_to_num(result, nan=0.0, posinf=0.0, neginf=0.0)

# === 4. Select focus rows for each function ===
idx = np.r_[0:63]

# === 5. Compute L2 relative error ===
num = np.linalg.norm(ref[idx] - result[idx])
den = np.linalg.norm(ref[idx]) + 1e-12  # Prevent division by zero
rel_l2_error = num / den

print(f"✅ L2 relative error (cleaned): {rel_l2_error:.6e}")
