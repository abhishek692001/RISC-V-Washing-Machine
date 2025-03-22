// Normal operation test - runs a complete washing cycle
class normal_operation_test extends washing_machine_test_base;
    // UVM factory registration
    `uvm_component_utils(normal_operation_test)
    
    // Constructor
    function new(string name = "normal_operation_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Run test sequence
    virtual task run_test_sequence(uvm_phase phase);
        normal_operation_sequence seq;
        seq = normal_operation_sequence::type_id::create("seq");
        
        `uvm_info(get_type_name(), "Starting normal operation test", UVM_LOW)
        
        // Start sequence on the sequencer
        seq.start(env.agent.sequencer);
        
        // Wait for sequence to complete
        #10000; // Add some margin
        
        `uvm_info(get_type_name(), "Normal operation test completed", UVM_LOW)
    endtask
endclass

// Door open error test - tests the error handling when door is opened during operation
class door_open_error_test extends washing_machine_test_base;
    // UVM factory registration
    `uvm_component_utils(door_open_error_test)
    
    // Constructor
    function new(string name = "door_open_error_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Run test sequence
    virtual task run_test_sequence(uvm_phase phase);
        door_open_error_sequence seq;
        seq = door_open_error_sequence::type_id::create("seq");
        
        `uvm_info(get_type_name(), "Starting door open error test", UVM_LOW)
        
        // Start sequence on the sequencer
        seq.start(env.agent.sequencer);
        
        // Wait for sequence to complete
        #5000; // Add some margin
        
        `uvm_info(get_type_name(), "Door open error test completed", UVM_LOW)
    endtask
endclass

// Pause-resume test - tests pausing and resuming the cycle
class pause_resume_test extends washing_machine_test_base;
    // UVM factory registration
    `uvm_component_utils(pause_resume_test)
    
    // Constructor
    function new(string name = "pause_resume_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Run test sequence
    virtual task run_test_sequence(uvm_phase phase);
        pause_resume_sequence seq;
        seq = pause_resume_sequence::type_id::create("seq");
        
        `uvm_info(get_type_name(), "Starting pause-resume test", UVM_LOW)
        
        // Start sequence on the sequencer
        seq.start(env.agent.sequencer);
        
        // Wait for sequence to complete
        #5000; // Add some margin
        
        `uvm_info(get_type_name(), "Pause-resume test completed", UVM_LOW)
    endtask
endclass

// Program change test - tests different washing programs
class program_change_test extends washing_machine_test_base;
    // UVM factory registration
    `uvm_component_utils(program_change_test)
    
    // Constructor
    function new(string name = "program_change_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Run test sequence
    virtual task run_test_sequence(uvm_phase phase);
        program_change_sequence seq;
        seq = program_change_sequence::type_id::create("seq");
        
        `uvm_info(get_type_name(), "Starting program change test", UVM_LOW)
        
        // Start sequence on the sequencer
        seq.start(env.agent.sequencer);
        
        // Wait for sequence to complete
        #20000; // Add some margin
        
        `uvm_info(get_type_name(), "Program change test completed", UVM_LOW)
    endtask
endclass

// Sensor error test - tests behavior with erratic sensor readings
class sensor_error_test extends washing_machine_test_base;
    // UVM factory registration
    `uvm_component_utils(sensor_error_test)
    
    // Constructor
    function new(string name = "sensor_error_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Run test sequence
    virtual task run_test_sequence(uvm_phase phase);
        sensor_error_sequence seq;
        seq = sensor_error_sequence::type_id::create("seq");
        
        `uvm_info(get_type_name(), "Starting sensor error test", UVM_LOW)
        
        // Start sequence on the sequencer
        seq.start(env.agent.sequencer);
        
        // Wait for sequence to complete
        #5000; // Add some margin
        
        `uvm_info(get_type_name(), "Sensor error test completed", UVM_LOW)
    endtask
endclass

// Regression test - runs all test sequences in succession
class regression_test extends washing_machine_test_base;
    // UVM factory registration
    `uvm_component_utils(regression_test)
    
    // Constructor
    function new(string name = "regression_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Run test sequence
    virtual task run_test_sequence(uvm_phase phase);
        normal_operation_sequence normal_seq;
        door_open_error_sequence door_seq;
        pause_resume_sequence pause_seq;
        program_change_sequence program_seq;
        sensor_error_sequence sensor_seq;
        
        // Create sequences
        normal_seq = normal_operation_sequence::type_id::create("normal_seq");
        door_seq = door_open_error_sequence::type_id::create("door_seq");
        pause_seq = pause_resume_sequence::type_id::create("pause_seq");
        program_seq = program_change_sequence::type_id::create("program_seq");
        sensor_seq = sensor_error_sequence::type_id::create("sensor_seq");
        
        `uvm_info(get_type_name(), "Starting regression test", UVM_LOW)
        
        // Run normal operation test
        `uvm_info(get_type_name(), "Running normal operation sequence", UVM_LOW)
        normal_seq.start(env.agent.sequencer);
        #10000;
        
        // Run door open error test
        `uvm_info(get_type_name(), "Running door open error sequence", UVM_LOW)
        door_seq.start(env.agent.sequencer);
        #5000;
        
        // Run pause-resume test
        `uvm_info(get_type_name(), "Running pause-resume sequence", UVM_LOW)
        pause_seq.start(env.agent.sequencer);
        #5000;
        
        // Run program change test
        `uvm_info(get_type_name(), "Running program change sequence", UVM_LOW)
        program_seq.start(env.agent.sequencer);
        #20000;
        
        // Run sensor error test
        `uvm_info(get_type_name(), "Running sensor error sequence", UVM_LOW)
        sensor_seq.start(env.agent.sequencer);
        #5000;
        
        `uvm_info(get_type_name(), "Regression test completed", UVM_LOW)
    endtask
endclass 