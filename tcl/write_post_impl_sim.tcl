set repo_root [file normalize [file join [file dirname [info script]] ..]]
open_project $repo_root/build/snowgenome.xpr
open_run impl_1
file mkdir $repo_root/sim/post_impl
write_verilog -force -mode timesim -nolib -sdf_anno true $repo_root/sim/post_impl/post_impl_netlist.v
write_sdf -force $repo_root/sim/post_impl/post_impl_netlist.sdf
