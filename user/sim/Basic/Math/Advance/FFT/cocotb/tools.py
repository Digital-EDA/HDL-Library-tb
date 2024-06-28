import numpy as np
import matplotlib.pyplot as plt

def normalize(array):
    min = np.min(array)
    max = np.max(array)
    normalized = 2 * (array - min) / (max - min) - 1
    return normalized

def drawFFT(dut, ref, py):
    dut_re = []; dut_im = []
    for val in dut:
        dut_re.append(val.real)
        dut_im.append(val.imag)
    dut_re = normalize(dut_re)
    dut_im = normalize(dut_im)

    ref_re = []; ref_im = []
    for val in ref:
        ref_re.append(val.real)
        ref_im.append(val.imag)
    ref_re = normalize(ref_re)
    ref_im = normalize(ref_im)
    
    py_re = []; py_im = []
    for val in py:
        py_re.append(val.real)
        py_im.append(val.imag)
    py_re = normalize(py_re)
    py_im = normalize(py_im)
    
    plt.plot(range(len(dut)), dut_re, label="dut")
    plt.plot(range(len(ref)), ref_re, label="ref")
    plt.plot(range(len(py)),  py_re,  label="python-fft")
    plt.legend()
    plt.savefig("all.png")

    mse_re = np.mean((dut_re - ref_re) ** 2)
    mse_im = np.mean((dut_im - ref_im) ** 2)
    print(f"re mse   -> {mse_re} ; im mse   -> {mse_im}")
