onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/clk
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/rst_n
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} -radix decimal /tb/dividend
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} -radix decimal /tb/divisor
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} -divider {New Divider}
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} -radix decimal /tb/quotient
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} -radix decimal /tb/remainder
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/valid_in
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/valid_o
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/signed_bit_dividend
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/unsigned_dividend
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/sigend_bit_divisor
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/unsigned_divisor
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/data_count
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} -radix unsigned /tb/ocnt
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/error_flag
add wave -noupdate -expand -label sim:/tb/DUT/Group1 -group {Region: sim:/tb/DUT} /tb/DUT/clk_i
add wave -noupdate -expand -label sim:/tb/DUT/Group1 -group {Region: sim:/tb/DUT} /tb/DUT/rst_n_i
add wave -noupdate -expand -label sim:/tb/DUT/Group1 -group {Region: sim:/tb/DUT} /tb/DUT/dividend_i
add wave -noupdate -expand -label sim:/tb/DUT/Group1 -group {Region: sim:/tb/DUT} /tb/DUT/divisor_i
add wave -noupdate -expand -label sim:/tb/DUT/Group1 -group {Region: sim:/tb/DUT} /tb/DUT/valid_i
add wave -noupdate -expand -label sim:/tb/DUT/Group1 -group {Region: sim:/tb/DUT} /tb/DUT/quotient_o
add wave -noupdate -expand -label sim:/tb/DUT/Group1 -group {Region: sim:/tb/DUT} /tb/DUT/remainder_o
add wave -noupdate -expand -label sim:/tb/DUT/Group1 -group {Region: sim:/tb/DUT} /tb/DUT/valid_o
add wave -noupdate -expand -label sim:/tb/DUT/Group1 -group {Region: sim:/tb/DUT} /tb/DUT/unsigned_dividend
add wave -noupdate -expand -label sim:/tb/DUT/Group1 -group {Region: sim:/tb/DUT} /tb/DUT/unsigned_divisor
add wave -noupdate -expand -label sim:/tb/DUT/Group1 -group {Region: sim:/tb/DUT} /tb/DUT/unsigned_quotient
add wave -noupdate -expand -label sim:/tb/DUT/Group1 -group {Region: sim:/tb/DUT} /tb/DUT/unsigned_remainder
add wave -noupdate -expand -label sim:/tb/DUT/Group1 -group {Region: sim:/tb/DUT} /tb/DUT/signed_quotient
add wave -noupdate -expand -label sim:/tb/DUT/Group1 -group {Region: sim:/tb/DUT} /tb/DUT/signed_remainder
add wave -noupdate -expand -label sim:/tb/DUT/Group1 -group {Region: sim:/tb/DUT} /tb/DUT/dividend_is_negetive
add wave -noupdate -expand -label sim:/tb/DUT/Group1 -group {Region: sim:/tb/DUT} /tb/DUT/divisor_is_negetive
add wave -noupdate -expand -label sim:/tb/DUT/Group1 -group {Region: sim:/tb/DUT} /tb/DUT/dividend_is_negetive_d
add wave -noupdate -expand -label sim:/tb/DUT/Group1 -group {Region: sim:/tb/DUT} /tb/DUT/divisor_is_negetive_d
add wave -noupdate -expand -label sim:/tb/DUT/div_u/Group1 -group {Region: sim:/tb/DUT/div_u} /tb/DUT/div_u/clk_i
add wave -noupdate -expand -label sim:/tb/DUT/div_u/Group1 -group {Region: sim:/tb/DUT/div_u} /tb/DUT/div_u/rst_n_i
add wave -noupdate -expand -label sim:/tb/DUT/div_u/Group1 -group {Region: sim:/tb/DUT/div_u} -radix unsigned /tb/DUT/div_u/dividend_i
add wave -noupdate -expand -label sim:/tb/DUT/div_u/Group1 -group {Region: sim:/tb/DUT/div_u} -radix unsigned /tb/DUT/div_u/divisor_i
add wave -noupdate -expand -label sim:/tb/DUT/div_u/Group1 -group {Region: sim:/tb/DUT/div_u} /tb/DUT/div_u/valid_i
add wave -noupdate -expand -label sim:/tb/DUT/div_u/Group1 -group {Region: sim:/tb/DUT/div_u} -radix unsigned /tb/DUT/div_u/quotient_o
add wave -noupdate -expand -label sim:/tb/DUT/div_u/Group1 -group {Region: sim:/tb/DUT/div_u} -radix unsigned /tb/DUT/div_u/remainder_o
add wave -noupdate -expand -label sim:/tb/DUT/div_u/Group1 -group {Region: sim:/tb/DUT/div_u} /tb/DUT/div_u/valid_o
add wave -noupdate -expand -label sim:/tb/DUT/div_u/Group1 -group {Region: sim:/tb/DUT/div_u} /tb/DUT/div_u/q
add wave -noupdate -expand -label sim:/tb/DUT/div_u/Group1 -group {Region: sim:/tb/DUT/div_u} /tb/DUT/div_u/valid_d
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2229824 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 251
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {2609250 ns}
