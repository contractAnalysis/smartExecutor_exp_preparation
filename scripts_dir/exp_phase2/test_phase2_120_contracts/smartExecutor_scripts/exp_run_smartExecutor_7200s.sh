#!/bin/bash

group_index=$1

csv_data_file_prefix='sGuard_contracts_info_group'

contract_folder='contracts'

#con_work_dir='/home/mythril/'
con_work_dir='./' # current directory


export PATH=/usr/local/bin:$PATH

result_folder=smartExecutor_group_${group_index}_results
rm -rf ${result_folder}
mkdir ${result_folder}


exec < ${con_work_dir}${csv_data_file_prefix}_${group_index}.csv || exit 1
#read header # read (and ignore) the first line
while IFS="," read solidity_name solc_version contract_name
  do
 echo "++++ ${solidity_name}  :  ${solc_version}  :  ${contract_name} ++++"  | tee -a ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}.txt
	solc-select install ${solc_version}
	 solc-select use ${solc_version} | tee -a ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}.txt

	
	start=$(date +%s.%N)
	 timeout 7300 myth analyze ${con_work_dir}${contract_folder}/$solidity_name:${contract_name}  --create-timeout 60 --execution-timeout 7200 -fdg -p 1 -p1All 1 -p2 1 | tee -a ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}.txt
	
	end=$(date +%s.%N) 
	runtime1=$(python -c "print(${end} - ${start})")
	
        echo "time_used: "${runtime1}" seconds"  | tee -a ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}.txt

	echo "#@contract_info_time" | tee -a ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}.txt  
	echo ${solidity_name}:${solc_version}:${contract_name}:${runtime1}:7300:60:7200 | tee -a ${con_work_dir}${result_folder}/${solidity_name}__${contract_name}.txt  


  done

