module cpu_jmp_cond_decoder (
    cond,

    eq,
    gt,
    lt,
    accel_can_read,
    accel_can_write,

    result
);

localparam COND_WIDTH = 4;

localparam COND_EQ  = 0;
localparam COND_NE  = 1;
localparam COND_LT  = 2;
localparam COND_LE  = 3;
localparam COND_GT  = 4;
localparam COND_GE  = 5;
localparam COND_CR  = 6;
localparam COND_CW  = 7;
localparam COND_NCR = 8;
localparam COND_NCW = 9;

input [COND_WIDTH - 1:0] cond;

input eq;
input gt;
input lt;
input accel_can_read;
input accel_can_write;

output reg result;

// result
always @(*) begin
    case (cond)
        COND_EQ:  result = eq;
        COND_NE:  result = !eq;
        COND_LT:  result = lt;
        COND_LE:  result = lt || eq;
        COND_GT:  result = gt;
        COND_GE:  result = gt || eq;
        COND_CR:  result = accel_can_read;
        COND_CW:  result = accel_can_write;
        COND_NCR: result = !accel_can_read;
        COND_NCW: result = !accel_can_write;
        default:  result = 0;
    endcase
end

endmodule
