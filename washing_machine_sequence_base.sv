class washing_machine_sequence_base extends uvm_sequence #(washing_machine_transaction);
    // UVM factory registration
    `uvm_object_utils(washing_machine_sequence_base)
    
    // Constructor
    function new(string name = "washing_machine_sequence_base");
        super.new(name);
    endfunction
    
    // Helper tasks
    task send_transaction(
        bit start_button = 0,
        bit pause_button = 0,
        bit door_closed = 1,
        bit [2:0] program_select = 3'b001,
        bit [7:0] water_level = 8'd0,
        bit [7:0] temperature = 8'd25,
        bit [7:0] load_weight = 8'd50,
        washing_machine_transaction::transaction_type_t trans_type = washing_machine_transaction::NORMAL_OPERATION
    );
        washing_machine_transaction tx;
        tx = washing_machine_transaction::type_id::create("tx");
        
        start_item(tx);
        
        tx.start_button = start_button;
        tx.pause_button = pause_button;
        tx.door_closed = door_closed;
        tx.program_select = program_select;
        tx.water_level = water_level;
        tx.temperature = temperature;
        tx.load_weight = load_weight;
        tx.transaction_type = trans_type;
        
        finish_item(tx);
        
        // Return the transaction for potential checking
        return tx;
    endtask
    
    // Task to wait for a specific state
    task wait_for_state(bit [3:0] state);
        washing_machine_transaction tx;
        do begin
            get_response(tx);
        end while (tx.current_state != state);
    endtask
    
    // Task to wait for cycle completion
    task wait_for_cycle_complete();
        washing_machine_transaction tx;
        do begin
            get_response(tx);
        end while (!tx.cycle_complete);
    endtask
endclass 