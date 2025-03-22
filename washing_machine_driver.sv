class washing_machine_driver extends uvm_driver #(washing_machine_transaction);
    // UVM factory registration
    `uvm_component_utils(washing_machine_driver)
    
    // Virtual interface handle
    virtual washing_machine_if vif;
    
    // Constructor
    function new(string name = "washing_machine_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase - get interface from config DB
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if (!uvm_config_db#(virtual washing_machine_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Virtual interface not found in config DB")
    endfunction
    
    // Run phase - main driver logic
    virtual task run_phase(uvm_phase phase);
        washing_machine_transaction tx;
        
        // Initialize interface signals
        vif.driver_cb.start_button <= 0;
        vif.driver_cb.pause_button <= 0;
        vif.driver_cb.door_closed <= 1;
        vif.driver_cb.program_select <= 3'b001; // Default to normal program
        vif.driver_cb.water_level <= 0;
        vif.driver_cb.temperature <= 25; // Room temperature
        vif.driver_cb.load_weight <= 0;
        
        // Wait for reset to complete
        @(posedge vif.rst_n);
        
        forever begin
            // Get next transaction from sequencer
            seq_item_port.get_next_item(tx);
            
            // Drive transaction to DUT
            drive_transaction(tx);
            
            // Sample DUT outputs
            sample_dut_outputs(tx);
            
            // Send item done to sequencer
            seq_item_port.item_done();
            
            // Send response back to sequence
            seq_item_port.put_response(tx);
        end
    endtask
    
    // Task to drive transaction to DUT
    virtual task drive_transaction(washing_machine_transaction tx);
        // Drive control inputs
        vif.driver_cb.start_button <= tx.start_button;
        vif.driver_cb.pause_button <= tx.pause_button;
        vif.driver_cb.door_closed <= tx.door_closed;
        vif.driver_cb.program_select <= tx.program_select;
        
        // Drive sensor inputs
        vif.driver_cb.water_level <= tx.water_level;
        vif.driver_cb.temperature <= tx.temperature;
        vif.driver_cb.load_weight <= tx.load_weight;
        
        // Wait for one clock cycle for DUT to process inputs
        @(vif.driver_cb);
    endtask
    
    // Task to sample DUT outputs
    virtual task sample_dut_outputs(ref washing_machine_transaction tx);
        // Sample control outputs
        tx.water_valve = vif.driver_cb.water_valve;
        tx.drain_valve = vif.driver_cb.drain_valve;
        tx.motor_speed = vif.driver_cb.motor_speed;
        tx.motor_direction = vif.driver_cb.motor_direction;
        tx.heater = vif.driver_cb.heater;
        tx.detergent_dispenser = vif.driver_cb.detergent_dispenser;
        tx.softener_dispenser = vif.driver_cb.softener_dispenser;
        
        // Sample status outputs
        tx.current_state = vif.driver_cb.current_state;
        tx.remaining_time = vif.driver_cb.remaining_time;
        tx.cycle_complete = vif.driver_cb.cycle_complete;
        tx.error = vif.driver_cb.error;
    endtask
endclass 