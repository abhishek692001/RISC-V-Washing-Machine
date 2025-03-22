interface washing_machine_if(input bit clk, input bit rst_n);
    // Control inputs
    logic start_button;
    logic pause_button;
    logic door_closed;
    logic [2:0] program_select;
    
    // Sensor inputs
    logic [7:0] water_level;
    logic [7:0] temperature;
    logic [7:0] load_weight;
    
    // Control outputs
    logic water_valve;
    logic drain_valve;
    logic [1:0] motor_speed;
    logic [1:0] motor_direction;
    logic heater;
    logic detergent_dispenser;
    logic softener_dispenser;
    
    // Status outputs
    logic [3:0] current_state;
    logic [7:0] remaining_time;
    logic cycle_complete;
    logic error;
    
    // Clocking block for driver
    clocking driver_cb @(posedge clk);
        output start_button;
        output pause_button;
        output door_closed;
        output program_select;
        output water_level;
        output temperature;
        output load_weight;
        
        input water_valve;
        input drain_valve;
        input motor_speed;
        input motor_direction;
        input heater;
        input detergent_dispenser;
        input softener_dispenser;
        input current_state;
        input remaining_time;
        input cycle_complete;
        input error;
    endclocking
    
    // Clocking block for monitor
    clocking monitor_cb @(posedge clk);
        input start_button;
        input pause_button;
        input door_closed;
        input program_select;
        input water_level;
        input temperature;
        input load_weight;
        
        input water_valve;
        input drain_valve;
        input motor_speed;
        input motor_direction;
        input heater;
        input detergent_dispenser;
        input softener_dispenser;
        input current_state;
        input remaining_time;
        input cycle_complete;
        input error;
    endclocking
    
    // Modports
    modport driver(clocking driver_cb, input clk, rst_n);
    modport monitor(clocking monitor_cb, input clk, rst_n);
    
    // State definitions for easier reference
    parameter IDLE          = 4'b0000;
    parameter FILLING       = 4'b0001;
    parameter HEATING       = 4'b0010;
    parameter WASHING       = 4'b0011;
    parameter RINSING       = 4'b0100;
    parameter SPINNING      = 4'b0101;
    parameter DRAINING      = 4'b0110;
    parameter COMPLETE      = 4'b0111;
    parameter ERROR_STATE   = 4'b1000;
    parameter PAUSED        = 4'b1001;
    
    // Helper tasks for common operations
    task automatic wait_for_state(input logic [3:0] state);
        while (current_state !== state) @(posedge clk);
    endtask
    
    task automatic wait_for_cycle_complete();
        while (!cycle_complete) @(posedge clk);
    endtask
    
    task automatic wait_for_n_clocks(input int n);
        repeat (n) @(posedge clk);
    endtask
endinterface