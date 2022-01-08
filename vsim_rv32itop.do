vsim -voptargs="+acc" work.RV32ITop_test

radix -hexadecimal

add wave -label clock clock
add wave -label reset reset

add wave -height 20 -divider PC

add wave -label pc DUT/rv/pc
add wave -label pc_next DUT/rv/dp/pc_next
add wave -group pc_src_group  \
    -label pc_sel DUT/rv/dp/pc_sel  \
    -label pc_plus4 DUT/rv/dp/pc_plus4  \
    -label pc_branch DUT/rv/dp/pc_branch  \

add wave -height 20 -divider Instruction

add wave -label inst DUT/rv/inst
add wave -group inst_group  \
    -label opcode DUT/rv/opcode  \
    -label funct3 DUT/rv/funct3  \
    -label funct7 DUT/rv/funct7  \
    -label rs1 DUT/rv/dp/rs1  \
    -label rs2 DUT/rv/dp/rs2  \
    -label rd DUT/rv/dp/rd  \
    -label i_imm DUT/rv/dp/i_imm  \
    -label s_imm DUT/rv/dp/s_imm  \
    -label b_imm DUT/rv/dp/b_imm  \
    -label u_imm DUT/rv/dp/u_imm  \
    -label j_imm DUT/rv/dp/j_imm  \

add wave -height 20 -divider Register

add wave -group register_read_group  \
    -label reg_r_data1 DUT/rv/dp/reg_r_data1  \
    -label reg_r_data2 DUT/rv/dp/reg_r_data2
add wave -label reg_w_data DUT/rv/dp/reg_w_data
add wave -label reg_w_en DUT/rv/reg_w_en
add wave -label rd DUT/rv/dp/rd
add wave -group register_write_group  \
    -label reg_w_sel DUT/rv/reg_w_sel  \
    -label u_imm DUT/rv/dp/u_imm  \
    -label result DUT/rv/dp/result  \
    -label pc_plus4 DUT/rv/dp/pc_plus4
add wave -label register_file DUT/rv/dp/rf/regfile

add wave -height 20 -divider ALU

add wave -label src_a DUT/rv/dp/src_a
add wave -label src_b DUT/rv/dp/src_b
add wave -label alu_result DUT/rv/dp/alu_result
add wave -group ALU_group  \
    -label alu_zero DUT/rv/dp/alu_zero  \
    -label alu_con -radix binary DUT/rv/alu_con  \
    -label src_a_sel DUT/rv/src_a_sel  \
    -label src_b_sel DUT/rv/src_b_sel

add wave -height 20 -divider Result

add wave -label result DUT/rv/dp/result
add wave -group result_group  \
    -label result_sel DUT/rv/result_sel  \
    -label alu_result DUT/rv/dp/alu_result  \
    -label mem_r_data DUT/rv/mem_r_data

add wave -height 20 -divider Memory

add wave -label mem_addr DUT/rv/mem_addr
add wave -label mem_r_data DUT/rv/mem_r_data
add wave -label mem_w_en DUT/rv/mem_w_en
add wave -label mem_w_data DUT/rv/mem_w_data


run 2000 ns
wave zoom full

# quit -f
