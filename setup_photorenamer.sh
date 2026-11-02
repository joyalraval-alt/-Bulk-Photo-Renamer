#!/bin/bash
# ============================================================
#  STARTER KIT – L47 Bulk Photo Renamer
#  Student: JOYAL RAVAL  Roll: H37  Div: G
#  Run:  bash setup_photorenamer.sh
#  It creates ~/linux_project/photorenamer with folders, sample data and
#  EMPTY script files with TODO comments. You write all the code yourself.
# ============================================================
P="$HOME/linux_project/photorenamer"
if [ -d "$P" ]; then echo "Folder $P already exists. Rename or delete it first."; exit 1; fi
mkdir -p "$P"/lib "$P"/data "$P"/reports "$P"/backups "$P"/logs
cd "$P" || exit 1

# sample folder: data/photos
mkdir -p 'data/photos'
for k in $(seq 1 8); do echo "Sample line $k" > 'data/photos'/sample_$k.txt; done

cat > lib/functions.sh <<'KIT_FUNCS'
#!/bin/bash
# lib/functions.sh – Bulk Photo Renamer
# Write ALL functions here. main.sh loads this file with: source lib/functions.sh
DATA="data/photos"

LOG="logs/activity.log"

# TODO: log  -> write one line "date time | message" into $LOG
#        hint: date, echo, >>
log() {
    :
}

# TODO: check_data -> if $DATA does not exist, print a message and return 1
#        hint: file test operators (-e, -f, -d)
check_data() {
    :
}

# TODO: show_help -> print how to use ./main.sh, ./main.sh --help, --backup, --cron
show_help() {
    echo "TODO: write the help text"
}

# TODO: view_data -> show the data file with line numbers (or list the folder)
#        hint: cat -n, more, ls -l
view_data() {
    echo "TODO: show the data"
}

# TODO: do_backup -> create backups/data_<date_time>.tar.gz of the data/ folder
#        hint: tar -czf, date +%Y%m%d_%H%M%S, du -h
do_backup() {
    echo "TODO: make a backup"
}

# TODO: view_log -> show the last 15 lines of $LOG
#        hint: tail
view_log() {
    echo "TODO: show the log"
}

# ------------------------------------------------------------
# FEATURE 1: Preview new names
# Commands you can use: for, mv, printf %03d, date -r, arrays
# Hints (see Step 5 of your guide):
#   - Your data is a folder (data/photos). Use a for loop over the files inside it.
#   - Use the commands from your list on each file (for, mv, printf %03d, date -r, arrays).
#   - Print a clear result for the user and write one line to the activity log.
# ------------------------------------------------------------
feature_1() {
    echo "TODO: Preview new names"
}

# ------------------------------------------------------------
# FEATURE 2: Rename with prefix_date_counter
# Commands you can use: for, mv, printf %03d, date -r, arrays
# Hints (see Step 6 of your guide):
#   - Your data is a folder (data/photos). Use a for loop over the files inside it.
#   - Use the commands from your list on each file (for, mv, printf %03d, date -r, arrays).
#   - Print a clear result for the user and write one line to the activity log.
# ------------------------------------------------------------
feature_2() {
    echo "TODO: Rename with prefix_date_counter"
}

# ------------------------------------------------------------
# FEATURE 3: Rename by modified date
# Commands you can use: for, mv, printf %03d, date -r, arrays
# Hints (see Step 7 of your guide):
#   - Your data is a folder (data/photos). Use a for loop over the files inside it.
#   - Use the commands from your list on each file (for, mv, printf %03d, date -r, arrays).
#   - Print a clear result for the user and write one line to the activity log.
# ------------------------------------------------------------
feature_3() {
    echo "TODO: Rename by modified date"
}

# ------------------------------------------------------------
# FEATURE 4: Save an undo log
# Commands you can use: for, mv, printf %03d, date -r, arrays
# Hints (see Step 8 of your guide):
#   - Your data is a folder (data/photos). Use a for loop over the files inside it.
#   - Use the commands from your list on each file (for, mv, printf %03d, date -r, arrays).
#   - Print a clear result for the user and write one line to the activity log.
# ------------------------------------------------------------
feature_4() {
    echo "TODO: Save an undo log"
}

# ------------------------------------------------------------
# FEATURE 5: Undo renames
# Commands you can use: for, mv, printf %03d, date -r, arrays
# Hints (see Step 9 of your guide):
#   - Your data is a folder (data/photos). Use a for loop over the files inside it.
#   - Use the commands from your list on each file (for, mv, printf %03d, date -r, arrays).
#   - Print a clear result for the user and write one line to the activity log.
# ------------------------------------------------------------
feature_5() {
    echo "TODO: Undo renames"
}

# ------------------------------------------------------------
# CRON TASK: Every day at 11 PM, rename new photos in the incoming folder automatically
# This runs when crontab calls:  ./main.sh --cron
# Write the output into reports/ or a file, and log it.
# ------------------------------------------------------------
cron_task() {
    echo "TODO: Every day at 11 PM, rename new photos in the incoming folder automatically"
}
KIT_FUNCS

cat > main.sh <<'KIT_MAIN'
#!/bin/bash
# main.sh – L47 Bulk Photo Renamer
# YOUR TASK: build the menu program in this file (Step 3 of your guide).
cd "$(dirname "$0")" || exit 1
source lib/functions.sh

# TODO 1: command-line arguments (use $1 and case...esac)
#   ./main.sh --help    -> call show_help, then exit
#   ./main.sh --backup  -> call do_backup, then exit
#   ./main.sh --cron    -> call cron_task, then exit

# TODO 2: menu (use a while loop + read + case...esac)
#   Show a title, then these options, read the choice and call the function:
#     1) Preview new names
#     2) Rename with prefix_date_counter
#     3) Rename by modified date
#     4) Save an undo log
#     5) Undo renames
#     6) View data            -> view_data
#     7) Backup data          -> do_backup
#     8) View activity log    -> view_log
#     0) Exit                 -> say bye and stop the loop (break)
#   Any other choice -> print "Invalid choice"

echo "Menu not built yet. Open main.sh and complete TODO 1 and TODO 2."
KIT_MAIN

cat > README.md <<'KIT_README'
# L47 – Bulk Photo Renamer

**Student:** JOYAL RAVAL | **Roll:** H37 | **Division:** G | **Enrollment:** 24004501210364

## Problem
Rename many files at once with a pattern, preview and undo.

## Who will use it
Photographers renaming hundreds of photos.

## Folder structure
(explain what each file and folder is for)

## Features
1. Preview new names
2. Rename with prefix_date_counter
3. Rename by modified date
4. Save an undo log
5. Undo renames

## How to run
(write the commands to run your project)

## My crontab line and what it means
(write your crontab line and explain the 5 time fields)

## Commands I used and why
(list the commands and where you used them)

## What I learned
(write 3-5 lines)
KIT_README

chmod +x main.sh
echo
echo "Starter kit ready!  Folder: $P"
ls -R "$P"
echo
echo "Next:  cd ~/linux_project/photorenamer  and follow your project guide."
