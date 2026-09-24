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


module gcd_stein (
    input  logic          clk,    // The clock signal.
    input  logic          reset,  // Reset the module.
    input  logic          req,    // Start computation.
    input  logic [15 : 0] AB,     // The two operands. One at a time.
    output logic          ack,    // Input received / Computation is complete.
    output logic [15 : 0] C       // The result.
);
    typedef enum logic [3 : 0] { waitA, getA, send_ack, waitB, getB, AsmallerB, AgreaterB, transmitC, eval, restruct, shiftB} state_t;

    shortint unsigned reg_a, next_reg_a, reg_b, next_reg_b;
    
    state_t state, next_state;

    //added by me
    logic [1:0] FN_ALU;
    shortint unsigned Y, k_next, reg_k;
    logic Nflag, Zflag, shift_b;
    
    // Combinatorial logic
    //Control block
    always_comb begin

        ack = 0;
        C = 0;
        shift_b = 0;
        next_state = state;
        next_reg_a = reg_a;
        next_reg_b = reg_b;
        k_next = reg_k;
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
            k_next = 0;
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
            next_state = eval;
        end

        transmitC: begin
            ack = 1;
            C = reg_a;     // can be reg_a or reg_b because they are = anyway
            if (!req) begin
                next_state = waitA;
            end
        end

        // <Stein Body>
        eval: begin
            ack = 0;
            if (reg_a == 16'd0) begin                                       // catch a = 0
                next_reg_a = reg_b;
                next_state = restruct;
            end else if (reg_b == 16'd0) begin                              // catch b = 0
                next_state = restruct;
            end else if ((reg_a[0] == 1'b0) && (reg_b[0] == 1'b0)) begin    // both even
                FN_ALU = 2'b10; // RSH reg_a
                next_reg_a = Y;
                next_state = shiftB;
            end else if (reg_a[0] == 1'b0) begin                           // a even
                FN_ALU = 2'b10;
                next_reg_a = Y;
                next_state = eval;
            end else if (reg_b[0] == 1'b0) begin
                FN_ALU = 2'b10;
                shift_b = 1;                                                // select reg_b for the ALU shift
                next_reg_b = Y;
                next_state = eval;
            end else begin                                                  // both odd
                if (reg_a == reg_b) begin
                    next_state = restruct;
                end else if (reg_a > reg_b) begin
                    FN_ALU = 2'b00; // (a - b)
                    next_reg_a = Y;
                end else begin
                    FN_ALU = 2'b01;
                    next_reg_b = Y;
                end
                if (reg_a != reg_b) begin
                    next_state = eval;
                end
            end
        end      

        shiftB: begin
            ack = 0;
            FN_ALU = 2'b10;
            shift_b = 1;
            next_reg_b = Y;
            k_next = reg_k + 1'b1;
            next_state = eval;
        end      

        restruct: begin
            ack = 0;
            if (reg_k > 4'd0) begin
                FN_ALU = 2'b11;
                next_reg_a = Y;
                k_next = reg_k - 1'b1;
                next_state = restruct;
            end else begin
                next_state = transmitC;
            end
        end
        endcase
    end

    // ALU block
    always_comb begin
        case (FN_ALU)
        
        2'b00: 
            Y = reg_a - reg_b;  // (a - b)
        2'b01: 
            Y = reg_b - reg_a;  // (b - a)
        2'b10: 
            Y = shift_b ? (reg_b >> 1) : (reg_a >> 1); // right shift selected operand
        2'b11: 
            Y = reg_a << 1;     // left shift

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
            reg_k <= 0;
        end else begin
            state <= next_state;
            reg_a     <= next_reg_a;
            reg_b     <= next_reg_b;
            reg_k   <= k_next;
        end
    end

endmodule
