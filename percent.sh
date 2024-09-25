#!/bin/bash

# Check if the file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 filename"
    exit 1
fi

filename="$1"

# Check if the file exists
if [ ! -f "$filename" ]; then
    echo "File not found!"
    exit 1
fi

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
    echo "$new_line"

done < "$filename"
