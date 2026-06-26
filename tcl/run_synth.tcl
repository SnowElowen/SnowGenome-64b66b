set repo_root [file normalize [file join [file dirname [info script]] ..]]
open_project $repo_root/build/snowgenome.xpr
reset_run synth_1
launch_runs synth_1 -jobs 8
wait_on_run synth_1
open_run synth_1
file mkdir $repo_root/reports/timing
file mkdir $repo_root/reports/utilization
report_timing_summary -file $repo_root/reports/timing/post_synth_timing_summary.rpt
report_utilization -file $repo_root/reports/utilization/post_synth_utilization.rpt
report_high_fanout_nets -file $repo_root/reports/timing/post_synth_high_fanout_nets.rpt
