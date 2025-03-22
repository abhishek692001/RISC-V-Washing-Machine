class washing_machine_monitor extends uvm_monitor;
    // UVM factory registration
    `uvm_component_utils(washing_machine_monitor)
    
    // Virtual interface handle
    virtual washing_machine_if vif;
    
    // Analysis port to send transactions to scoreboard
    uvm_analysis_port #(washing_machine_transaction) analysis_port;
    
    // Constructor
    function new(string name = "washing_machine_monitor", uvm_component parent = null);
        super.new(name, parent);
        analysis_port = new("analysis_port", this);
    endfunction
    
    // Build phase - get interface from config DB
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if (!uvm_config_db#(virtual washing_machine_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Virtual interface not found in config DB")
    endfunction
    
    // Run phase - main monitor logic
    virtual task run_phase(uvm_phase phase);
        washing_machine_transaction tx;
        
        // Wait for reset to complete
        @(posedge vif.rst_n);
        
        forever begin
            // Create new transaction
            tx = washing_machine_transaction::type_id::create("tx");
            
            // Wait for a clock edge to sample signals
            @(vif.monitor_cb);
            
            // Sample all interface signals
            sample_signals(tx);
            
            // Send transaction to analysis port
            analysis_port.write(tx);
            
            // Log transaction
            `uvm_info(get_type_name(), $sformatf("Monitored transaction: state=%0d", tx.current_state), UVM_HIGH)
        end
    endtask
    
    // Task to sample interface signals
    virtual task sample_signals(ref washing_machine_transaction tx);
        // Sample control inputs
        tx.start_button = vif.monitor_cb.start_button;
        tx.pause_button = vif.monitor_cb.pause_button;
        tx.door_closed = vif.monitor_cb.door_closed;
        tx.program_select = vif.monitor_cb.program_select;
        
        // Sample sensor inputs
        tx.water_level = vif.monitor_cb.water_level;
        tx.temperature = vif.monitor_cb.temperature;
        tx.load_weight = vif.monitor_cb.load_weight;
        
        // Sample control outputs
        tx.water_valve = vif.monitor_cb.water_valve;
        tx.drain_valve = vif.monitor_cb.drain_valve;
        tx.motor_speed = vif.monitor_cb.motor_speed;
        tx.motor_direction = vif.monitor_cb.motor_direction;
        tx.heater = vif.monitor_cb.heater;
        tx.detergent_dispenser = vif.monitor_cb.detergent_dispenser;
        tx.softener_dispenser = vif.monitor_cb.softener_dispenser;
        
        // Sample status outputs
        tx.current_state = vif.monitor_cb.current_state;
        tx.remaining_time = vif.monitor_cb.remaining_time;
        tx.cycle_complete = vif.monitor_cb.cycle_complete;
        tx.error = vif.monitor_cb.error;
        
        // Determine transaction type based on signals
        if (!tx.door_closed && tx.current_state != washing_machine_if::IDLE && tx.current_state != washing_machine_if::COMPLETE)
            tx.transaction_type = washing_machine_transaction::DOOR_OPEN_ERROR;
        else if (tx.pause_button)
            tx.transaction_type = washing_machine_transaction::PAUSE_RESUME;
        else
            tx.transaction_type = washing_machine_transaction::NORMAL_OPERATION;
    endtask
endclass 