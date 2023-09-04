module ClkDiv (
    input   wire            i_ref_clk,
    input   wire            i_rst_n,
    input   wire            i_clk_en,
    input   wire    [3:0]   i_div_ratio,
    output  reg             o_div_clk
);

// Internal signals declaration
reg     [4:0]   counter;        //corner case 15 -> 7 , 8 
wire    [3:0]   half_period;    
wire            LSB;            
wire            check_enable;
reg             div_clk;

// Assign statments
assign  check_enable = i_clk_en && (i_div_ratio != 'b0) && (i_div_ratio != 'b1);
assign  LSB =  i_div_ratio[0];
assign  half_period = (i_div_ratio >> 1);

// combinational always
// assign the output in case it's following the i_ref_clk it must be
// a combinational output at this case not edge triggered
always @(*)
begin
    if(check_enable)
    o_div_clk = div_clk;
    else
    o_div_clk = i_ref_clk;
end

// sequential always
always @(posedge i_ref_clk or negedge i_rst_n) 
begin
    if(!i_rst_n)
        begin
            div_clk <= 'b0;
            counter <= 'b1;
        end
    else if (check_enable)
        begin
            if((counter == half_period) && div_clk || (counter == half_period + LSB) && !div_clk)
                begin
                    div_clk <= ~div_clk;
                    counter <= 'b1;   
                end
            else
                counter <= counter + 1;
        end
    else
        begin
            div_clk <= 1'b0;
            counter <= 1'b1;
        end
end



endmodule