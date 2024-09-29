#!/bin/bash

### summing up ###
# Helper function to sum the fields of two lines
sum_fields() {
  IFS=',' read -r -a line1 <<< "$1"
  IFS=',' read -r -a line2 <<< "$2"
  sum=""
  for i in {1..6}; do
    sum+=$((${line1[$i]} + ${line2[$i]}))
    if [[ $i -lt 6 ]]; then
      sum+=","
    fi
  done
  echo $sum
}

# Function to process a region (e.g., "tee", "tew", etc.)
process_region() {
  local region="$1"
  local log_file="$2"
  local output_file="$3"
  local device11=()
  local device21=()
  local device=""

  # Read log file and capture lines for device11 and device21
  while IFS=, read -r date field2 field3 field4 field5 field6 field7; do
    if [[ $date =~ ^[a-zA-Z]+[0-9]+$ ]]; then
      device="$date"
    elif [[ $device == "${region}11" ]]; then
      device11+=("$date,$field2,$field3,$field4,$field5,$field6,$field7")
    elif [[ $device == "${region}21" ]]; then
      device21+=("$date,$field2,$field3,$field4,$field5,$field6,$field7")
    fi
  done < "$log_file"

  # Summing fields for each matching date and writing to the output file
  echo "Summing $region..."
  for i in "${!device11[@]}"; do
    sum=$(sum_fields "${device11[$i]}" "${device21[$i]}")
    date=$(echo "${device11[$i]}" | cut -d',' -f1)
    echo "$region,$date,$sum" >> "$output_file"
  done
}

# Main script execution
log_file="temp.log"
output_file="a.txt"
regions=("tee" "tew" "ta" "is" "sh" "ma" "ah" "al")

# Ensure output file is empty before appending new data
> "$output_file"

for region in "${regions[@]}"; do
  process_region "$region" "$log_file" "$output_file"
done

echo "Summed logs written to $output_file"

### percenting ###
filename="a.txt"
result="format.log"

# Check if the file exists
if [ ! -f "$filename" ]; then
    echo "File not found!"
    exit 1
fi

# create result file
touch $result

# adding header fields
headers="Region,Date-hour,record_count,file_count,s---_flag_count,s--r_flag_count,s-p-_flag_count,s-pr_flag_count,s---_flag_percent,s--r_flag_percent,s-p-_flag_percent,s-pr_flag_percent"
echo $headers > $result

# Read the file line by line
while IFS= read -r line
do
    # Extract the fields using awk and split by comma
    field3=$(echo "$line" | awk -F, '{print $3}')
    field5=$(echo "$line" | awk -F, '{print $5}')
    field6=$(echo "$line" | awk -F, '{print $6}')
    field7=$(echo "$line" | awk -F, '{print $7}')
    field8=$(echo "$line" | awk -F, '{print $8}')

    # Perform the division by field2 and multiply by 100 to get percentages with higher precision
    if [[ "$field2" != "0" ]]; then
        result1=$(echo "scale=6; ($field5 / $field3) * 100" | bc)
        result2=$(echo "scale=6; ($field6 / $field3) * 100" | bc)
        result3=$(echo "scale=6; ($field7 / $field3) * 100" | bc)
        result4=$(echo "scale=6; ($field8 / $field3) * 100" | bc)
        new_line="$line,${result1},${result2},${result3},${result4}"
    else
        new_line="$line,division_by_zero"
    fi

    # Output the new line
    echo "$new_line" >> $result

done < "$filename"
echo >> $result
echo "percenting and summing done."

# plotting the informations
mkdir imgs
echo "ploting information and copying to imgs directory . . ."
python3 core.py
echo "Done."
