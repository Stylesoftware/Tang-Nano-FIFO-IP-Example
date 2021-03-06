module TOP (CLOCK,LED_R,LED_G,LED_B);           // I/O from the constraints file

    input CLOCK;                                // inputs are naturally regs
    output LED_R,LED_G,LED_B;                   // outputs are naturally wires

    reg rR=1'b0;                                // create some regs for our LEDS
    reg rG=1'b0;
    reg rB=1'b0;

    assign LED_R = !rR;                         // assign the LED wire to the above reg's, but inversed
    assign LED_G = !rG;
    assign LED_B = !rB;

    reg [7:0] fifo1_in;                         // all our FIFO requirements
    wire [7:0] fifo1_out;
    reg fifo1_read_enable;
    reg fifo1_write_enable;
    wire fifo1_empty;
    wire fifo1_full;

    fifo_top your_instance_name (               // instantiate the FIFO IP from Gowin
        .RdClk(CLOCK),
        .WrClk(CLOCK),
        .RdEn(fifo1_read_enable),
        .WrEn(fifo1_write_enable),
        .Data(fifo1_in),
        .Full(fifo1_full),
        .Empty(fifo1_empty),
        .Q(fifo1_out)
    );

    reg [3:0] RSTATE;                           // Counter for the Read state machine below
    reg [3:0] WSTATE;                           // Counter for the Write state machine below

    initial                                     // Init some stuff
    begin
        fifo1_write_enable <= 1'b0;
        fifo1_read_enable <= 1'b0;
        WSTATE <= 0;
        RSTATE <= 0;
    end

    always @ (posedge CLOCK)                // On every clock edge do the following
    begin
        case (WSTATE)                       // Each clock cycle only does one of the following cases
            0:
            begin
                fifo1_write_enable = 1'b1;  // Enable writing
                fifo1_in <= 8'h65;          // Write first byte
                WSTATE <= 1;
            end
            1:
            begin        
                fifo1_in <= 8'h66;          // Write second byte
                WSTATE <= 2;
            end
            2:
            begin 
               fifo1_in <= 8'h67;           // Write third byte
               WSTATE <= 3;                 // NOTE: Wait 3 more ticks before setting write enable to off
            end
            3:                              // First wait tick
            begin 
               WSTATE <= 4;
            end
            4:                              // Second wait tick
            begin 
               WSTATE <= 5;
            end
            5:                              // Third tick: Set write enable off
            begin 
               fifo1_write_enable = 1'b0;
               WSTATE <= 6;                 // 6 diesn't exist so this sequence will never fire again
            end
        endcase

        if(!fifo1_empty)                            // if the fifo isn't empty run another stateful sequence, one per clock
            begin
            case (RSTATE)
                0:
                begin
                    fifo1_read_enable = 1'b1;       // Start the read proccess by enabling this register (fifo1_read_enable)
                    RSTATE <= 1;                    // NOTE: Wait 3 ticks before reading each byte
                end
                1:                                  // First wait tick
                begin
                    RSTATE <= 2;
                end
                2:                                  // Second wait tick
                begin
                    RSTATE <= 3;
                end
                3:                                  // Third tick to start reading
                begin
                    if(fifo1_out == 8'h65)          // First byte read
                    begin
                        rR = 1'b1;                  // Turn the red LED on if the value is correct
                    end
                    fifo1_read_enable = 1'b0;       // End the read proccess by disabling this register (fifo1_read_enable),
                                                    // three ticks from when it was turned on, if you wish to read three bytes that is...
                    RSTATE <= 4;
                end
                4:                                  // Second byte read
                begin
                    if(fifo1_out == 8'h66)        
                    begin
                        rG = 1'b1;                  // Turn the green LED on if the value is correct
                    end
                    RSTATE <= 5;
                end
                5:                                  // Third byte read
                begin
                    if(fifo1_out == 8'h67)
                    begin
                        rB = 1'b1;                  // Turn the blue LED on if the value is correct
                    end
                    RSTATE <= 6;                    // 6 doesn't exist so this sequence will never fire again
                end
            endcase
        end
    end
endmodule

