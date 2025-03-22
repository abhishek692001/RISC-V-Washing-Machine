class washing_machine_scoreboard extends uvm_scoreboard;
    // UVM factory registration
    `uvm_component_utils(washing_machine_scoreboard)
    
    // Analysis export to receive transactions from monitor
    uvm_analysis_imp #(washing_machine_transaction, washing_machine_scoreboard) analysis_export;
    
    // Internal state tracking
    bit [3:0] expected_state;
    bit [7:0] expected_remaining_time;
    bit expected_cycle_complete;
    bit expected_error;
    
    // Counters for coverage and reporting
    int num_transactions;
    int num_errors;
    int num_state_transitions;
    int num_cycles_completed;
    
    // State transition tracking
    bit [3:0] previous_state;
    bit state_transition_occurred;
    
    // Constructor
    function new(string name = "washing_machine_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        analysis_export = new("analysis_export", this);
        
        // Initialize counters and state tracking
        num_transactions = 0;
        num_errors = 0;
        num_state_transitions = 0;
        num_cycles_completed = 0;
        
        expected_state = washing_machine_if::IDLE;
        expected_remaining_time = 0;
        expected_cycle_complete = 0;
        expected_error = 0;
        
        previous_state = washing_machine_if::IDLE;
        state_transition_occurred = 0;
    endfunction
    
    // Write method - called when monitor sends a transaction
    virtual function void write(washing_machine_transaction tx);
        // Increment transaction counter
        num_transactions++;
        
        // Check for state transition
        if (tx.current_state != previous_state) begin
            num_state_transitions++;
            state_transition_occurred = 1;
            `uvm_info(get_type_name(), $sformatf("State transition: %0d -> %0d", previous_state, tx.current_state), UVM_MEDIUM)
        end
        else begin
            state_transition_occurred = 0;
        end
        
        // Update previous state
        previous_state = tx.current_state;
        
        // Check for cycle completion
        if (tx.cycle_complete && !expected_cycle_complete) begin
            num_cycles_completed++;
            expected_cycle_complete = 1;
            `uvm_info(get_type_name(), "Wash cycle completed", UVM_MEDIUM)
        end
        
        // Check for errors
        if (tx.error && !expected_error) begin
            num_errors++;
            expected_error = 1;
            `uvm_info(get_type_name(), "Error detected", UVM_MEDIUM)
        end
        
        // Verify state machine behavior
        verify_state_machine(tx);
        
        // Verify outputs based on state
        verify_outputs(tx);
    endfunction
    
    // Verify state machine transitions
    virtual function void verify_state_machine(washing_machine_transaction tx);
        // Check state transitions based on inputs
        case (tx.current_state)
            washing_machine_if::IDLE: begin
                // From IDLE, can go to FILLING if start button pressed and door closed
                if (tx.start_button && tx.door_closed) begin
                    expected_state = washing_machine_if::FILLING;
                end
                // From IDLE, can go to ERROR if start button pressed and door open
                else if (tx.start_button && !tx.door_closed) begin
                    expected_state = washing_machine_if::ERROR_STATE;
                    expected_error = 1;
                end
                else begin
                    expected_state = washing_machine_if::IDLE;
                end
            end
            
            washing_machine_if::FILLING: begin
                // From FILLING, can go to ERROR if door opens
                if (!tx.door_closed) begin
                    expected_state = washing_machine_if::ERROR_STATE;
                    expected_error = 1;
                end
                // From FILLING, can go to HEATING if water level reaches target
                else if (tx.water_level >= 50) begin // Assuming 50 is target for normal program
                    expected_state = washing_machine_if::HEATING;
                end
                else begin
                    expected_state = washing_machine_if::FILLING;
                end
            end
            
            washing_machine_if::HEATING: begin
                // From HEATING, can go to ERROR if door opens
                if (!tx.door_closed) begin
                    expected_state = washing_machine_if::ERROR_STATE;
                    expected_error = 1;
                end
                // From HEATING, can go to WASHING if temperature reaches target
                else if (tx.temperature >= 40) begin // Assuming 40 is target for normal program
                    expected_state = washing_machine_if::WASHING;
                end
                else begin
                    expected_state = washing_machine_if::HEATING;
                end
            end
            
            washing_machine_if::WASHING: begin
                // From WASHING, can go to ERROR if door opens
                if (!tx.door_closed) begin
                    expected_state = washing_machine_if::ERROR_STATE;
                    expected_error = 1;
                end
                // From WASHING, can go to DRAINING when wash time completes
                else if (tx.remaining_time <= expected_remaining_time - 20) begin // Assuming 20 min wash time
                    expected_state = washing_machine_if::DRAINING;
                end
                else begin
                    expected_state = washing_machine_if::WASHING;
                end
            end
            
            washing_machine_if::DRAINING: begin
                // From DRAINING, can go to ERROR if door opens
                if (!tx.door_closed) begin
                    expected_state = washing_machine_if::ERROR_STATE;
                    expected_error = 1;
                end
                // From DRAINING, can go to FILLING for rinse or SPINNING if all rinses done
                else if (tx.water_level <= 5) begin
                    // This is simplified - would need to track rinse count in real implementation
                    if (tx.remaining_time > 5) begin // If more than spin time remaining, must be rinse cycles left
                        expected_state = washing_machine_if::FILLING;
                    end
                    else begin
                        expected_state = washing_machine_if::SPINNING;
                    end
                end
                else begin
                    expected_state = washing_machine_if::DRAINING;
                end
            end
            
            washing_machine_if::RINSING: begin
                // From RINSING, can go to ERROR if door opens
                if (!tx.door_closed) begin
                    expected_state = washing_machine_if::ERROR_STATE;
                    expected_error = 1;
                end
                // From RINSING, can go to DRAINING when rinse time completes
                else if (tx.remaining_time <= expected_remaining_time - 10) begin // Assuming 10 min rinse time
                    expected_state = washing_machine_if::DRAINING;
                end
                else begin
                    expected_state = washing_machine_if::RINSING;
                end
            end
            
            washing_machine_if::SPINNING: begin
                // From SPINNING, can go to ERROR if door opens
                if (!tx.door_closed) begin
                    expected_state = washing_machine_if::ERROR_STATE;
                    expected_error = 1;
                end
                // From SPINNING, can go to COMPLETE when spin time completes
                else if (tx.remaining_time == 0) begin
                    expected_state = washing_machine_if::COMPLETE;
                    expected_cycle_complete = 1;
                end
                else begin
                    expected_state = washing_machine_if::SPINNING;
                end
            end
            
            washing_machine_if::COMPLETE: begin
                // From COMPLETE, can go to IDLE if start button pressed
                if (tx.start_button) begin
                    expected_state = washing_machine_if::IDLE;
                    expected_cycle_complete = 0;
                end
                else begin
                    expected_state = washing_machine_if::COMPLETE;
                end
            end
            
            washing_machine_if::ERROR_STATE: begin
                // From ERROR, can go to IDLE if start button pressed and door closed
                if (tx.start_button && tx.door_closed) begin
                    expected_state = washing_machine_if::IDLE;
                    expected_error = 0;
                end
                else begin
                    expected_state = washing_machine_if::ERROR_STATE;
                end
            end
            
            washing_machine_if::PAUSED: begin
                // From PAUSED, can go back to previous state if pause button pressed again
                if (tx.pause_button) begin
                    // In real implementation, would need to track the state before pause
                    expected_state = previous_state;
                end
                else begin
                    expected_state = washing_machine_if::PAUSED;
                end
            end
            
            default: begin
                // Should never reach here
                `uvm_error(get_type_name(), $sformatf("Unknown state: %0d", tx.current_state))
            end
        endcase
        
        // Update expected remaining time
        if (tx.current_state != washing_machine_if::IDLE && 
            tx.current_state != washing_machine_if::COMPLETE && 
            tx.current_state != washing_machine_if::ERROR_STATE &&
            tx.current_state != washing_machine_if::PAUSED) begin
            expected_remaining_time = tx.remaining_time;
        end
    endfunction
    
    // Verify outputs based on current state
    virtual function void verify_outputs(washing_machine_transaction tx);
        // Check that outputs match expected values for the current state
        case (tx.current_state)
            washing_machine_if::IDLE: begin
                check_output(tx.water_valve, 0, "water_valve in IDLE");
                check_output(tx.drain_valve, 0, "drain_valve in IDLE");
                check_output(tx.motor_speed, 2'b00, "motor_speed in IDLE");
                check_output(tx.motor_direction, 2'b00, "motor_direction in IDLE");
                check_output(tx.heater, 0, "heater in IDLE");
                check_output(tx.detergent_dispenser, 0, "detergent_dispenser in IDLE");
                check_output(tx.softener_dispenser, 0, "softener_dispenser in IDLE");
            end
            
            washing_machine_if::FILLING: begin
                check_output(tx.water_valve, 1, "water_valve in FILLING");
                check_output(tx.drain_valve, 0, "drain_valve in FILLING");
                check_output(tx.motor_speed, 2'b00, "motor_speed in FILLING");
                check_output(tx.motor_direction, 2'b00, "motor_direction in FILLING");
                check_output(tx.heater, 0, "heater in FILLING");
                // Detergent dispenser may be on during first fill
                // Softener dispenser may be on during last rinse fill
            end
            
            washing_machine_if::HEATING: begin
                check_output(tx.water_valve, 0, "water_valve in HEATING");
                check_output(tx.drain_valve, 0, "drain_valve in HEATING");
                check_output(tx.motor_speed, 2'b00, "motor_speed in HEATING");
                check_output(tx.motor_direction, 2'b00, "motor_direction in HEATING");
                check_output(tx.heater, 1, "heater in HEATING");
                check_output(tx.detergent_dispenser, 0, "detergent_dispenser in HEATING");
                check_output(tx.softener_dispenser, 0, "softener_dispenser in HEATING");
            end
            
            washing_machine_if::WASHING: begin
                check_output(tx.water_valve, 0, "water_valve in WASHING");
                check_output(tx.drain_valve, 0, "drain_valve in WASHING");
                check_output(tx.motor_direction, 2'b11, "motor_direction in WASHING"); // Alternating
                check_output(tx.heater, 0, "heater in WASHING");
                check_output(tx.detergent_dispenser, 0, "detergent_dispenser in WASHING");
                check_output(tx.softener_dispenser, 0, "softener_dispenser in WASHING");
            end
            
            washing_machine_if::DRAINING: begin
                check_output(tx.water_valve, 0, "water_valve in DRAINING");
                check_output(tx.drain_valve, 1, "drain_valve in DRAINING");
                check_output(tx.motor_speed, 2'b00, "motor_speed in DRAINING");
                check_output(tx.motor_direction, 2'b00, "motor_direction in DRAINING");
                check_output(tx.heater, 0, "heater in DRAINING");
                check_output(tx.detergent_dispenser, 0, "detergent_dispenser in DRAINING");
                check_output(tx.softener_dispenser, 0, "softener_dispenser in DRAINING");
            end
            
            washing_machine_if::RINSING: begin
                check_output(tx.water_valve, 0, "water_valve in RINSING");
                check_output(tx.drain_valve, 0, "drain_valve in RINSING");
                check_output(tx.motor_direction, 2'b11, "motor_direction in RINSING"); // Alternating
                check_output(tx.heater, 0, "heater in RINSING");
                check_output(tx.detergent_dispenser, 0, "detergent_dispenser in RINSING");
                check_output(tx.softener_dispenser, 0, "softener_dispenser in RINSING");
            end
            
            washing_machine_if::SPINNING: begin
                check_output(tx.water_valve, 0, "water_valve in SPINNING");
                check_output(tx.drain_valve, 0, "drain_valve in SPINNING");
                check_output(tx.motor_direction, 2'b01, "motor_direction in SPINNING"); // Clockwise
                check_output(tx.heater, 0, "heater in SPINNING");
                check_output(tx.detergent_dispenser, 0, "detergent_dispenser in SPINNING");
                check_output(tx.softener_dispenser, 0, "softener_dispenser in SPINNING");
            end
                        
            washing_machine_if::COMPLETE: begin
                check_output(tx.water_valve, 0, "water_valve in COMPLETE");
                check_output(tx.drain_valve, 0, "drain_valve in COMPLETE");
                check_output(tx.motor_speed, 2'b00, "motor_speed in COMPLETE");
                check_output(tx.motor_direction, 2'b00, "motor_direction in COMPLETE");
                check_output(tx.heater, 0, "heater in COMPLETE");
                check_output(tx.detergent_dispenser, 0, "detergent_dispenser in COMPLETE");
                check_output(tx.softener_dispenser, 0, "softener_dispenser in COMPLETE");
                check_output(tx.cycle_complete, 1, "cycle_complete in COMPLETE");
            end
            
            washing_machine_if::ERROR_STATE: begin
                check_output(tx.water_valve, 0, "water_valve in ERROR");
                check_output(tx.drain_valve, 1, "drain_valve in ERROR"); // Drain for safety
                check_output(tx.motor_speed, 2'b00, "motor_speed in ERROR");
                check_output(tx.motor_direction, 2'b00, "motor_direction in ERROR");
                check_output(tx.heater, 0, "heater in ERROR");
                check_output(tx.detergent_dispenser, 0, "detergent_dispenser in ERROR");
                check_output(tx.softener_dispenser, 0, "softener_dispenser in ERROR");
                check_output(tx.error, 1, "error flag in ERROR");
            end
            
            washing_machine_if::PAUSED: begin
                check_output(tx.water_valve, 0, "water_valve in PAUSED");
                check_output(tx.drain_valve, 0, "drain_valve in PAUSED");
                check_output(tx.motor_speed, 2'b00, "motor_speed in PAUSED");
                check_output(tx.motor_direction, 2'b00, "motor_direction in PAUSED");
                check_output(tx.heater, 0, "heater in PAUSED");
                check_output(tx.detergent_dispenser, 0, "detergent_dispenser in PAUSED");
                check_output(tx.softener_dispenser, 0, "softener_dispenser in PAUSED");
            end
        endcase
    endfunction
    
    // Helper function to check output values
    virtual function void check_output(bit actual, bit expected, string message);
        if (actual !== expected) begin
            `uvm_error(get_type_name(), $sformatf("Output check failed: %s, expected %0d, got %0d", message, expected, actual))
        end
    endfunction
    
    // Helper function to check multi-bit output values
    virtual function void check_output(bit [1:0] actual, bit [1:0] expected, string message);
        if (actual !== expected) begin
            `uvm_error(get_type_name(), $sformatf("Output check failed: %s, expected %0d, got %0d", message, expected, actual))
        end
    endfunction
    
    // Report phase - print statistics
    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Scoreboard statistics:"), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Total transactions: %0d", num_transactions), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  State transitions: %0d", num_state_transitions), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Cycles completed: %0d", num_cycles_completed), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Errors detected: %0d", num_errors), UVM_LOW)
    endfunction
endclass 