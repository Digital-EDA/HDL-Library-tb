import numpy as np
import matplotlib.pyplot as plt

N = 64
Fs = 1000
t = np.arange(N) / Fs

def normalize(signal, peak_value=1.0):
    max_val = np.max(np.abs(signal))
    if max_val == 0:
        return signal
    return signal / max_val * peak_value

def generate_signals(peak_value=1.0):
    signals = {}

    frequencies = [50, 100, 200]
    pure_sine_waves = [np.sin(2 * np.pi * f * t) for f in frequencies]
    signals['pure_sine_waves'] = pure_sine_waves

    freq_pairs = [(50, 150), (75, 225), (100, 250)]
    multi_sine_waves = [np.sin(2 * np.pi * f1 * t) + np.sin(2 * np.pi * f2 * t) for f1, f2 in freq_pairs]
    signals['multi_sine_waves'] = multi_sine_waves

    pulse_positions = [16, 32, 48]
    pulse_signals = [np.zeros(N) for _ in pulse_positions]
    for signal, pos in zip(pulse_signals, pulse_positions):
        signal[pos] = 1
    signals['pulse_signals'] = pulse_signals

    return signals

def generate_complex_signals(peak_value=1.0):
    signals = {}

    frequencies = [50, 100, 200]
    phases = [np.pi/4, np.pi/2, 3*np.pi/4]
    complex_sine_waves = [normalize(np.exp(1j * (2 * np.pi * f * t + p)), peak_value) for f, p in zip(frequencies, phases)]
    signals['complex_sine_waves'] = complex_sine_waves

    freq_pairs = [(50, 150), (75, 225), (100, 250)]
    complex_multi_sine_waves = [normalize(np.exp(1j * 2 * np.pi * f1 * t) + np.exp(1j * 2 * np.pi * f2 * t), peak_value) for f1, f2 in freq_pairs]
    signals['complex_multi_sine_waves'] = complex_multi_sine_waves

    pulse_positions = [512, 1024, 1536]
    complex_pulse_signals = [np.zeros(N, dtype=complex) for _ in pulse_positions]
    for signal, pos in zip(complex_pulse_signals, pulse_positions):
        signal[pos] = peak_value * (1 + 1j)
    signals['complex_pulse_signals'] = complex_pulse_signals

    return signals

def split_real_imag(signals):
    real_imag_signals = {}
    for key, signal_list in signals.items():
        real_imag_signals[key] = [(np.real(signal), np.imag(signal)) for signal in signal_list]
    return real_imag_signals
