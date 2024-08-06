run_dir="/project/rrg-mdiamond/data/MATHUSLA//simulation/run-2024-07-cosmic-proton/"
step_files_pattern="$run_dir/SimOutput/cosmic/run*/*/*/run_step_data.root"
step_files=( $step_files_pattern )

for i in "${step_files[@]}"
do

    kaon_file="${i%.root}_kaons.joblib"
    # if [ ! -f $kaon_file ]; then
    #     echo "processing file ${i}"
    #     python3 extract_kaons.py $i
    # fi
    python3 extract_kaons.py $i

done