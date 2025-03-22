class washing_machine_env extends uvm_env;
    // UVM factory registration
    `uvm_component_utils(washing_machine_env)
    
    // Environment components
    washing_machine_agent agent;
    washing_machine_scoreboard scoreboard;
    washing_machine_coverage coverage;
    
    // Virtual interface
    virtual washing_machine_if vif;
    
    // Constructor
    function new(string name = "washing_machine_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase - create environment components
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get virtual interface from config DB
        if (!uvm_config_db#(virtual washing_machine_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Virtual interface not found in config DB")
        
        // Create components
        agent = washing_machine_agent::type_id::create("agent", this);
        scoreboard = washing_machine_scoreboard::type_id::create("scoreboard", this);
        coverage = washing_machine_coverage::type_id::create("coverage", this);
        
        // Pass virtual interface to agent components
        uvm_config_db#(virtual washing_machine_if)::set(this, "agent.*", "vif", vif);
    endfunction
    
    // Connect phase - connect components
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect monitor to scoreboard and coverage
        agent.monitor.analysis_port.connect(scoreboard.analysis_export);
        agent.monitor.analysis_port.connect(coverage.analysis_export);
    endfunction
    
    // Run phase - start environment
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        // Additional environment-level run tasks can be added here
    endtask
endclass 