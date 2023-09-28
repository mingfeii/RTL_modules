onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group sim:/test/u_divider/Group1 -radix decimal /test/u_divider/clk
add wave -noupdate -expand -group sim:/test/u_divider/Group1 -radix decimal /test/u_divider/rstn
add wave -noupdate -expand -group sim:/test/u_divider/Group1 -radix decimal /test/u_divider/valid_in
add wave -noupdate -expand -group sim:/test/u_divider/Group1 -radix decimal /test/u_divider/dividend
add wave -noupdate -expand -group sim:/test/u_divider/Group1 -radix decimal /test/u_divider/divisor
add wave -noupdate -expand -group sim:/test/u_divider/Group1 -radix decimal /test/u_divider/valid_o
add wave -noupdate -expand -group sim:/test/u_divider/Group1 -radix decimal /test/u_divider/unsigned_dividend
add wave -noupdate -expand -group sim:/test/u_divider/Group1 -radix decimal /test/u_divider/unsigned_divisor
add wave -noupdate -expand -group sim:/test/u_divider/Group1 -radix decimal /test/u_divider/unsigned_remainder
add wave -noupdate -expand -group sim:/test/u_divider/Group1 -radix decimal /test/u_divider/dividend_is_negetive
add wave -noupdate -expand -group sim:/test/u_divider/Group1 -radix decimal /test/u_divider/divisor_is_negetive
add wave -noupdate -expand -group sim:/test/u_divider/Group1 -radix decimal /test/u_divider/dividend_is_negetive_d
add wave -noupdate -expand -group sim:/test/u_divider/Group1 -radix decimal /test/u_divider/divisor_is_negetive_d
add wave -noupdate -expand -group sim:/test/u_divider/Group1 -radix decimal /test/u_divider/unsigned_quotient
add wave -noupdate -expand -group sim:/test/u_divider/Group1 -radix decimal /test/u_divider/signed_quotient
add wave -noupdate -expand -group sim:/test/u_divider/Group1 -radix decimal /test/u_divider/signed_remainder
add wave -noupdate -radix decimal /test/u_divider/quotient
add wave -noupdate -radix decimal /test/u_divider/remainder
add wave -noupdate -expand -group sim:/test/Group1 -radix decimal /test/clk
add wave -noupdate -expand -group sim:/test/Group1 -radix decimal /test/rstn
add wave -noupdate -expand -group sim:/test/Group1 -radix decimal /test/data_rdy
add wave -noupdate -expand -group sim:/test/Group1 -radix decimal /test/dividend
add wave -noupdate -expand -group sim:/test/Group1 -radix decimal /test/divisor
add wave -noupdate -expand -group sim:/test/Group1 -radix decimal /test/res_rdy
add wave -noupdate -expand -group sim:/test/Group1 -radix decimal /test/merchant
add wave -noupdate -expand -group sim:/test/Group1 -radix decimal /test/remainder
add wave -noupdate -expand -group sim:/test/Group1 -radix decimal /test/data_count
add wave -noupdate -expand -group sim:/test/Group1 -radix decimal /test/error_flag
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {19925 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 406
configure wave -valuecolwidth 338
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
WaveRestoreZoom {0 ns} {21005 ns}
