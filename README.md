
# UART Design Verification

This repository contains the Verilog code for a UART (Universal Asynchronous Receiver/Transmitter) design, along with the verification environment for simulating and testing the functionality.

## Project Description

The UART module supports data transmission and reception with parameterizable baud rates and clock frequencies. It is verified using SystemVerilog and includes a testbench with a generator, driver, monitor, and scoreboard to validate the UART's functionality.

### Key Modules:
- **uart_top**: Top-level UART module integrating the UART transmitter and receiver.
- **uarttx**: UART transmitter responsible for serial data transmission.
- **uartrx**: UART receiver that captures serial data.
- **Testbench**: Verification components including generator, driver, monitor, and scoreboard.

### Features:

- Full transaction-level verification using testbench with generator, driver, and monitor.
- Scoreboard to compare transmitted and received data.
