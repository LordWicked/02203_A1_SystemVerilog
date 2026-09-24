// -----------------------------------------------------------------------------
//
//  Title      :  System Verilog FSMD implementation template for GCD
//             :
//  Developers :  Otto Westy Rasmussen
//             :
//  Purpose    :  This is a template for the FSMD (finite state machine with datapath) 
//             :  implementation of the GCD circuit
//             :
//  Revision   :  02203 fall 2025 v.1.0
//
// -----------------------------------------------------------------------------


module gcd (
    input  logic          clk,    // The clock signal.
    input  logic          reset,  // Reset the module.
    input  logic          req,    // Start computation.
    input  logic [15 : 0] AB,     // The two operands. One at a time.
    output logic          ack,    // Input received / Computation is complete.
    output logic [15 : 0] C       // The result.
);
    typedef enum logic [3 : 0] { waitA, getA, send_ack, waitB, getB, moduloY, transmitC } state_t; // Input your own state names here

    shortint unsigned reg_a, next_reg_a, reg_b, next_reg_b;
    
    state_t state, next_state;

    //added by me
    logic [1:0] FN_ALU;
    shortint unsigned Y;
    logic Nflag, Zflag;
    
    // Combinatorial logic
    //Control block
    always_comb begin

        ack = 0;
        C = 0;
        next_state = state;
        next_reg_a = reg_a;
        next_reg_b = reg_b;
        FN_ALU = 2'b00;

        
        case (state)
            // <COMBINATORIAL BODY>
	    waitA: begin
            ack = 0;
            if (req) begin
                next_state = getA;
            end
        end
        getA: begin
            ack = 0;
            next_reg_a = AB;  // store A
            next_state = send_ack;
        end
        send_ack: begin
            ack = 1;
            if (!req) begin
               next_state = waitB;
            end
        end
        waitB: begin
            ack = 0;
            if (req) begin
              next_state = getB;
            end
        end

        getB: begin
            ack = 0;
            next_reg_b = AB;
            next_state = moduloY;
        end

        moduloY: begin
            ack = 0;
            FN_ALU = 2'b00;
            if (Zflag) begin
                next_state = transmitC;
            end else begin
                next_reg_b = Y;
                next_reg_a = reg_b;
            end
        end

        transmitC: begin
            ack = 1;
            C = reg_b;
            if (!req) begin
                next_state = waitA;
            end
        end
        
        // should add an handle of 0 input !!!!!!
        endcase
    end

    // ALU block
    always_comb begin
        case (FN_ALU)
        
        2'b00: 
            Y = reg_a % reg_b;
        2'b01: 
            Y = reg_a;
        2'b10: 
            Y = reg_b;
        2'b11: 
            Y = reg_b;

        endcase

        Nflag = Y[15];
        if (!Y) begin
            Zflag = 1;
        end else begin
            Zflag = 0;
        end

    end


        // Register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= waitA;
            reg_a     <= 0;
            reg_b     <= 0;
        end else begin
            state <= next_state;
            reg_a     <= next_reg_a;
            reg_b     <= next_reg_b;
        end
    end

endmodule