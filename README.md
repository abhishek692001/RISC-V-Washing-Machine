# RISC-V Based Washing Machine Controller with UVM Verification

This project implements a RISC-V based washing machine controller in Verilog RTL along with a comprehensive UVM testbench for verification.

## Project Structure

### RTL Design
- `riscv_washing_machine_controller.v`: Main RISC-V based washing machine controller module

### UVM Testbench
- `washing_machine_if.sv`: Interface definition
- `washing_machine_transaction.sv`: Transaction class
- `washing_machine_sequence_base.sv`: Base sequence class
- `washing_machine_sequences.sv`: Test-specific sequences
- `washing_machine_driver.sv`: Driver class
- `washing_machine_monitor.sv`: Monitor class
- `washing_machine_scoreboard.sv`: Scoreboard class
- `washing_machine_coverage.sv`: Coverage model
- `washing_machine_agent.sv`: Agent class
- `washing_machine_env.sv`: Environment class
- `washing_machine_test_base.sv`: Base test class
- `washing_machine_tests.sv`: Test-specific classes
- `washing_machine_tb_top.sv`: Top-level testbench

## Design Overview

The washing machine controller is implemented using a simplified RISC-V processor core that executes a washing machine control program. The controller manages the following components:

- Water inlet valve
- Drain valve
- Motor (with variable speed and direction)
- Heater
- Detergent and softener dispensers

The controller supports multiple washing programs (Quick, Normal, Heavy, Delicate, Custom) and handles various error conditions, such as door opening during operation.

## State Machine

The washing machine operates through the following states:
1. IDLE: Waiting for start button
2. FILLING: Filling the drum with water
3. HEATING: Heating the water to target temperature
4. WASHING: Main wash cycle
5. RINSING: Rinse cycle
6. SPINNING: Spin cycle
7. DRAINING: Draining water
8. COMPLETE: Cycle completed
9. ERROR_STATE: Error detected
10. PAUSED: Cycle paused

## UVM Verification

The UVM testbench provides comprehensive verification of the washing machine controller, including:

### Test Sequences
- Normal operation sequence: Tests a complete washing cycle
- Door open error sequence: Tests error handling when door is opened during operation
- Pause-resume sequence: Tests pausing and resuming the cycle
- Program change sequence: Tests different washing programs
- Sensor error sequence: Tests behavior with erratic sensor readings

### Coverage
- State coverage: Ensures all states are visited
- State transition coverage: Ensures all valid state transitions are covered
- Program selection coverage: Ensures all programs are tested
- Error condition coverage: Ensures all error conditions are tested
- Pause-resume coverage: Ensures pause functionality works in all states
- Sensor input coverage: Ensures a range of sensor values are tested
- Output coverage: Ensures all output combinations are tested
- Cycle completion coverage: Ensures full cycles are completed

## Running the Tests

To run a specific test:
```
vsim -novopt washing_machine_tb_top +UVM_TESTNAME=normal_operation_test
```

To run the regression test (all tests in sequence):
```
vsim -novopt washing_machine_tb_top +UVM_TESTNAME=regression_test
```

## RISC-V Implementation

The washing machine controller uses a simplified RISC-V implementation with:
- 8 general-purpose registers
- Basic instruction set (LOAD, STORE, ADD, SUB, BRANCH, JUMP)
- Program memory with washing machine control program

This implementation demonstrates how a RISC-V core can be used for embedded control applications like a washing machine controller. 