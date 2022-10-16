#!/bin/bash


group_name_prefix='contracts_4_group'

run_script='exp_run_mythril_1800s.sh'
job_1_container_script='exp_1_container_mythril.sh'

base_path='/scratch/06227/qiping/exp_benchmark/SB_Curated/IB_RE_ULC/mythril_data/'
con_work_dir='/home/mythril/'


sif_dir=${base_path}
sif_name='contract_analysis_mythril_Original_modified.sif'

for i in {0..0}
do
# make sure each job have a different name, so that I can distinguish differnt jobs by names
 sbatch  -p  normal -n 1 -N 1 -t 2:10:00 -J job_$((i+1))_mythril J26Container.sh  $((i*30))  ${group_name_prefix} ${run_script} ${job_1_container_script} ${base_path} ${con_work_dir} ${sif_name}

done

exit



