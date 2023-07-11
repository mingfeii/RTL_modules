if ![file isdirectory ./work] { vlib ./work }
vmap work ./work

vlog dma_intf.v
vlog dmac_ahb_ctrl.v
vlog dmac_arb.v
vlog dmac_channel_ctrl.v
vlog dmac_channel.v
vlog dmac_fifo.v
vlog dmac.v
vlog test_dma.v

 vsim work.test_dma -voptargs=+acc
#  do wave.do
 run -all
