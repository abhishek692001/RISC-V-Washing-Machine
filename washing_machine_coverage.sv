class washing_machine_coverage extends uvm_subscriber #(washing_machine_transaction);
    // UVM factory registration
    `uvm_component_utils(washing_machine_coverage)
    
    // Transaction handle for coverage sampling
    washing_machine_transaction tx;
    
    // Coverage groups
    
    // State coverage - ensure all states are visited
    covergroup state_cg;
        state_cp: coverpoint tx.current_state {
            bins idle = {washing_machine_if::IDLE};
            bins filling = {washing_machine_if::FILLING};
            bins heating = {washing_machine_if::HEATING};
            bins washing = {washing_machine_if::WASHING};
            bins rinsing = {washing_machine_if::RINSING};
            bins spinning = {washing_machine_if::SPINNING};
            bins draining = {washing_machine_if::DRAINING};
            bins complete = {washing_machine_if::COMPLETE};
            bins error_state = {washing_machine_if::ERROR_STATE};
            bins paused = {washing_machine_if::PAUSED};
        }
    endgroup
    
    // State transition coverage - ensure all valid state transitions are covered
    covergroup state_transition_cg;
        prev_state_cp: coverpoint tx.prev_state {
            bins states[] = {[0:9]};
            illegal_bins illegal = {10,11,12,13,14,15};
        }
        
        curr_state_cp: coverpoint tx.current_state {
            bins states[] = {[0:9]};
            illegal_bins illegal = {10,11,12,13,14,15};
        }
        
        state_transition_cross: cross prev_state_cp, curr_state_cp {
            // Valid transitions from IDLE
            bins idle_to_filling = binsof(prev_state_cp) intersect {washing_machine_if::IDLE} && 
                                  binsof(curr_state_cp) intersect {washing_machine_if::FILLING};
            bins idle_to_error = binsof(prev_state_cp) intersect {washing_machine_if::IDLE} && 
                                binsof(curr_state_cp) intersect {washing_machine_if::ERROR_STATE};
            
            // Valid transitions from FILLING
            bins filling_to_heating = binsof(prev_state_cp) intersect {washing_machine_if::FILLING} && 
                                     binsof(curr_state_cp) intersect {washing_machine_if::HEATING};
            bins filling_to_rinsing = binsof(prev_state_cp) intersect {washing_machine_if::FILLING} && 
                                     binsof(curr_state_cp) intersect {washing_machine_if::RINSING};
            bins filling_to_error = binsof(prev_state_cp) intersect {washing_machine_if::FILLING} && 
                                   binsof(curr_state_cp) intersect {washing_machine_if::ERROR_STATE};
            bins filling_to_paused = binsof(prev_state_cp) intersect {washing_machine_if::FILLING} && 
                                    binsof(curr_state_cp) intersect {washing_machine_if::PAUSED};
            
            // Valid transitions from HEATING
            bins heating_to_washing = binsof(prev_state_cp) intersect {washing_machine_if::HEATING} && 
                                     binsof(curr_state_cp) intersect {washing_machine_if::WASHING};
            bins heating_to_error = binsof(prev_state_cp) intersect {washing_machine_if::HEATING} && 
                                   binsof(curr_state_cp) intersect {washing_machine_if::ERROR_STATE};
            bins heating_to_paused = binsof(prev_state_cp) intersect {washing_machine_if::HEATING} && 
                                    binsof(curr_state_cp) intersect {washing_machine_if::PAUSED};
            
            // Valid transitions from WASHING
            bins washing_to_draining = binsof(prev_state_cp) intersect {washing_machine_if::WASHING} && 
                                      binsof(curr_state_cp) intersect {washing_machine_if::DRAINING};
            bins washing_to_error = binsof(prev_state_cp) intersect {washing_machine_if::WASHING} && 
                                   binsof(curr_state_cp) intersect {washing_machine_if::ERROR_STATE};
            bins washing_to_paused = binsof(prev_state_cp) intersect {washing_machine_if::WASHING} && 
                                    binsof(curr_state_cp) intersect {washing_machine_if::PAUSED};
            
            // Valid transitions from RINSING
            bins rinsing_to_draining = binsof(prev_state_cp) intersect {washing_machine_if::RINSING} && 
                                      binsof(curr_state_cp) intersect {washing_machine_if::DRAINING};
            bins rinsing_to_error = binsof(prev_state_cp) intersect {washing_machine_if::RINSING} && 
                                   binsof(curr_state_cp) intersect {washing_machine_if::ERROR_STATE};
            bins rinsing_to_paused = binsof(prev_state_cp) intersect {washing_machine_if::RINSING} && 
                                    binsof(curr_state_cp) intersect {washing_machine_if::PAUSED};
            
            // Valid transitions from DRAINING
            bins draining_to_filling = binsof(prev_state_cp) intersect {washing_machine_if::DRAINING} && 
                                      binsof(curr_state_cp) intersect {washing_machine_if::FILLING};
            bins draining_to_spinning = binsof(prev_state_cp) intersect {washing_machine_if::DRAINING} && 
                                       binsof(curr_state_cp) intersect {washing_machine_if::SPINNING};
            bins draining_to_error = binsof(prev_state_cp) intersect {washing_machine_if::DRAINING} && 
                                    binsof(curr_state_cp) intersect {washing_machine_if::ERROR_STATE};
            bins draining_to_paused = binsof(prev_state_cp) intersect {washing_machine_if::DRAINING} && 
                                     binsof(curr_state_cp) intersect {washing_machine_if::PAUSED};
            
            // Valid transitions from SPINNING
            bins spinning_to_complete = binsof(prev_state_cp) intersect {washing_machine_if::SPINNING} && 
                                       binsof(curr_state_cp) intersect {washing_machine_if::COMPLETE};
            bins spinning_to_error = binsof(prev_state_cp) intersect {washing_machine_if::SPINNING} && 
                                    binsof(curr_state_cp) intersect {washing_machine_if::ERROR_STATE};
            bins spinning_to_paused = binsof(prev_state_cp) intersect {washing_machine_if::SPINNING} && 
                                     binsof(curr_state_cp) intersect {washing_machine_if::PAUSED};
            
            // Valid transitions from COMPLETE
            bins complete_to_idle = binsof(prev_state_cp) intersect {washing_machine_if::COMPLETE} && 
                                   binsof(curr_state_cp) intersect {washing_machine_if::IDLE};
            
            // Valid transitions from ERROR_STATE
            bins error_to_idle = binsof(prev_state_cp) intersect {washing_machine_if::ERROR_STATE} && 
                                binsof(curr_state_cp) intersect {washing_machine_if::IDLE};
            
            // Valid transitions from PAUSED
            bins paused_to_filling = binsof(prev_state_cp) intersect {washing_machine_if::PAUSED} && 
                                    binsof(curr_state_cp) intersect {washing_machine_if::FILLING};
            bins paused_to_heating = binsof(prev_state_cp) intersect {washing_machine_if::PAUSED} && 
                                    binsof(curr_state_cp) intersect {washing_machine_if::HEATING};
            bins paused_to_washing = binsof(prev_state_cp) intersect {washing_machine_if::PAUSED} && 
                                    binsof(curr_state_cp) intersect {washing_machine_if::WASHING};
            bins paused_to_rinsing = binsof(prev_state_cp) intersect {washing_machine_if::PAUSED} && 
                                    binsof(curr_state_cp) intersect {washing_machine_if::RINSING};
            bins paused_to_spinning = binsof(prev_state_cp) intersect {washing_machine_if::PAUSED} && 
                                     binsof(curr_state_cp) intersect {washing_machine_if::SPINNING};
            bins paused_to_draining = binsof(prev_state_cp) intersect {washing_machine_if::PAUSED} && 
                                     binsof(curr_state_cp) intersect {washing_machine_if::DRAINING};
            
            // Ignore self-transitions (staying in the same state)
            ignore_bins same_state = binsof(prev_state_cp) intersect {binsof(curr_state_cp)};
            
            // Ignore illegal transitions
            ignore_bins illegal_transitions = 
                // Can't go from IDLE to states other than FILLING or ERROR
                (binsof(prev_state_cp) intersect {washing_machine_if::IDLE} && 
                 binsof(curr_state_cp) intersect {washing_machine_if::HEATING, washing_machine_if::WASHING, 
                                                 washing_machine_if::RINSING, washing_machine_if::SPINNING, 
                                                 washing_machine_if::DRAINING, washing_machine_if::COMPLETE, 
                                                 washing_machine_if::PAUSED}) ||
                // Can't go from COMPLETE to states other than IDLE
                (binsof(prev_state_cp) intersect {washing_machine_if::COMPLETE} && 
                 binsof(curr_state_cp) intersect {washing_machine_if::FILLING, washing_machine_if::HEATING, 
                                                 washing_machine_if::WASHING, washing_machine_if::RINSING, 
                                                 washing_machine_if::SPINNING, washing_machine_if::DRAINING, 
                                                 washing_machine_if::ERROR_STATE, washing_machine_if::PAUSED});
        }
    endgroup
    
    // Program selection coverage - ensure all programs are tested
    covergroup program_cg;
        program_cp: coverpoint tx.program_select {
            bins quick = {3'b000};
            bins normal = {3'b001};
            bins heavy = {3'b010};
            bins delicate = {3'b011};
            bins custom = {3'b100};
            illegal_bins reserved = {3'b101, 3'b110, 3'b111};
        }
    endgroup
    
    // Error condition coverage - ensure all error conditions are tested
    covergroup error_cg;
        error_cp: coverpoint tx.error {
            bins no_error = {0};
            bins error_detected = {1};
        }
        
        door_closed_cp: coverpoint tx.door_closed {
            bins door_open = {0};
            bins door_closed = {1};
        }
        
        state_cp: coverpoint tx.current_state {
            bins error_state = {washing_machine_if::ERROR_STATE};
            bins other_states = {[0:7], 9}; // All states except ERROR_STATE
        }
        
        // Cross coverage to ensure door open errors are detected in all operational states
        door_error_cross: cross door_closed_cp, state_cp, error_cp {
            // Door open during operation should cause error
            bins door_open_during_operation = binsof(door_closed_cp) intersect {0} && 
                                             binsof(state_cp) intersect {washing_machine_if::FILLING, 
                                                                        washing_machine_if::HEATING,
                                                                        washing_machine_if::WASHING,
                                                                        washing_machine_if::RINSING,
                                                                        washing_machine_if::SPINNING,
                                                                        washing_machine_if::DRAINING} &&
                                             binsof(error_cp) intersect {1};
            
            // Door open in IDLE or COMPLETE should not cause error
            bins door_open_when_idle = binsof(door_closed_cp) intersect {0} && 
                                      binsof(state_cp) intersect {washing_machine_if::IDLE, 
                                                                 washing_machine_if::COMPLETE} &&
                                      binsof(error_cp) intersect {0};
        }
    endgroup
    
    // Pause-resume coverage - ensure pause functionality works in all states
    covergroup pause_cg;
        pause_button_cp: coverpoint tx.pause_button {
            bins not_pressed = {0};
            bins pressed = {1};
        }
        
        state_cp: coverpoint tx.current_state {
            bins paused = {washing_machine_if::PAUSED};
            bins operational_states = {washing_machine_if::FILLING, 
                                      washing_machine_if::HEATING,
                                      washing_machine_if::WASHING,
                                      washing_machine_if::RINSING,
                                      washing_machine_if::SPINNING,
                                      washing_machine_if::DRAINING};
            bins non_pausable_states = {washing_machine_if::IDLE, 
                                       washing_machine_if::COMPLETE,
                                       washing_machine_if::ERROR_STATE};
        }
        
        // Cross coverage to ensure pause works in all operational states
        pause_cross: cross pause_button_cp, state_cp {
            // Pressing pause in operational states
            bins pause_during_operation = binsof(pause_button_cp) intersect {1} && 
                                         binsof(state_cp) intersect {washing_machine_if::FILLING, 
                                                                    washing_machine_if::HEATING,
                                                                    washing_machine_if::WASHING,
                                                                    washing_machine_if::RINSING,
                                                                    washing_machine_if::SPINNING,
                                                                    washing_machine_if::DRAINING};
            
            // Pressing pause when already paused (to resume)
            bins resume_from_pause = binsof(pause_button_cp) intersect {1} && 
                                    binsof(state_cp) intersect {washing_machine_if::PAUSED};
        }
    endgroup
    
    // Sensor input coverage - ensure a range of sensor values are tested
    covergroup sensor_cg;
        water_level_cp: coverpoint tx.water_level {
            bins empty = {0};
            bins low = {[1:25]};
            bins medium = {[26:75]};
            bins high = {[76:99]};
            bins full = {100};
        }
        
        temperature_cp: coverpoint tx.temperature {
            bins cold = {[0:20]};
            bins warm = {[21:40]};
            bins hot = {[41:60]};
            bins very_hot = {[61:100]};
        }
        
        load_weight_cp: coverpoint tx.load_weight {
            bins empty = {0};
            bins light = {[1:25]};
            bins medium = {[26:75]};
            bins heavy = {[76:100]};
        }
    endgroup
    
    // Output coverage - ensure all output combinations are tested
    covergroup output_cg;
        water_valve_cp: coverpoint tx.water_valve {
            bins off = {0};
            bins on = {1};
        }
        
        drain_valve_cp: coverpoint tx.drain_valve {
            bins off = {0};
            bins on = {1};
        }
        
        motor_speed_cp: coverpoint tx.motor_speed {
            bins off = {2'b00};
            bins low = {2'b01};
            bins medium = {2'b10};
            bins high = {2'b11};
        }
        
        motor_direction_cp: coverpoint tx.motor_direction {
            bins off = {2'b00};
            bins clockwise = {2'b01};
            bins counter_clockwise = {2'b10};
            bins alternating = {2'b11};
        }
        
        heater_cp: coverpoint tx.heater {
            bins off = {0};
            bins on = {1};
        }
        
        detergent_dispenser_cp: coverpoint tx.detergent_dispenser {
            bins off = {0};
            bins on = {1};
        }
        
        softener_dispenser_cp: coverpoint tx.softener_dispenser {
            bins off = {0};
            bins on = {1};
        }
        
        // Cross coverage for key output combinations
        motor_cross: cross motor_speed_cp, motor_direction_cp {
            // Motor should be off when direction is off
            bins motor_off = binsof(motor_speed_cp) intersect {2'b00} && 
                            binsof(motor_direction_cp) intersect {2'b00};
            
            // Motor should have direction when speed is non-zero
            bins motor_running = binsof(motor_speed_cp) intersect {2'b01, 2'b10, 2'b11} && 
                                binsof(motor_direction_cp) intersect {2'b01, 2'b10, 2'b11};
        }
    endgroup
    
    // Complete cycle coverage - ensure full cycles are completed
    covergroup cycle_cg;
        cycle_complete_cp: coverpoint tx.cycle_complete {
            bins not_complete = {0};
            bins complete = {1};
        }
        
        state_cp: coverpoint tx.current_state {
            bins complete_state = {washing_machine_if::COMPLETE};
            bins other_states = {[0:6], 8, 9}; // All states except COMPLETE
        }
        
        // Cross coverage to ensure cycle_complete flag is set in COMPLETE state
        cycle_cross: cross cycle_complete_cp, state_cp {
            bins cycle_completed = binsof(cycle_complete_cp) intersect {1} && 
                                  binsof(state_cp) intersect {washing_machine_if::COMPLETE};
            
            // cycle_complete should be 0 in all other states
            bins cycle_not_completed = binsof(cycle_complete_cp) intersect {0} && 
                                      binsof(state_cp) intersect {washing_machine_if::IDLE,
                                                                 washing_machine_if::FILLING,
                                                                 washing_machine_if::HEATING,
                                                                 washing_machine_if::WASHING,
                                                                 washing_machine_if::RINSING,
                                                                 washing_machine_if::SPINNING,
                                                                 washing_machine_if::DRAINING,
                                                                 washing_machine_if::ERROR_STATE,
                                                                 washing_machine_if::PAUSED};
        }
    endgroup
    
    // Constructor
    function new(string name = "washing_machine_coverage", uvm_component parent = null);
        super.new(name, parent);
        
        // Create coverage groups
        state_cg = new();
        state_transition_cg = new();
        program_cg = new();
        error_cg = new();
        pause_cg = new();
        sensor_cg = new();
        output_cg = new();
        cycle_cg = new();
    endfunction
    
    // Add prev_state field to transaction for state transition coverage
    bit [3:0] prev_state;
    
    // Write method - called when monitor sends a transaction
    virtual function void write(washing_machine_transaction t);
        // Store transaction for coverage sampling
        tx = t;
        
        // Add previous state for transition coverage
        tx.prev_state = prev_state;
        prev_state = tx.current_state;
        
        // Sample coverage
        state_cg.sample();
        state_transition_cg.sample();
        program_cg.sample();
        error_cg.sample();
        pause_cg.sample();
        sensor_cg.sample();
        output_cg.sample();
        cycle_cg.sample();
    endfunction
    
    // Report phase - print coverage statistics
    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Coverage statistics:"), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  State coverage: %.2f%%", state_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  State transition coverage: %.2f%%", state_transition_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Program coverage: %.2f%%", program_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Error condition coverage: %.2f%%", error_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Pause-resume coverage: %.2f%%", pause_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Sensor input coverage: %.2f%%", sensor_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Output coverage: %.2f%%", output_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Cycle completion coverage: %.2f%%", cycle_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Total coverage: %.2f%%", get_coverage()), UVM_LOW)
    endfunction
    
    // Get overall coverage
    virtual function real get_coverage();
        return (state_cg.get_coverage() + 
                state_transition_cg.get_coverage() + 
                program_cg.get_coverage() + 
                error_cg.get_coverage() + 
                pause_cg.get_coverage() + 
                sensor_cg.get_coverage() + 
                output_cg.get_coverage() + 
                cycle_cg.get_coverage()) / 8;
    endfunction
endclass 