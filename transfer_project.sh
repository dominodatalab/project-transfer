#!/usr/bin/env bash

# Set a shell flag to have the entire script fail if one command fails
set -e

# Gather parameters, exists early and display error if missing parameter
old_domino_url=${1:?"Old Domino URL is required"} && shift 1
new_domino_url=${1:?"New Domino URL is required"} && shift 1
project_names=(${@:?"Project Names are required"})

# Define a subshell function (uses paranthases instead of curly braces)
# A subshell is used to reduce complexity of moving in and out of directories
function upload_project() (
    # Open the project directory and remove the existing .domino directory
    cd "${1}"
    rm -rf .domino

    # Initialize the project and upload it to the Domino instance
    printf '\n' | domino init
    domino upload
)

# Login to old Domino instance
echo -e "\e[34mLogging into ${old_domino_url}\e[0m"
domino login "${old_domino_url}"

# Iterate over all the projects and download them to disk
for name in "${project_names[@]}"; do
    echo
    domino get "${name}"
done

# Login to the new Domino instance
echo -e "\e[34m\nLogging into ${new_domino_url}\e[0m"
domino login "${new_domino_url}"

# Iterate over all the projects and upload them to Domino
for name in "${project_names[@]}"; do
    echo
    upload_project "${name}"
done
