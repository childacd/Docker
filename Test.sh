#!/bin/bash

output_file="output.txt"
declare -A machine_map

# 清空输出文件
> $output_file

# 遍历所有文件夹中的 .jil 文件
for file in */*virtual_machine*.jil; do
    if [ -f "$file" ]; then
        # 读取文件内容
        while IFS=: read -r key value; do
            case "$key" in
                delete_machine)
                    autosys_vm=$(echo "$value" | xargs)
                    ;;
                machine)
                    host_name=$(echo "$value" | xargs)
                    ;;
            esac
        done < "$file"

        # 检查是否已经存在相同的 machine
        if [[ -n "${machine_map[$autosys_vm]}" && "${machine_map[$autosys_vm]}" != "$host_name" ]]; then
            echo "Conflict detected for $autosys_vm: ${machine_map[$autosys_vm]} vs $host_name"
        else
            machine_map[$autosys_vm]=$host_name
        fi
    fi
done

# 输出结果到文件
for autosys_vm in "${!machine_map[@]}"; do
    echo "$autosys_vm:" >> $output_file
    echo "    host_name: ${machine_map[$autosys_vm]}" >> $output_file
    echo "    autosys_vm: $autosys_vm" >> $output_file
done

echo "Output written to $output_file"
