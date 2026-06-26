set repo_root [file normalize [file join [file dirname [info script]] ..]]
set proj_dir  [file join $repo_root build]
file mkdir $proj_dir

create_project snowgenome $proj_dir -part xczu15eg-ffvb1156-2-i -force

add_files [list \
    $repo_root/rtl/ingress/ssg_66b_header_check.v \
    $repo_root/rtl/ingress/ssg_66b_block_capture.v \
    $repo_root/rtl/dna/ssg_packed2_unpack32.v \
    $repo_root/rtl/kmer/ssg_rolling_kmer.v \
    $repo_root/rtl/kmer/ssg_reverse_complement.v \
    $repo_root/rtl/kmer/ssg_canonical_kmer.v \
    $repo_root/rtl/filter/ssg_target_cam_filter.v \
    $repo_root/rtl/filter/ssg_motif_score_kernel.v \
    $repo_root/rtl/event/ssg_event_pack.v \
    $repo_root/rtl/common/ssg_pipe_reg.v \
    $repo_root/rtl/common/ssg_reset_sync_3ff.v \
    $repo_root/rtl/top/snowgenome_top.v \
]

add_files -fileset sim_1 [list \
    $repo_root/tb/tb_snowgenome_top.v \
]

add_files -fileset constrs_1 [list \
    $repo_root/xdc/snowgenome_core_322m.xdc \
]

set_property top snowgenome_top [current_fileset]
set_property top tb_snowgenome_top [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
