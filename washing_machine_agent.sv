class washing_machine_agent extends uvm_agent;
    // UVM factory registration
    `uvm_component_utils(washing_machine_agent)
    
    // Agent components
    washing_machine_driver driver;
    washing_machine_monitor monitor;
    uvm_sequencer #(washing_machine_transaction) sequencer;
    
    // Configuration
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    
    // Constructor
    function new(string name = "washing_machine_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase - create agent components
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Always create the monitor
        monitor = washing_machine_monitor::type_id::create("monitor", this);
        
        // Create sequencer and driver only if active
        if (is_active == UVM_ACTIVE) begin
            sequencer = uvm_sequencer#(washing_machine_transaction)::type_id::create("sequencer", this);
            driver = washing_machine_driver::type_id::create("driver", this);
        end
    endfunction
    
    // Connect phase - connect components
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect sequencer to driver if active
        if (is_active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction
endclass 