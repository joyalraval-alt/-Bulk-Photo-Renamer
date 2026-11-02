mkdir -p ~/linux_project
cd ~/linux_project
pwd

/home/your-username/linux_project

cd ~/linux_project
nano setup_photorenamer.sh
------------------------------------------------------------------------------------------------------------
#!/bin/bash

P="$HOME/linux_project/photorenamer"

if [ -d "$P" ]; then
    echo "Project folder already exists: $P"
    echo "Please do not run setup again."
    exit 1
fi

mkdir -p "$P"/{lib,data/photos,reports,backups,logs,incoming}

cd "$P" || exit 1

# Create 20 sample files for testing
for i in $(seq 1 20); do
    printf "Sample photo file %s\n" "$i" > "data/photos/photo_$i.jpg"
done

# Create the activity log
touch logs/activity.log

# Create the undo log
touch logs/undo.log

# Create the main script
cat > main.sh <<'MAIN'
#!/bin/bash

cd "$(dirname "$0")" || exit 1
source lib/functions.sh

case "${1:-}" in
    --help)
        show_help
        exit 0
        ;;
    --backup)
        do_backup
        exit $?
        ;;
    --cron)
        cron_task
        exit $?
        ;;
esac

while true; do
    echo
    echo "=================================="
    echo "       BULK PHOTO RENAMER"
    echo "=================================="
    echo "1. Preview new names"
    echo "2. Rename with prefix and counter"
    echo "3. Rename by modified date"
    echo "4. Save an undo log"
    echo "5. Undo renames"
    echo "6. View data"
    echo "7. Backup data"
    echo "8. View activity log"
    echo "0. Exit"
    echo "=================================="

    read -r -p "Enter your choice: " choice

    case "$choice" in
        1) feature_1 ;;
        2) feature_2 ;;
        3) feature_3 ;;
        4) feature_4 ;;
        5) feature_5 ;;
        6) view_data ;;
        7) do_backup ;;
        8) view_log ;;
        0)
            echo "Thank you for using Bulk Photo Renamer!"
            break
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done
MAIN

chmod +x main.sh

echo "Project folders and main.sh created successfully!"
echo "Location: $P"
MAIN
----------------------------------------------------------------------------------------------------------------
chmod +x setup_photorenamer.sh
./setup_photorenamer.sh

cd ~/linux_project/photorenamer
nano lib/functions.sh

------------------------------------------------------------------------------------------------------------------
#!/bin/bash

DATA="data/photos"
LOG="logs/activity.log"
UNDO="logs/undo.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $*" >> "$LOG"
}

check_data() {
    if [ ! -d "$DATA" ]; then
        echo "Error: Data folder does not exist."
        return 1
    fi
    return 0
}

show_help() {
    echo "Bulk Photo Renamer"
    echo "Usage:"
    echo "./main.sh       Open menu"
    echo "./main.sh --help   Show help"
    echo "./main.sh --backup Create a backup"
    echo "./main.sh --cron   Run automatic renaming"
}

view_data() {
    check_data || return 1
    echo "Files in $DATA:"
    ls -lh "$DATA"
    log "Viewed photo data"
}

do_backup() {
    local backup_file
    mkdir -p backups
    backup_file="backups/data_$(date +%Y%m%d_%H%M%S).tar.gz"

    if tar -czf "$backup_file" data/; then
        echo "Backup created: $backup_file"
        log "Backup created: $backup_file"
    else
        echo "Backup failed."
        return 1
    fi
}

view_log() {
    touch "$LOG"
    echo "Recent activity:"
    tail -n 15 "$LOG"
}

