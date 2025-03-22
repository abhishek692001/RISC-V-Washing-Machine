`include "uvm_macros.svh"
import uvm_pkg::*;

// Include all UVM files
`include "washing_machine_if.sv"
`include "washing_machine_transaction.sv"
`include "washing_machine_sequence_base.sv"
`include "washing_machine_sequences.sv"
`include "washing_machine_driver.sv"
`include "washing_machine_monitor.sv"
`include "washing_machine_scoreboard.sv"
`include "washing_machine_coverage.sv"
`include "washing_machine_agent.sv"
`include "washing_machine_env.sv"
`include "washing_machine_test_base.sv"
`include "washing_machine_tests.sv"

module washing_machine_tb_top;
    // Clock and reset
    bit clk;
    bit rst_n;
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Interface instance
    washing_machine_if vif(clk, rst_n);
    
    // DUT instance
    riscv_washing_machine_controller dut (
        .clk(clk),
        .rst_n(rst_n),
        .start_button(vif.start_button),
        .pause_button(vif.pause_button),
        .door_closed(vif.door_closed),
        .program_select(vif.program_select),
        .water_level(vif.water_level),
        .temperature(vif.temperature),
        .load_weight(vif.load_weight),
        .water_valve(vif.water_valve),
        .drain_valve(vif.drain_valve),
        .motor_speed(vif.motor_speed),
        .motor_direction(vif.motor_direction),
        .heater(vif.heater),
        .detergent_dispenser(vif.detergent_dispenser),
        .softener_dispenser(vif.softener_dispenser),
        .current_state(vif.current_state),
        .remaining_time(vif.remaining_time),
        .cycle_complete(vif.cycle_complete),
        .error(vif.error)
    );
    
    // Initial block to start the test
    initial begin
        // Set the interface in the config DB
        uvm_config_db#(virtual washing_machine_if)::set(null, "*", "vif", vif);
        
        // Start UVM phases
        run_test();
    end
    
    // Dump waveforms
    initial begin
        $dumpfile("washing_machine.vcd");
        $dumpvars(0, washing_machine_tb_top);
    end
    
    // Timeout to prevent infinite simulation
    initial begin
        #1000000; // 1ms at timescale 1ns/1ps
        `uvm_fatal("TIMEOUT", "Simulation timed out")
    end
endmodule 