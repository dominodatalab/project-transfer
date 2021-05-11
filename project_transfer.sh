#!/usr/bin/env bash

# Set a shell flag to have the entire script fail if one command fails
set -e

# Gather parameters, will exit early and display error if missing parameter
old_domino_url=${1:?"Old Domino URL is required"} && shift 1
new_domino_url=${1:?"New Domino URL is required"} && shift 1
project_names=(${@:?"Project Names are required"})

# Define a subshell function (uses parentheses instead of curly braces)
# A subshell is used to reduce complexity of moving in and out of directories
function upload_project() (
    # Open the project directory and remove the existing .domino directory
    cd "${1}"
    rm -rf .domino

    # Tar the project, excluding .domino and CLI log
    tar --exclude='./domino.log' -cvzf "../${1}.tar.gz" .

    # Delete everything and move the tar ball back to this directory
    find . -not -name "${1}.tar.gz" -delete
    mv "../${1}.tar.gz" .

    # Initialize the project and pipe in an enter to use the default name
    printf '\n' | domino init

    # Kick off run to untar file, which wil force an upload
    domino run --direct "tar -xzvf ${1}.tar.gz && rm -rf ${1}.tar.gz"
)

# Move to /tmp to avoid conflict with /mnt domino files
cd /tmp

# Login to old Domino instance
echo -e "\e[94mLogging into ${old_domino_url}\e[0m"
domino login "${old_domino_url}"

# Iterate over all the projects and download them to disk, then tar and delete
for name in "${project_names[@]}"; do
    simple_name=$(echo "${name}" | cut -f 2 -d /)
    [[ -d "${simple_name}" ]] && rm -rf "${simple_name}"

    echo
    domino get "${name}"
done

# Login to the new Domino instance
echo -e "\e[94m\nLogging into ${new_domino_url}\e[0m"
domino login "${new_domino_url}"

# Iterate over all the projects and upload them to Domino
for name in "${project_names[@]}"; do
    # Remove the username from project name when admin is tranferring projects
    # Does not affect project names that do not contain a username
    name=$(echo "${name}" | cut -f 2 -d /)

    echo
    upload_project "${name}"

    # Remove the temporary project to avoid collisions on consecutive runs
    rm -rf "${name}"
done
