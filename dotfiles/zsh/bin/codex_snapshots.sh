#!/bin/bash

# Codex Backup Script with Grandfather-Father-Son Rotation
# Author: Generated backup script
# Description: Creates compressed backups with GFS retention policy

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ============================================================================
# CONFIGURATION
# ============================================================================

# Source and destination paths
SOURCE_DIR="/Users/pbuell/Google Drive/My Drive/Resources/Codex"
BACKUP_BASE_DIR="/Users/pbuell/Google Drive/My Drive/Archive/Backups/Snapshots"
TEMP_DIR="/tmp/codex_backup_$$"
LOG_FILE="$BACKUP_BASE_DIR/backup.log"

# Backup naming
BACKUP_PREFIX="Codex"
DATE_FORMAT="%Y-%m-%d"
DATETIME_FORMAT="%Y-%m-%d_%H:%M:%S"

# Retention policy (GFS)
DAILY_RETENTION=7      # Keep 7 daily backups
WEEKLY_RETENTION=4     # Keep 4 weekly backups
MONTHLY_RETENTION=12   # Keep 12 monthly backups

# Safety settings
MIN_FREE_SPACE_GB=1    # Minimum free space required (GB)
MAX_BACKUP_SIZE_GB=5   # Alert if backup exceeds this size (GB)

# Email settings (optional - set EMAIL_TO to enable notifications)
EMAIL_TO=""            # Set to your email for failure notifications
EMAIL_SUBJECT="Codex Backup"

# ============================================================================
# FUNCTIONS
# ============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date +"$DATETIME_FORMAT")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

log_info() {
    log "INFO" "$@"
}

log_warn() {
    log "WARN" "$@"
}

log_error() {
    log "ERROR" "$@"
}

cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
        log_info "Cleaned up temporary directory: $TEMP_DIR"
    fi
}

send_notification() {
    local subject="$1"
    local message="$2"

    if [[ -n "$EMAIL_TO" ]] && command -v mail >/dev/null 2>&1; then
        echo "$message" | mail -s "$subject" "$EMAIL_TO"
        log_info "Email notification sent to $EMAIL_TO"
    fi
}

check_prerequisites() {
    log_info "Performing pre-flight checks..."

    # Check if source directory exists
    if [[ ! -d "$SOURCE_DIR" ]]; then
        log_error "Source directory does not exist: $SOURCE_DIR"
        exit 1
    fi

    # Check if source directory is readable
    if [[ ! -r "$SOURCE_DIR" ]]; then
        log_error "Source directory is not readable: $SOURCE_DIR"
        exit 1
    fi

    # Create backup directory if it doesn't exist
    if [[ ! -d "$BACKUP_BASE_DIR" ]]; then
        mkdir -p "$BACKUP_BASE_DIR"
        log_info "Created backup directory: $BACKUP_BASE_DIR"
    fi

    # Check if backup directory is writable
    if [[ ! -w "$BACKUP_BASE_DIR" ]]; then
        log_error "Backup directory is not writable: $BACKUP_BASE_DIR"
        exit 1
    fi

    # Create log file if it doesn't exist
    touch "$LOG_FILE" 2>/dev/null || {
        log_error "Cannot create log file: $LOG_FILE"
        exit 1
    }

    # Check available disk space
    local available_space
    available_space=$(df "$BACKUP_BASE_DIR" | tail -1 | awk '{print $4}')
    available_space=$((available_space / 1024 / 1024))  # Convert to GB

    if [[ $available_space -lt $MIN_FREE_SPACE_GB ]]; then
        log_error "Insufficient disk space. Available: ${available_space}GB, Required: ${MIN_FREE_SPACE_GB}GB"
        exit 1
    fi

    log_info "Available disk space: ${available_space}GB"

    # Create temp directory
    mkdir -p "$TEMP_DIR"

    log_info "Pre-flight checks completed successfully"
}

estimate_backup_size() {
    local source="$1"
    log_info "Estimating backup size..."

    local size_kb
    size_kb=$(du -sk "$source" | cut -f1)
    local size_gb=$((size_kb / 1024 / 1024))

    log_info "Estimated backup size: ${size_gb}GB"

    if [[ $size_gb -gt $MAX_BACKUP_SIZE_GB ]]; then
        log_warn "Backup size (${size_gb}GB) exceeds threshold (${MAX_BACKUP_SIZE_GB}GB)"
    fi
}

