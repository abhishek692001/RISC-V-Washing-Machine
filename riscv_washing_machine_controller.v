module riscv_washing_machine_controller (
    input wire clk,
    input wire rst_n,
    
    // Control inputs
    input wire start_button,
    input wire pause_button,
    input wire door_closed,
    input wire [2:0] program_select,  // 000: Quick, 001: Normal, 010: Heavy, 011: Delicate, 100: Custom
    
    // Sensor inputs
    input wire [7:0] water_level,
    input wire [7:0] temperature,
    input wire [7:0] load_weight,
    
    // Control outputs
    output reg water_valve,
    output reg drain_valve,
    output reg [1:0] motor_speed,  // 00: Off, 01: Low, 10: Medium, 11: High
    output reg [1:0] motor_direction,  // 00: Off, 01: Clockwise, 10: Counter-clockwise, 11: Alternating
    output reg heater,
    output reg detergent_dispenser,
    output reg softener_dispenser,
    
    // Status outputs
    output reg [3:0] current_state,
    output reg [7:0] remaining_time,
    output reg cycle_complete,
    output reg error
);

    // State definitions
    localparam IDLE          = 4'b0000;
    localparam FILLING       = 4'b0001;
    localparam HEATING       = 4'b0010;
    localparam WASHING       = 4'b0011;
    localparam RINSING       = 4'b0100;
    localparam SPINNING      = 4'b0101;
    localparam DRAINING      = 4'b0110;
    localparam COMPLETE      = 4'b0111;
    localparam ERROR_STATE   = 4'b1000;
    localparam PAUSED        = 4'b1001;

    // Program parameters
    reg [7:0] target_water_level;
    reg [7:0] target_temperature;
    reg [7:0] wash_time;
    reg [7:0] rinse_time;
    reg [7:0] spin_time;
    reg [1:0] wash_speed;
    reg [1:0] spin_speed;
    
    // Internal registers
    reg [7:0] timer;
    reg [2:0] rinse_count;
    reg [2:0] current_rinse;
    reg previous_pause;
    
    // RISC-V simplified instruction set for washing machine control
    // This is a very simplified representation of RISC-V instructions for demonstration
    localparam INSTR_NOP     = 32'h00000013;  // NOP (addi x0, x0, 0)
    localparam INSTR_LOAD    = 32'h00000003;  // Load
    localparam INSTR_STORE   = 32'h00000023;  // Store
    localparam INSTR_ADD     = 32'h00000033;  // Add
    localparam INSTR_SUB     = 32'h40000033;  // Subtract
    localparam INSTR_BRANCH  = 32'h00000063;  // Branch
    localparam INSTR_JUMP    = 32'h0000006F;  // Jump
    
    // Program counter and instruction register
    reg [31:0] pc;
    reg [31:0] instruction;
    
    // Simplified register file (8 registers)
    reg [31:0] registers [0:7];
    
    // Program memory (simplified, would be much larger in reality)
    reg [31:0] program_mem [0:63];
    
    // Initialize program memory with washing machine control program
    initial begin
        // This is a simplified representation of a RISC-V program
        // In reality, this would be loaded from memory or programmed separately
        program_mem[0]  = INSTR_LOAD;    // Load program parameters
        program_mem[1]  = INSTR_BRANCH;  // Check if door is closed
        program_mem[2]  = INSTR_LOAD;    // Load water level target
        program_mem[3]  = INSTR_STORE;   // Store to control register
        program_mem[4]  = INSTR_LOAD;    // Load temperature target
        program_mem[5]  = INSTR_STORE;   // Store to control register
        program_mem[6]  = INSTR_BRANCH;  // Check water level
        program_mem[7]  = INSTR_BRANCH;  // Check temperature
        program_mem[8]  = INSTR_LOAD;    // Load wash time
        program_mem[9]  = INSTR_STORE;   // Store to timer
        program_mem[10] = INSTR_LOAD;    // Load motor parameters
        program_mem[11] = INSTR_STORE;   // Control motor
        program_mem[12] = INSTR_SUB;     // Decrement timer
        program_mem[13] = INSTR_BRANCH;  // Check if wash complete
        program_mem[14] = INSTR_JUMP;    // Jump to next phase
        // ... more instructions would follow
    end
    
    // Simplified instruction fetch and execute
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'h0;
            instruction <= INSTR_NOP;
            // Reset all registers
            registers[0] <= 32'h0;
            registers[1] <= 32'h0;
            registers[2] <= 32'h0;
            registers[3] <= 32'h0;
            registers[4] <= 32'h0;
            registers[5] <= 32'h0;
            registers[6] <= 32'h0;
            registers[7] <= 32'h0;
        end
        else begin
            // Fetch instruction
            instruction <= program_mem[pc];
            
            // Execute (simplified)
            case (instruction[6:0])  // opcode field
                7'b0000011: begin  // LOAD
                    // Simplified load operation
                    registers[instruction[11:7]] <= registers[instruction[19:15]] + instruction[31:20];
                    pc <= pc + 1;
                end
                7'b0100011: begin  // STORE
                    // Simplified store operation
                    // In a real implementation, this would write to memory
                    pc <= pc + 1;
                end
                7'b0110011: begin  // R-type (ADD, SUB, etc.)
                    if (instruction[30]) // SUB
                        registers[instruction[11:7]] <= registers[instruction[19:15]] - registers[instruction[24:20]];
                    else // ADD
                        registers[instruction[11:7]] <= registers[instruction[19:15]] + registers[instruction[24:20]];
                    pc <= pc + 1;
                end
                7'b1100011: begin  // BRANCH
                    // Simplified branch operation
                    if (registers[instruction[19:15]] == registers[instruction[24:20]])
                        pc <= pc + {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                    else
                        pc <= pc + 1;
                end
                7'b1101111: begin  // JUMP
                    // Simplified jump operation
                    registers[instruction[11:7]] <= pc + 1;
                    pc <= pc + {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                end
                default: begin
                    pc <= pc + 1;  // Default: move to next instruction
                end
            endcase
        end
    end
    
    // Main state machine for washing machine control
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            water_valve <= 0;
            drain_valve <= 0;
            motor_speed <= 2'b00;
            motor_direction <= 2'b00;
            heater <= 0;
            detergent_dispenser <= 0;
            softener_dispenser <= 0;
            remaining_time <= 0;
            cycle_complete <= 0;
            error <= 0;
            timer <= 0;
            rinse_count <= 0;
            current_rinse <= 0;
            previous_pause <= 0;
            
            // Default program parameters
            target_water_level <= 8'd50;  // 50% full
            target_temperature <= 8'd30;  // 30 degrees C
            wash_time <= 8'd20;           // 20 minutes
            rinse_time <= 8'd10;          // 10 minutes
            spin_time <= 8'd5;            // 5 minutes
            wash_speed <= 2'b01;          // Low speed
            spin_speed <= 2'b11;          // High speed
        end
        else begin
            // Pause button detection (edge detection)
            if (pause_button && !previous_pause && current_state != IDLE && current_state != COMPLETE && current_state != ERROR_STATE) begin
                if (current_state != PAUSED)
                    current_state <= PAUSED;
                else
                    current_state <= registers[0][3:0]; // Restore previous state from register
            end
            previous_pause <= pause_button;
            
            // Main state machine
            case (current_state)
                IDLE: begin
                    // Reset outputs
                    water_valve <= 0;
                    drain_valve <= 0;
                    motor_speed <= 2'b00;
                    motor_direction <= 2'b00;
                    heater <= 0;
                    detergent_dispenser <= 0;
                    softener_dispenser <= 0;
                    cycle_complete <= 0;
                    
                    // Set program parameters based on program_select
                    case (program_select)
                        3'b000: begin // Quick
                            target_water_level <= 8'd40;
                            target_temperature <= 8'd30;
                            wash_time <= 8'd10;
                            rinse_time <= 8'd5;
                            spin_time <= 8'd3;
                            rinse_count <= 3'd1;
                            wash_speed <= 2'b10;
                            spin_speed <= 2'b11;
                        end
                        3'b001: begin // Normal
                            target_water_level <= 8'd50;
                            target_temperature <= 8'd40;
                            wash_time <= 8'd20;
                            rinse_time <= 8'd10;
                            spin_time <= 8'd5;
                            rinse_count <= 3'd2;
                            wash_speed <= 2'b10;
                            spin_speed <= 2'b11;
                        end
                        3'b010: begin // Heavy
                            target_water_level <= 8'd60;
                            target_temperature <= 8'd60;
                            wash_time <= 8'd30;
                            rinse_time <= 8'd15;
                            spin_time <= 8'd8;
                            rinse_count <= 3'd3;
                            wash_speed <= 2'b11;
                            spin_speed <= 2'b11;
                        end
                        3'b011: begin // Delicate
                            target_water_level <= 8'd55;
                            target_temperature <= 8'd20;
                            wash_time <= 8'd15;
                            rinse_time <= 8'd8;
                            spin_time <= 8'd2;
                            rinse_count <= 3'd2;
                            wash_speed <= 2'b01;
                            spin_speed <= 2'b01;
                        end
                        3'b100: begin // Custom
                            // Use default values or could be set via additional inputs
                        end
                        default: begin // Default to Normal
                            target_water_level <= 8'd50;
                            target_temperature <= 8'd40;
                            wash_time <= 8'd20;
                            rinse_time <= 8'd10;
                            spin_time <= 8'd5;
                            rinse_count <= 3'd2;
                            wash_speed <= 2'b10;
                            spin_speed <= 2'b11;
                        end
                    endcase
                    
                    // Calculate total cycle time
                    remaining_time <= wash_time + (rinse_time * rinse_count) + spin_time;
                    
                    // Start cycle if start button pressed and door is closed
                    if (start_button && door_closed) begin
                        current_state <= FILLING;
                        current_rinse <= 0;
                    end
                    else if (start_button && !door_closed) begin
                        current_state <= ERROR_STATE;
                        error <= 1;
                    end
                end
                
                FILLING: begin
                    water_valve <= 1;
                    drain_valve <= 0;
                    motor_speed <= 2'b00;
                    motor_direction <= 2'b00;
                    
                    // If door opens during operation, go to error state
                    if (!door_closed) begin
                        current_state <= ERROR_STATE;
                        error <= 1;
                    end
                    // When water level reaches target, move to next state
                    else if (water_level >= target_water_level) begin
                        water_valve <= 0;
                        if (current_rinse == 0) begin
                            // First fill is for washing
                            detergent_dispenser <= 1;
                            current_state <= HEATING;
                        end
                        else begin
                            // Subsequent fills are for rinsing
                            if (current_rinse == rinse_count) begin
                                softener_dispenser <= 1;
                            end
                            current_state <= RINSING;
                        end
                    end
                end
                
                HEATING: begin
                    detergent_dispenser <= 0;
                    heater <= 1;
                    
                    // If door opens during operation, go to error state
                    if (!door_closed) begin
                        current_state <= ERROR_STATE;
                        error <= 1;
                    end
                    // When temperature reaches target, move to washing
                    else if (temperature >= target_temperature) begin
                        heater <= 0;
                        current_state <= WASHING;
                        timer <= wash_time;
                    end
                end
                
                WASHING: begin
                    motor_speed <= wash_speed;
                    motor_direction <= 2'b11; // Alternating direction
                    
                    // If door opens during operation, go to error state
                    if (!door_closed) begin
                        current_state <= ERROR_STATE;
                        error <= 1;
                    end
                    else begin
                        // Decrement timer each minute (this would be scaled in real implementation)
                        if (timer > 0) begin
                            timer <= timer - 1;
                            remaining_time <= remaining_time - 1;
                        end
                        else begin
                            // Washing complete, move to draining
                            motor_speed <= 2'b00;
                            current_state <= DRAINING;
                        end
                    end
                end
                
                RINSING: begin
                    softener_dispenser <= 0;
                    motor_speed <= wash_speed;
                    motor_direction <= 2'b11; // Alternating direction
                    
                    // If door opens during operation, go to error state
                    if (!door_closed) begin
                        current_state <= ERROR_STATE;
                        error <= 1;
                    end
                    else begin
                        // Decrement timer each minute
                        if (timer > 0) begin
                            timer <= timer - 1;
                            remaining_time <= remaining_time - 1;
                        end
                        else begin
                            // Rinsing complete, move to draining
                            motor_speed <= 2'b00;
                            current_state <= DRAINING;
                        end
                    end
                end
                
                DRAINING: begin
                    drain_valve <= 1;
                    
                    // If door opens during operation, go to error state
                    if (!door_closed) begin
                        current_state <= ERROR_STATE;
                        error <= 1;
                    end
                    // When water level is low enough, decide next state
                    else if (water_level <= 8'd5) begin
                        drain_valve <= 0;
                        
                        if (current_rinse < rinse_count) begin
                            // More rinse cycles needed
                            current_rinse <= current_rinse + 1;
                            current_state <= FILLING;
                            timer <= rinse_time;
                        end
                        else begin
                            // All rinse cycles complete, move to spinning
                            current_state <= SPINNING;
                            timer <= spin_time;
                        end
                    end
                end
                
                SPINNING: begin
                    motor_speed <= spin_speed;
                    motor_direction <= 2'b01; // Clockwise
                    
                    // If door opens during operation, go to error state
                    if (!door_closed) begin
                        current_state <= ERROR_STATE;
                        error <= 1;
                    end
                    else begin
                        // Decrement timer each minute
                        if (timer > 0) begin
                            timer <= timer - 1;
                            remaining_time <= remaining_time - 1;
                        end
                        else begin
                            // Spinning complete, cycle is done
                            motor_speed <= 2'b00;
                            current_state <= COMPLETE;
                            cycle_complete <= 1;
                        end
                    end
                end
                
                COMPLETE: begin
                    // Wait for door to open or new cycle to start
                    if (start_button) begin
                        current_state <= IDLE;
                        cycle_complete <= 0;
                    end
                end
                
                ERROR_STATE: begin
                    // Turn off all outputs for safety
                    water_valve <= 0;
                    drain_valve <= 1; // Drain water for safety
                    motor_speed <= 2'b00;
                    motor_direction <= 2'b00;
                    heater <= 0;
                    detergent_dispenser <= 0;
                    softener_dispenser <= 0;
                    
                    // Can only exit error state by resetting
                    if (start_button && door_closed) begin
                        current_state <= IDLE;
                        error <= 0;
                        drain_valve <= 0;
                    end
                end
                
                PAUSED: begin
                    // Store current state in register for resuming later
                    registers[0][3:0] <= current_state;
                    
                    // Turn off all actuators but maintain state
                    water_valve <= 0;
                    drain_valve <= 0;
                    motor_speed <= 2'b00;
                    motor_direction <= 2'b00;
                    heater <= 0;
                    detergent_dispenser <= 0;
                    softener_dispenser <= 0;
                end
                
                default: begin
                    current_state <= IDLE;
                end
            endcase
        end
    end
endmodule 