feature_1() {
    check_data || return 1

    local i=1 file ext newname
    shopt -s nullglob

    echo "Preview of new filenames:"
    for file in "$DATA"/*; do
        [ -f "$file" ] || continue
        ext="${file##*.}"
        printf -v newname "trip_%s_%03d.%s" "$(date +%Y%m%d)" "$i" "$ext"
        printf '%s -> %s\n' "$(basename "$file")" "$newname"
        ((i++))
    done

    shopt -u nullglob
    log "Previewed new filenames"
}

feature_2() {
    check_data || return 1

    local prefix i file ext newname
    read -r -p "Enter filename prefix (example: trip): " prefix

    if [[ ! "$prefix" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Invalid prefix. Use letters, numbers, _ or -."
        return 1
    fi

    local -a files=()
    shopt -s nullglob
    for file in "$DATA"/*; do
        [ -f "$file" ] && files+=("$file")
    done
    shopt -u nullglob

    i=1
    for file in "${files[@]}"; do
        ext="${file##*.}"
        printf -v newname "%s_%s_%03d.%s" \
            "$prefix" "$(date +%Y%m%d)" "$i" "$ext"

        if [ -e "$DATA/$newname" ]; then
            echo "Skipped: $newname already exists."
            continue
        fi

        printf '%s\t%s\n' "$(basename "$file")" "$newname" >> "$UNDO"

        if mv -- "$file" "$DATA/$newname"; then
            echo "$(basename "$file") -> $newname"
        else
            echo "Failed to rename $(basename "$file")"
        fi
        ((i++))
    done

    log "Renamed files with prefix $prefix"
}

feature_3() {
    check_data || return 1

    local file ext stamp newname i
    local -a files=()

    shopt -s nullglob
    for file in "$DATA"/*; do
        [ -f "$file" ] && files+=("$file")
    done
    shopt -u nullglob

    i=1
    for file in "${files[@]}"; do
        ext="${file##*.}"
        stamp="$(date -r "$file" +%Y%m%d)"

        printf -v newname "photo_%s_%03d.%s" "$stamp" "$i" "$ext"

        if [ -e "$DATA/$newname" ]; then
            echo "Skipped: $newname already exists."
            continue
        fi

        printf '%s\t%s\n' "$(basename "$file")" "$newname" >> "$UNDO"

        if mv -- "$file" "$DATA/$newname"; then
            echo "$(basename "$file") -> $newname"
        else
            echo "Failed to rename $(basename "$file")"
        fi
        ((i++))
    done

    log "Renamed files by modified date"
}

feature_4() {
    if [ ! -s "$UNDO" ]; then
        echo "No rename history available."
        return
    fi

    echo "Saved rename history:"
    cat -n "$UNDO"
    log "Viewed saved undo history"
}

feature_5() {
    if [ ! -s "$UNDO" ]; then
        echo "No rename history available."
        return
    fi

    local original renamed current
    local -a lines=()

    mapfile -t lines < "$UNDO"
    : > "$UNDO"

    local i
    for ((i=${#lines[@]}-1; i>=0; i--)); do
        IFS=$'\t' read -r original renamed <<< "${lines[$i]}"

        if [ -z "$original" ] || [ -z "$renamed" ]; then
            continue
        fi

        if [ -e "$DATA/$renamed" ] && [ ! -e "$DATA/$original" ]; then
            if mv -- "$DATA/$renamed" "$DATA/$original"; then
                echo "$renamed -> $original"
            else
                echo "Could not undo $renamed"
                printf '%s\t%s\n' "$original" "$renamed" >> "$UNDO"
            fi
        elif [ -e "$DATA/$renamed" ]; then
            echo "Cannot restore $original: original name already exists."
            printf '%s\t%s\n' "$original" "$renamed" >> "$UNDO"
        fi
    done

    log "Attempted to undo renames"
}

cron_task() {
    local file ext stamp newname
    local -a files=()

    mkdir -p incoming
    touch logs/cron.log

    shopt -s nullglob
    for file in incoming/*; do
        [ -f "$file" ] && files+=("$file")
    done
    shopt -u nullglob

    if [ "${#files[@]}" -eq 0 ]; then
        echo "No new files in incoming folder."
        log "Cron task ran: no incoming files"
        return 0
    fi

    mkdir -p "$DATA"

    for file in "${files[@]}"; do
        ext="${file##*.}"
        stamp="$(date -r "$file" +%Y%m%d)"
        newname="incoming_${stamp}_$(basename "$file")"

        if [ -e "$DATA/$newname" ]; then
            echo "Skipped duplicate: $newname"
            continue
        fi

        if mv -- "$file" "$DATA/$newname"; then
            echo "Imported: $newname"
        else
            echo "Failed to import $(basename "$file")"
        fi
    done

    log "Cron task processed incoming files"
}
---------------------------------------------------------------------------------------------------------------
cd ~/linux_project/photorenamer
chmod +x main.sh
bash -n main.sh
bash -n lib/functions.sh

./main.sh

./main.sh --help

./main.sh --cron

ls -lh backups/

tar -tzf "$(ls -1t backups/*.tar.gz | head -n 1)"

cat logs/activity.log

cat logs/undo.log

ls -R

----------------------------------------------------------------------------------------------------------------
sudo service cron start

crontab -e

0 23 * * * /bin/bash /home/joyal_raval/linux_project/photorenamer/main.sh --cron >> /home/joyal/linux_project/photorenamer/logs/cron.log 2>&1

crontab -l

cat ~/linux_project/photorenamer/logs/cron.log

echo "Test incoming file" > ~/linux_project/photorenamer/incoming/test.jpg

cd ~/linux_project/photorenamer
./main.sh --cron

ls -l incoming/
ls -l data/photos/

cd ~/linux_project

tar -czf H37_L47_photorenamer.tar.gz photorenamer/

tar -tzf H37_L47_photorenamer.tar.gz

ls -lh H37_L47_photorenamer.tar.gz

~/linux_project/H37_L47_photorenamer.tar.gz

---------------------------------------------------------------------------------------------------
cd ~/linux_project/photorenamer

./main.sh
