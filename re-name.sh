#!/usr/bin/env bash
set -euo pipefail

# Rename image folders/files to match the image03 correction rules in
# check_questionare_names.ipynb.
#
# Run from anywhere. Override ROOT_DIR if needed:
#   ROOT_DIR=/path/to/sourcedata/nii bash re-name.sh
#
# Preview without changing files:
#   DRY_RUN=1 bash re-name.sh

ROOT_DIR="${ROOT_DIR:-/gscratch/scrubbed/fanglab/xiaoqian/IFOCUS/sourcedata/nii}"
DRY_RUN="${DRY_RUN:-0}"

cd "$ROOT_DIR"

run_cmd() {
    if [[ "$DRY_RUN" == "1" ]]; then
        printf '[DRY RUN] %q ' "$@"
        printf '\n'
    else
        "$@"
    fi
}

drop_record() {
    local sub_id="$1"
    local ses_id="$2"
    local record_dir="sub-${sub_id}/ses-${ses_id}"

    if [[ -d "$record_dir" ]]; then
        echo "[DROP] $record_dir"
        run_cmd rm -rf "$record_dir"
    else
        echo "[SKIP DROP] Missing $record_dir"
    fi
}

rename_record() {
    local old_sub="$1"
    local old_ses="$2"
    local new_sub="$3"
    local new_ses="$4"

    local old_sub_dir="sub-${old_sub}"
    local old_ses_dir="${old_sub_dir}/ses-${old_ses}"
    local new_sub_dir="sub-${new_sub}"
    local new_ses_dir="${new_sub_dir}/ses-${new_ses}"

    if [[ ! -d "$old_ses_dir" ]]; then
        echo "[SKIP RENAME] Missing $old_ses_dir -> $new_ses_dir"
        return
    fi

    if [[ "$old_ses_dir" != "$new_ses_dir" && -e "$new_ses_dir" ]]; then
        echo "[ERROR] Target already exists: $new_ses_dir" >&2
        echo "        Resolve this before renaming $old_ses_dir." >&2
        exit 1
    fi

    echo "[RENAME] $old_ses_dir -> $new_ses_dir"

    while IFS= read -r -d '' file_path; do
        local dir_name
        local base_name
        local new_base
        dir_name="$(dirname "$file_path")"
        base_name="$(basename "$file_path")"
        new_base="${base_name//sub-${old_sub}/sub-${new_sub}}"
        new_base="${new_base//ses-${old_ses}/ses-${new_ses}}"

        if [[ "$base_name" != "$new_base" ]]; then
            run_cmd mv "$file_path" "${dir_name}/${new_base}"
        fi
    done < <(find "$old_ses_dir" -type f -print0)

    if [[ "$old_ses_dir" != "$new_ses_dir" ]]; then
        run_cmd mkdir -p "$new_sub_dir"
        run_cmd mv "$old_ses_dir" "$new_ses_dir"
    fi
}

# Dropping rules from check_questionare_names.ipynb:
# records_to_drop = [
#     ("132", "baseline"),
#     ("328", "baseline"),
# ]
drop_record "132" "baseline"
drop_record "328" "baseline"

# Mapping rules from check_questionare_names.ipynb:
# (current_ID, current_visit) -> (new_ID, new_visit)
rename_record "25011615385104" "baseline"  "104" "baseline"
rename_record "25033110523111" "baseline"  "111" "baseline"
rename_record "132"            "baseline1" "132" "baseline"
rename_record "26041410095139" "T6"        "139" "T6"
rename_record "141"            "baseline1" "141" "T12"
rename_record "26042410014153" "baseline"  "153" "baseline"
rename_record "304"            "baseline1" "304" "repeatbaseline"
rename_record "326"            "T12"       "325" "T12"
rename_record "326"            "T121"      "326" "T12"
rename_record "25112414482328" "baseline"  "328" "baseline"
