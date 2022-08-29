function [63:0] rotl;
   input [63:0] x;
   input [5:0]  k;
   begin
      rotl = (x << k) | (x>>(64-k));
   end
endfunction // rotl

module user_module_xoroshiro128
  (
   input wire [7:0] io_in,
   output reg [7:0] io_out,
   output wire      clo
   );
   wire             clk = io_in[0];
   wire             rst = io_in[1];
   assign clo = clk;
   
   //internal state
   reg [127:0]      state;
   reg [63:0]       s1n;

   reg [2:0]        cycle;

   always @(posedge rst or posedge clk) begin
      if(rst) begin
         // chosen by fair dice roll. That was a boring 10 minutes.
         state <= 128'b10100101011110101111110100110000110100100100111001110100100010000010010011001001111001110111010101011101111011010111000000010111;
         io_out <= state[127:120] + state[63:56];
         cycle <= 1;
      end else begin
         case(cycle)
           0: begin
              io_out <= state[127:120] + state[63:56];
              cycle <= cycle + 1;
           end
           1: begin
              io_out <= state[119:112] + state[55:48];
              cycle <= cycle + 1;
           end
           2: begin
              io_out <= state[111:104] + state[47:40];
              cycle <= cycle + 1;
           end
           3: begin
              io_out <= state[103:96] + state[39:32];
              cycle <= cycle + 1;
           end
           4: begin
              io_out <= state[95:88] + state[31:24];
              cycle <= cycle + 1;
           end
           5: begin
              io_out <= state[87:80] + state[23:16];
              cycle <= cycle + 1;
           end
           6: begin
              io_out <= state[79:72] + state[15:8];
              s1n <= state[127:64] ^ state[63:0];
              cycle <= cycle + 1;
           end
           7: begin
              io_out <= state[71:64] + state[7:0];
              // update xoroshiro
              state[127:64] <= rotl(state[127:64], 55) ^ s1n ^ (s1n << 14);
              state[63:0] <= rotl(s1n, 36);
              // reset counter
              cycle <= 0;
           end
         endcase // case (cycle)
      end // else: !if(rst)
   end // always @ (posedge rst or posedge clk)
endmodule // user_module_xoroshiro128