create_backup() {
    local date_str="$1"
    local temp_backup="$TEMP_DIR/${date_str}-${BACKUP_PREFIX}.tgz"
    local final_backup="$BACKUP_BASE_DIR/${date_str}-${BACKUP_PREFIX}.tgz"

    log_info "Starting backup creation..."
    log_info "Source: $SOURCE_DIR"
    log_info "Temporary file: $temp_backup"
    log_info "Final destination: $final_backup"

    # Create backup in temp location first (atomic operation)
    if tar -czf "$temp_backup" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")" 2>/dev/null; then
        log_info "Backup archive created successfully"
    else
        log_error "Failed to create backup archive"
        return 1
    fi

    # Verify backup integrity
    if tar -tzf "$temp_backup" >/dev/null 2>&1; then
        log_info "Backup integrity verified"
    else
        log_error "Backup integrity check failed"
        return 1
    fi

    # Get backup file size
    local backup_size
    backup_size=$(stat -f%z "$temp_backup" 2>/dev/null || stat -c%s "$temp_backup" 2>/dev/null)
    backup_size=$((backup_size / 1024 / 1024))  # Convert to MB
    log_info "Backup file size: ${backup_size}MB"

    # Move to final location (atomic operation)
    if mv "$temp_backup" "$final_backup"; then
        log_info "Backup moved to final location successfully"
        echo "$final_backup"  # Return the path
        return 0
    else
        log_error "Failed to move backup to final location"
        return 1
    fi
}

