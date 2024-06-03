#!/bin/bash

# Define a list of script paths
script_paths=(
    "app.dart"
    "auth_gate.dart"
    "common_drawer.dart"
    "create_project_screen.dart"
    "data_dashboard_screen.dart"
    "data_policy_screen.dart"
    "default_data.dart"
    "display_name_preference.dart"
    "download_data_screen.dart"
    "firebase_utils.dart"
    "list_projects_screen.dart"
    "main.dart"
    "manage_users_screen.dart"
    "preferences_service.dart"
    "upload_data_screen.dart"
    "settings_screen.dart"
    "display_name_preferenece.dart"
    "utils.dart"

    # Add more script paths as needed
)

# Specify the output file
output_file="out.txt"

# Check if the output file already exists and remove it to start fresh
if [ -f "$output_file" ]; then
    rm "$output_file"
fi

# Iterate through each script path
for script_path in "${script_paths[@]}"; do
    # Check if the script file exists
    if [ -f "$script_path" ]; then
        # Extract the filename from the path
        filename=$(basename "$script_path")
        
        # Append a line of ########## before the filename
        echo "##########" >> "$output_file"
        
        # Append the filename to the output file
        echo "Filename: $filename" >> "$output_file"
        
        # Append a line of ########## before the content
        echo "##########" >> "$output_file"
        
        # Append the content of the script file to the output file
        echo "Content:" >> "$output_file"
        cat "$script_path" >> "$output_file"
        
        # Append a line of ########## after the content for separation
        echo "##########" >> "$output_file"
        echo "" >> "$output_file" # Add a newline for better readability between scripts
    else
        echo "The file $script_path does not exist."
    fi
done

echo "The contents have been written to $output_file."
