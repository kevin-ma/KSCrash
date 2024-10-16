#!/bin/sh

function change_filename_in_path() {
    path=$1
    current_dir=$(pwd)
    cd $path
    for file in $(find . -type f -name "KS*"); do
        new_name=$(echo $file | sed 's/KS/TTSDK/')
        echo "change $file to $new_name in $path"
        mv "$file" "$new_name"
    done
    for dir in $(find . -type d -name "KS*"); do
        new_name=$(echo $dir | sed 's/KS/TTSDK/')
        change_filename_in_path "$path/$dir"
        echo "change $dir to $new_name in $path"
        mv "$dir" "$new_name"
    done
    cd $current_dir
}

cd "$1"
change_filename_in_path $(pwd)