cleanup_old_backups() {
    log_info "Starting backup cleanup (GFS retention policy)..."

    cd "$BACKUP_BASE_DIR" || {
        log_error "Cannot change to backup directory"
        return 1
    }

    # Get all backup files sorted by date (newest first)
    local all_backups
    all_backups=$(find . -name "*-${BACKUP_PREFIX}.tgz" -type f -printf "%T@ %p\n" 2>/dev/null | sort -nr | cut -d' ' -f2- || \
                  find . -name "*-${BACKUP_PREFIX}.tgz" -type f -exec stat -f "%m %N" {} \; 2>/dev/null | sort -nr | cut -d' ' -f2-)

    if [[ -z "$all_backups" ]]; then
        log_info "No backup files found for cleanup"
        return 0
    fi

    # Arrays to track backups to keep
    local -a keep_backups=()
    local -a daily_candidates=()
    local -a weekly_candidates=()
    local -a monthly_candidates=()

    # Current date for calculations
    local current_date
    current_date=$(date +%s)

    # Process each backup file
    while IFS= read -r backup_file; do
        [[ -z "$backup_file" ]] && continue

        # Extract date from filename (format: YYYY-MM-DD-Codex.tgz)
        local backup_date_str
        backup_date_str=$(basename "$backup_file" | sed -E 's/^([0-9]{4}-[0-9]{2}-[0-9]{2})-.*$/\1/')

        # Convert to epoch time for calculations
        local backup_epoch
        backup_epoch=$(date -d "$backup_date_str" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$backup_date_str" +%s 2>/dev/null)

        if [[ -z "$backup_epoch" ]]; then
            log_warn "Could not parse date from backup file: $backup_file"
            continue
        fi

        # Calculate age in days
        local age_days=$(( (current_date - backup_epoch) / 86400 ))

        # Categorize backup based on age and retention policy
        if [[ $age_days -le $DAILY_RETENTION ]]; then
            # Keep all recent backups (daily retention period)
            daily_candidates+=("$backup_file")
        elif [[ $age_days -le $((DAILY_RETENTION + WEEKLY_RETENTION * 7)) ]]; then
            # Weekly retention period - keep one per week
            weekly_candidates+=("$backup_file")
        elif [[ $age_days -le $((DAILY_RETENTION + WEEKLY_RETENTION * 7 + MONTHLY_RETENTION * 30)) ]]; then
            # Monthly retention period - keep one per month
            monthly_candidates+=("$backup_file")
        fi
        # Backups older than monthly retention period will be deleted
    done <<< "$all_backups"

    # Keep all daily backups
    log_info "Preserving ${#daily_candidates[@]} daily backups (last $DAILY_RETENTION days)"
    keep_backups+=("${daily_candidates[@]}")

    # Keep one backup per week from weekly candidates
    if [[ ${#weekly_candidates[@]} -gt 0 ]]; then
        log_info "Processing ${#weekly_candidates[@]} weekly backup candidates"
        local -A weeks_seen=()
        local weekly_kept=0

        for backup_file in "${weekly_candidates[@]}"; do
            local backup_date_str
            backup_date_str=$(basename "$backup_file" | sed -E 's/^([0-9]{4}-[0-9]{2}-[0-9]{2})-.*$/\1/')

            # Get week number (ISO week)
            local week_key
            week_key=$(date -d "$backup_date_str" +%Y-W%V 2>/dev/null || date -j -f "%Y-%m-%d" "$backup_date_str" +%Y-W%V 2>/dev/null)

            if [[ -z "${weeks_seen[$week_key]:-}" ]]; then
                weeks_seen[$week_key]=1
                keep_backups+=("$backup_file")
                ((weekly_kept++))
            fi
        done
        log_info "Preserving $weekly_kept weekly backups"
    fi

    # Keep one backup per month from monthly candidates
    if [[ ${#monthly_candidates[@]} -gt 0 ]]; then
        log_info "Processing ${#monthly_candidates[@]} monthly backup candidates"
        local -A months_seen=()
        local monthly_kept=0

        for backup_file in "${monthly_candidates[@]}"; do
            local backup_date_str
            backup_date_str=$(basename "$backup_file" | sed -E 's/^([0-9]{4}-[0-9]{2}-[0-9]{2})-.*$/\1/')

            # Get year-month
            local month_key
            month_key=$(date -d "$backup_date_str" +%Y-%m 2>/dev/null || date -j -f "%Y-%m-%d" "$backup_date_str" +%Y-%m 2>/dev/null)

            if [[ -z "${months_seen[$month_key]:-}" ]]; then
                months_seen[$month_key]=1
                keep_backups+=("$backup_file")
                ((monthly_kept++))
            fi
        done
        log_info "Preserving $monthly_kept monthly backups"
    fi

    # Create associative array of backups to keep for fast lookup
    local -A keep_lookup=()
    for backup in "${keep_backups[@]}"; do
        keep_lookup["$backup"]=1
    done

    # Remove backups not in the keep list
    local deleted_count=0
    while IFS= read -r backup_file; do
        [[ -z "$backup_file" ]] && continue

        if [[ -z "${keep_lookup[$backup_file]:-}" ]]; then
            log_info "Removing old backup: $(basename "$backup_file")"
            rm -f "$backup_file"
            ((deleted_count++))
        fi
    done <<< "$all_backups"

    # Count remaining backups
    local backup_count
    backup_count=$(find . -name "*-${BACKUP_PREFIX}.tgz" -type f | wc -l)
    log_info "Cleanup completed. Deleted: $deleted_count, Remaining: $backup_count backups"
}

main() {
    local start_time
    start_time=$(date +"$DATETIME_FORMAT")

    log_info "=== Codex Backup Started ==="
    log_info "Start time: $start_time"

    # Set up cleanup trap
    trap cleanup EXIT

    # Perform checks
    check_prerequisites
    estimate_backup_size "$SOURCE_DIR"

    # Create backup
    local current_date
    current_date=$(date +"$DATE_FORMAT")

    local backup_file
    if backup_file=$(create_backup "$current_date"); then
        log_info "Backup created successfully: $backup_file"

        # Clean up old backups
        cleanup_old_backups

        local end_time
        end_time=$(date +"$DATETIME_FORMAT")
        log_info "=== Backup Completed Successfully ==="
        log_info "End time: $end_time"

        send_notification "$EMAIL_SUBJECT - Success" "Backup completed successfully at $end_time"

    else
        log_error "Backup failed"
        local end_time
        end_time=$(date +"$DATETIME_FORMAT")
        log_error "=== Backup Failed ==="
        log_error "End time: $end_time"

        send_notification "$EMAIL_SUBJECT - FAILED" "Backup failed at $end_time. Check logs for details."
        exit 1
    fi
}

# ============================================================================
# SCRIPT EXECUTION
# ============================================================================

# Handle command line arguments
case "${1:-}" in
    --dry-run)
        log_info "DRY RUN MODE - No actual backup will be created"
        check_prerequisites
        estimate_backup_size "$SOURCE_DIR"
        log_info "Dry run completed successfully"
        ;;
    --help|-h)
        echo "Usage: $0 [--dry-run] [--help]"
        echo ""
        echo "Options:"
        echo "  --dry-run    Perform checks without creating backup"
        echo "  --help, -h   Show this help message"
        echo ""
        echo "Configuration can be modified at the top of this script."
        ;;
    "")
        main
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
