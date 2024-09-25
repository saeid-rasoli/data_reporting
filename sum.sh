#!/bin/bash

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
output_file="summed_logs.txt"
regions=("tee" "tew" "ta" "is" "sh" "ma" "ah" "al")

# Ensure output file is empty before appending new data
> "$output_file"

for region in "${regions[@]}"; do
  process_region "$region" "$log_file" "$output_file"
done

echo "Summed logs written to $output_file"
