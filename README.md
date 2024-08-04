# UART Communication Protocol on BASYS3

## Project Overview

This project aims to create a communication protocol called UART (Universal Asynchronous Receiver-Transmitter) between two BASYS3 boards. The main module is `UART_Device`, and it integrates four submodules: `buttonDebouncer`, `BCDToSevenSegment`, `TXBUF`, and `RXBUF`.

## Modules

### UART_Device

The `UART_Device` module is the top-level module that incorporates the functionality of all submodules to implement the UART communication protocol.

### buttonDebouncer

The `buttonDebouncer` module prevents button bounces. When a button is pressed, it can bounce due to physical properties, causing the input to fluctuate between 0 and 1. This fluctuation can result in multiple calls to a function when there should be only one. The `buttonDebouncer` module waits for 20000 clock cycles after the button is pressed and then captures the input value, effectively eliminating button bounces.

### BCDToSevenSegment

The `BCDToSevenSegment` module converts numerical outputs to a seven-segment display format. This conversion enables the activation of the seven-segment display in the UART module.

### TXBUF

The `TXBUF` module is responsible for transmitting data from one BASYS3 board to another. It operates through six states:

1. **idleState**: Resets counters and remains inactive.
2. **loadState**: Loads the data input as a complete message, including start bit, data bits, parity bit, and stop bit.
3. **loadWaitState**: Waits for the load button to return to 0 to prevent multiple loads, ensuring activation of the load state on a positive edge from 0 to 1.
4. **transmitState**: Sends the data bit by bit through a cable. If the auto-transfer switch is on, this state runs four times to send all loaded data.
5. **transmitWaitState**: Waits for the transmit enable input to return to 0, similar to `loadWaitState`, to prevent multiple transmissions.
6. **autoState**: Manages the auto-transfer process.

### RXBUF

The `RXBUF` module receives data sent from the other BASYS3 board. It operates through three states:

1. **idleState**: Waits for an input signal.
2. **receiveState**: Enters this state upon receiving a start bit (0). It balances the receiving frequency with the transmission frequency and stores each received bit in memory until the stop bit is detected.
3. **processState**: Checks the parity of the received message. If the message has an odd number of 1’s, it indicates an error during transmission and outputs 0. If the message is correct, it outputs the received message. After processing, the module returns to `idleState` to wait for a new message.

## Conclusion

This project successfully implements a UART communication protocol between two BASYS3 boards using the `UART_Device` module and its submodules. The system handles button debouncing, data conversion for seven-segment displays, data transmission, and data reception efficiently.

## License

This project is licensed under the MIT License.

## Contact

For any questions or feedback, please contact [your_email@example.com].
