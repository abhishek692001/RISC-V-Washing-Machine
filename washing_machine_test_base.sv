class washing_machine_test_base extends uvm_test;
    // UVM factory registration
    `uvm_component_utils(washing_machine_test_base)
    
    // Environment
    washing_machine_env env;
    
    // Virtual interface
    virtual washing_machine_if vif;
    
    // Constructor
    function new(string name = "washing_machine_test_base", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase - create test components
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get virtual interface from config DB
        if (!uvm_config_db#(virtual washing_machine_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Virtual interface not found in config DB")
        
        // Create environment
        env = washing_machine_env::type_id::create("env", this);
        
        // Pass virtual interface to environment
        uvm_config_db#(virtual washing_machine_if)::set(this, "env", "vif", vif);
    endfunction
    
    // End of elaboration phase - print topology
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        
        // Print the test topology
        uvm_top.print_topology();
    endfunction
    
    // Run phase - start test
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        // Raise objection to keep test running
        phase.raise_objection(this);
        
        // Apply reset
        apply_reset();
        
        // Wait for reset to complete
        #100;
        
        // Run test-specific sequence (to be implemented by derived classes)
        run_test_sequence(phase);
        
        // Drop objection to end test
        phase.drop_objection(this);
    endtask
    
    // Apply reset to DUT
    virtual task apply_reset();
        vif.rst_n = 0;
        repeat(5) @(posedge vif.clk);
        vif.rst_n = 1;
    endtask
    
    // Run test-specific sequence (to be implemented by derived classes)
    virtual task run_test_sequence(uvm_phase phase);
        // Default implementation - do nothing
        // Derived classes should override this method
    endtask
endclass 