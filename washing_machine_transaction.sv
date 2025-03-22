class washing_machine_transaction extends uvm_sequence_item;
    // Control inputs
    rand bit start_button;
    rand bit pause_button;
    rand bit door_closed;
    rand bit [2:0] program_select;
    
    // Sensor inputs
    rand bit [7:0] water_level;
    rand bit [7:0] temperature;
    rand bit [7:0] load_weight;
    
    // Control outputs
    bit water_valve;
    bit drain_valve;
    bit [1:0] motor_speed;
    bit [1:0] motor_direction;
    bit heater;
    bit detergent_dispenser;
    bit softener_dispenser;
    
    // Status outputs
    bit [3:0] current_state;
    bit [7:0] remaining_time;
    bit cycle_complete;
    bit error;
    
    // Transaction type
    typedef enum {
        NORMAL_OPERATION,
        DOOR_OPEN_ERROR,
        PAUSE_RESUME,
        WATER_LEVEL_SENSOR_ERROR,
        TEMPERATURE_SENSOR_ERROR,
        PROGRAM_CHANGE,
        POWER_CYCLE
    } transaction_type_t;
    
    rand transaction_type_t transaction_type;
    
    // UVM factory registration
    `uvm_object_utils_begin(washing_machine_transaction)
        `uvm_field_int(start_button, UVM_ALL_ON)
        `uvm_field_int(pause_button, UVM_ALL_ON)
        `uvm_field_int(door_closed, UVM_ALL_ON)
        `uvm_field_int(program_select, UVM_ALL_ON)
        `uvm_field_int(water_level, UVM_ALL_ON)
        `uvm_field_int(temperature, UVM_ALL_ON)
        `uvm_field_int(load_weight, UVM_ALL_ON)
        `uvm_field_int(water_valve, UVM_ALL_ON)
        `uvm_field_int(drain_valve, UVM_ALL_ON)
        `uvm_field_int(motor_speed, UVM_ALL_ON)
        `uvm_field_int(motor_direction, UVM_ALL_ON)
        `uvm_field_int(heater, UVM_ALL_ON)
        `uvm_field_int(detergent_dispenser, UVM_ALL_ON)
        `uvm_field_int(softener_dispenser, UVM_ALL_ON)
        `uvm_field_int(current_state, UVM_ALL_ON)
        `uvm_field_int(remaining_time, UVM_ALL_ON)
        `uvm_field_int(cycle_complete, UVM_ALL_ON)
        `uvm_field_int(error, UVM_ALL_ON)
        `uvm_field_enum(transaction_type_t, transaction_type, UVM_ALL_ON)
    `uvm_object_utils_end
    
    // Constraints
    constraint valid_program_select {
        program_select inside {[0:4]};
    }
    
    constraint valid_water_level {
        water_level inside {[0:100]};
    }
    
    constraint valid_temperature {
        temperature inside {[0:100]};
    }
    
    constraint valid_load_weight {
        load_weight inside {[0:100]};
    }
    
    constraint door_closed_for_normal_operation {
        (transaction_type == NORMAL_OPERATION) -> door_closed == 1;
    }
    
    constraint door_open_for_error_test {
        (transaction_type == DOOR_OPEN_ERROR) -> door_closed == 0;
    }
    
    constraint pause_for_pause_test {
        (transaction_type == PAUSE_RESUME) -> pause_button == 1;
    }
    
    // Constructor
    function new(string name = "washing_machine_transaction");
        super.new(name);
    endfunction
    
    // Custom print method
    virtual function string convert2string();
        string s;
        s = super.convert2string();
        s = {s, $sformatf("\n Transaction Type: %s", transaction_type.name())};
        s = {s, $sformatf("\n Control Inputs:")};
        s = {s, $sformatf("\n   start_button: %0d", start_button)};
        s = {s, $sformatf("\n   pause_button: %0d", pause_button)};
        s = {s, $sformatf("\n   door_closed: %0d", door_closed)};
        s = {s, $sformatf("\n   program_select: %0d", program_select)};
        s = {s, $sformatf("\n Sensor Inputs:")};
        s = {s, $sformatf("\n   water_level: %0d", water_level)};
        s = {s, $sformatf("\n   temperature: %0d", temperature)};
        s = {s, $sformatf("\n   load_weight: %0d", load_weight)};
        s = {s, $sformatf("\n Control Outputs:")};
        s = {s, $sformatf("\n   water_valve: %0d", water_valve)};
        s = {s, $sformatf("\n   drain_valve: %0d", drain_valve)};
        s = {s, $sformatf("\n   motor_speed: %0d", motor_speed)};
        s = {s, $sformatf("\n   motor_direction: %0d", motor_direction)};
        s = {s, $sformatf("\n   heater: %0d", heater)};
        s = {s, $sformatf("\n   detergent_dispenser: %0d", detergent_dispenser)};
        s = {s, $sformatf("\n   softener_dispenser: %0d", softener_dispenser)};
        s = {s, $sformatf("\n Status Outputs:")};
        s = {s, $sformatf("\n   current_state: %0d", current_state)};
        s = {s, $sformatf("\n   remaining_time: %0d", remaining_time)};
        s = {s, $sformatf("\n   cycle_complete: %0d", cycle_complete)};
        s = {s, $sformatf("\n   error: %0d", error)};
        return s;
    endfunction
    
    // Compare method
    virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        washing_machine_transaction rhs_cast;
        if (!$cast(rhs_cast, rhs)) return 0;
        
        return (super.do_compare(rhs, comparer) &&
                start_button == rhs_cast.start_button &&
                pause_button == rhs_cast.pause_button &&
                door_closed == rhs_cast.door_closed &&
                program_select == rhs_cast.program_select &&
                water_level == rhs_cast.water_level &&
                temperature == rhs_cast.temperature &&
                load_weight == rhs_cast.load_weight &&
                water_valve == rhs_cast.water_valve &&
                drain_valve == rhs_cast.drain_valve &&
                motor_speed == rhs_cast.motor_speed &&
                motor_direction == rhs_cast.motor_direction &&
                heater == rhs_cast.heater &&
                detergent_dispenser == rhs_cast.detergent_dispenser &&
                softener_dispenser == rhs_cast.softener_dispenser &&
                current_state == rhs_cast.current_state &&
                remaining_time == rhs_cast.remaining_time &&
                cycle_complete == rhs_cast.cycle_complete &&
                error == rhs_cast.error);
    endfunction
endclass 