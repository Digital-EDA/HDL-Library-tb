import sys
import random
import tools
from scipy.fftpack import fft
from pathlib import Path

proj_path = Path(__file__).resolve().parent.parent
sys.path.append(str(proj_path))

import cocotb
import cocotb.simulator
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def pure_sin_test(dut):
    """Test Pure Sine Signals"""

    # get signal
    signals = []
    for _ in range(2 ** len(dut.iaddr)):
        re = random.randint(-(2 ** (len(dut.iaddr) - 1)), (2 ** (len(dut.iaddr) - 1)))
        im = random.randint(-(2 ** (len(dut.iaddr) - 1)), (2 ** (len(dut.iaddr) - 1)))
        signals.append(re + im * 1j)

    # set clock
    clk = Clock(dut.iclk, 20, "ns")
    await cocotb.start(clk.start())

    # reset dut
    dut.rstn.value = 0
    for _ in range(3):
        await RisingEdge(dut.iclk)
    dut.rstn.value = 1

    # run simulation
    dut_output = []

    dut.ien.value = 1

    for addr in range(2 ** len(dut.iaddr)):
        dut.iaddr.value = addr
        dut.iReal.value = round(signals[addr].real)
        dut.iImag.value = round(signals[addr].imag)
        await RisingEdge(dut.iclk)
    
    dut.ien.value = 0

    while True:
        if dut.oen.value:
            dut_output.append(dut.oReal.value.signed_integer + dut.oImag.value.signed_integer*1j)
            if (dut.oaddr.value == 2 ** len(dut.oaddr) - 1):
                break
        await RisingEdge(dut.iclk)

    await Timer(100, "ns")
 
    ref_output = []
    dut.ref_ien.value = 1
        
    for addr in range(2 ** len(dut.iaddr)):
        dut.iaddr.value = addr
        dut.iReal.value = round(signals[addr].real)
        dut.iImag.value = round(signals[addr].imag)
        await RisingEdge(dut.iclk)

    await RisingEdge(dut.ref_osync)
    await RisingEdge(dut.iclk)
    for _ in range(64):
        ref_output.append(dut.ref_oreal.value.signed_integer + dut.ref_oimag.value.signed_integer*1j)
        await RisingEdge(dut.iclk)

    await Timer(100, "ns")

    py_output = fft(signals)
    tools.drawFFT(dut_output, ref_output, py_output)
