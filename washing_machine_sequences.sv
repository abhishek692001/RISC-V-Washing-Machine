// Normal operation sequence - runs a complete washing cycle
class normal_operation_sequence extends washing_machine_sequence_base;
    `uvm_object_utils(normal_operation_sequence)
    
    function new(string name = "normal_operation_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        washing_machine_transaction tx;
        
        // Start a normal wash cycle with door closed
        `uvm_info(get_type_name(), "Starting normal wash cycle", UVM_MEDIUM)
        tx = send_transaction(
            .start_button(1),
            .door_closed(1),
            .program_select(3'b001), // Normal program
            .load_weight(8'd50)
        );
        
        // Wait for filling state
        `uvm_info(get_type_name(), "Waiting for FILLING state", UVM_MEDIUM)
        wait_for_state(washing_machine_if::FILLING);
        
        // Simulate water level rising
        repeat(10) begin
            tx = send_transaction(
                .door_closed(1),
                .water_level(tx.water_level + 8'd5)
            );
            #1000; // Wait some time between updates
        end
        
        // Wait for heating state
        `uvm_info(get_type_name(), "Waiting for HEATING state", UVM_MEDIUM)
        wait_for_state(washing_machine_if::HEATING);
        
        // Simulate temperature rising
        repeat(8) begin
            tx = send_transaction(
                .door_closed(1),
                .water_level(8'd50),
                .temperature(tx.temperature + 8'd5)
            );
            #1000;
        end
        
        // Wait for washing state
        `uvm_info(get_type_name(), "Waiting for WASHING state", UVM_MEDIUM)
        wait_for_state(washing_machine_if::WASHING);
        
        // Let washing complete (would take a while in real time)
        repeat(5) begin
            tx = send_transaction(
                .door_closed(1),
                .water_level(8'd50),
                .temperature(8'd40)
            );
            #5000;
        end
        
        // Wait for draining state
        `uvm_info(get_type_name(), "Waiting for DRAINING state", UVM_MEDIUM)
        wait_for_state(washing_machine_if::DRAINING);
        
        // Simulate water level decreasing
        repeat(10) begin
            tx = send_transaction(
                .door_closed(1),
                .water_level(tx.water_level > 8'd5 ? tx.water_level - 8'd5 : 8'd0)
            );
            #1000;
        end
        
        // Wait for filling state (rinse cycle)
        `uvm_info(get_type_name(), "Waiting for FILLING state (rinse cycle)", UVM_MEDIUM)
        wait_for_state(washing_machine_if::FILLING);
        
        // Simulate water level rising for rinse
        repeat(10) begin
            tx = send_transaction(
                .door_closed(1),
                .water_level(tx.water_level + 8'd5)
            );
            #1000;
        end
        
        // Wait for rinsing state
        `uvm_info(get_type_name(), "Waiting for RINSING state", UVM_MEDIUM)
        wait_for_state(washing_machine_if::RINSING);
        
        // Let rinsing complete
        repeat(3) begin
            tx = send_transaction(.door_closed(1));
            #5000;
        end
        
        // Wait for draining state again
        `uvm_info(get_type_name(), "Waiting for DRAINING state (after rinse)", UVM_MEDIUM)
        wait_for_state(washing_machine_if::DRAINING);
        
        // Simulate water level decreasing
        repeat(10) begin
            tx = send_transaction(
                .door_closed(1),
                .water_level(tx.water_level > 8'd5 ? tx.water_level - 8'd5 : 8'd0)
            );
            #1000;
        end
        
        // Wait for spinning state
        `uvm_info(get_type_name(), "Waiting for SPINNING state", UVM_MEDIUM)
        wait_for_state(washing_machine_if::SPINNING);
        
        // Let spinning complete
        repeat(3) begin
            tx = send_transaction(.door_closed(1));
            #5000;
        end
        
        // Wait for cycle completion
        `uvm_info(get_type_name(), "Waiting for cycle completion", UVM_MEDIUM)
        wait_for_cycle_complete();
        
        `uvm_info(get_type_name(), "Normal wash cycle completed successfully", UVM_MEDIUM)
    endtask
endclass

// Door open error sequence - tests the error handling when door is opened during operation
class door_open_error_sequence extends washing_machine_sequence_base;
    `uvm_object_utils(door_open_error_sequence)
    
    function new(string name = "door_open_error_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        washing_machine_transaction tx;
        
        // Start a normal wash cycle with door closed
        `uvm_info(get_type_name(), "Starting wash cycle for door open test", UVM_MEDIUM)
        tx = send_transaction(
            .start_button(1),
            .door_closed(1),
            .program_select(3'b001) // Normal program
        );
        
        // Wait for filling state
        `uvm_info(get_type_name(), "Waiting for FILLING state", UVM_MEDIUM)
        wait_for_state(washing_machine_if::FILLING);
        
        // Simulate water level rising
        repeat(5) begin
            tx = send_transaction(
                .door_closed(1),
                .water_level(tx.water_level + 8'd10)
            );
            #1000;
        end
        
        // Open the door during operation - should trigger error
        `uvm_info(get_type_name(), "Opening door during operation", UVM_MEDIUM)
        tx = send_transaction(
            .door_closed(0),
            .water_level(8'd50),
            .transaction_type(washing_machine_transaction::DOOR_OPEN_ERROR)
        );
        
        // Wait for error state
        `uvm_info(get_type_name(), "Waiting for ERROR state", UVM_MEDIUM)
        wait_for_state(washing_machine_if::ERROR_STATE);
        
        // Verify error flag is set
        assert(tx.error == 1) else
            `uvm_error(get_type_name(), "Error flag not set when door opened during operation")
        
        // Close door and press start to reset
        `uvm_info(get_type_name(), "Closing door and pressing start to reset", UVM_MEDIUM)
        tx = send_transaction(
            .start_button(1),
            .door_closed(1)
        );
        
        // Wait for idle state
        `uvm_info(get_type_name(), "Waiting for IDLE state after reset", UVM_MEDIUM)
        wait_for_state(washing_machine_if::IDLE);
        
        `uvm_info(get_type_name(), "Door open error test completed successfully", UVM_MEDIUM)
    endtask
endclass

// Pause-resume sequence - tests pausing and resuming the cycle
class pause_resume_sequence extends washing_machine_sequence_base;
    `uvm_object_utils(pause_resume_sequence)
    
    function new(string name = "pause_resume_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        washing_machine_transaction tx;
        
        // Start a normal wash cycle
        `uvm_info(get_type_name(), "Starting wash cycle for pause-resume test", UVM_MEDIUM)
        tx = send_transaction(
            .start_button(1),
            .door_closed(1),
            .program_select(3'b001) // Normal program
        );
        
        // Wait for washing state
        `uvm_info(get_type_name(), "Waiting for WASHING state", UVM_MEDIUM)
        wait_for_state(washing_machine_if::WASHING);
        
        // Let washing run for a bit
        repeat(2) begin
            tx = send_transaction(.door_closed(1));
            #2000;
        end
        
        // Pause the cycle
        `uvm_info(get_type_name(), "Pausing the wash cycle", UVM_MEDIUM)
        tx = send_transaction(
            .pause_button(1),
            .door_closed(1),
            .transaction_type(washing_machine_transaction::PAUSE_RESUME)
        );
        
        // Wait for paused state
        `uvm_info(get_type_name(), "Waiting for PAUSED state", UVM_MEDIUM)
        wait_for_state(washing_machine_if::PAUSED);
        
        // Wait a bit while paused
        #5000;
        
        // Resume the cycle
        `uvm_info(get_type_name(), "Resuming the wash cycle", UVM_MEDIUM)
        tx = send_transaction(
            .pause_button(1), // Toggle pause button again to resume
            .door_closed(1),
            .transaction_type(washing_machine_transaction::PAUSE_RESUME)
        );
        
        // Wait for washing state again
        `uvm_info(get_type_name(), "Waiting for WASHING state after resume", UVM_MEDIUM)
        wait_for_state(washing_machine_if::WASHING);
        
        `uvm_info(get_type_name(), "Pause-resume test completed successfully", UVM_MEDIUM)
    endtask
endclass

// Program change sequence - tests different washing programs
class program_change_sequence extends washing_machine_sequence_base;
    `uvm_object_utils(program_change_sequence)
    
    function new(string name = "program_change_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        washing_machine_transaction tx;
        bit [2:0] programs[] = {3'b000, 3'b001, 3'b010, 3'b011, 3'b100}; // All available programs
        string program_names[] = {"Quick", "Normal", "Heavy", "Delicate", "Custom"};
        
        foreach (programs[i]) begin
            // Start a wash cycle with the current program
            `uvm_info(get_type_name(), $sformatf("Testing %s program", program_names[i]), UVM_MEDIUM)
            tx = send_transaction(
                .start_button(1),
                .door_closed(1),
                .program_select(programs[i]),
                .transaction_type(washing_machine_transaction::PROGRAM_CHANGE)
            );
            
            // Wait for filling state
            wait_for_state(washing_machine_if::FILLING);
            
            // Simulate water level rising to target
            repeat(10) begin
                tx = send_transaction(
                    .door_closed(1),
                    .program_select(programs[i]),
                    .water_level(tx.water_level + 8'd6),
                    .transaction_type(washing_machine_transaction::PROGRAM_CHANGE)
                );
                #500;
            end
            
            // Wait for heating state
            wait_for_state(washing_machine_if::HEATING);
            
            // Simulate temperature rising to target
            repeat(8) begin
                tx = send_transaction(
                    .door_closed(1),
                    .program_select(programs[i]),
                    .temperature(tx.temperature + 8'd5),
                    .transaction_type(washing_machine_transaction::PROGRAM_CHANGE)
                );
                #500;
            end
            
            // Wait for washing state
            wait_for_state(washing_machine_if::WASHING);
            
            // Let it run for a bit then reset for next program
            #2000;
            
            // Reset to IDLE for next program test
            tx = send_transaction(
                .start_button(0),
                .door_closed(0) // Open door to force stop
            );
            
            // Wait for error state
            wait_for_state(washing_machine_if::ERROR_STATE);
            
            // Reset
            tx = send_transaction(
                .start_button(1),
                .door_closed(1)
            );
            
            // Wait for idle state
            wait_for_state(washing_machine_if::IDLE);
            
            `uvm_info(get_type_name(), $sformatf("%s program test completed", program_names[i]), UVM_MEDIUM)
        end
        
        `uvm_info(get_type_name(), "Program change tests completed successfully", UVM_MEDIUM)
    endtask
endclass

// Sensor error sequence - tests behavior with erratic sensor readings
class sensor_error_sequence extends washing_machine_sequence_base;
    `uvm_object_utils(sensor_error_sequence)
    
    function new(string name = "sensor_error_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        washing_machine_transaction tx;
        
        // Test with erratic water level sensor
        `uvm_info(get_type_name(), "Testing with erratic water level sensor", UVM_MEDIUM)
        tx = send_transaction(
            .start_button(1),
            .door_closed(1),
            .program_select(3'b001), // Normal program
            .transaction_type(washing_machine_transaction::WATER_LEVEL_SENSOR_ERROR)
        );
        
        // Wait for filling state
        wait_for_state(washing_machine_if::FILLING);
        
        // Send erratic water level readings
        repeat(20) begin
            tx = send_transaction(
                .door_closed(1),
                .water_level($urandom_range(0, 100)), // Random water level
                .transaction_type(washing_machine_transaction::WATER_LEVEL_SENSOR_ERROR)
            );
            #500;
        end
        
        // Eventually stabilize at target level
        tx = send_transaction(
            .door_closed(1),
            .water_level(8'd50), // Target level for normal program
            .transaction_type(washing_machine_transaction::WATER_LEVEL_SENSOR_ERROR)
        );
        
        // Wait for heating state
        wait_for_state(washing_machine_if::HEATING);
        
        // Test with erratic temperature sensor
        `uvm_info(get_type_name(), "Testing with erratic temperature sensor", UVM_MEDIUM)
        
        // Send erratic temperature readings
        repeat(20) begin
            tx = send_transaction(
                .door_closed(1),
                .water_level(8'd50),
                .temperature($urandom_range(20, 80)), // Random temperature
                .transaction_type(washing_machine_transaction::TEMPERATURE_SENSOR_ERROR)
            );
            #500;
        end
        
        // Eventually stabilize at target temperature
        tx = send_transaction(
            .door_closed(1),
            .water_level(8'd50),
            .temperature(8'd40), // Target temperature for normal program
            .transaction_type(washing_machine_transaction::TEMPERATURE_SENSOR_ERROR)
        );
        
        // Wait for washing state
        wait_for_state(washing_machine_if::WASHING);
        
        `uvm_info(get_type_name(), "Sensor error tests completed", UVM_MEDIUM)
    endtask
endclass 