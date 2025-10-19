#!/bin/bash
# SpectreNetlister: Generate a flattened Spectre netlist straight from the design hierarchy.


# Print script usage information
usage() {
    echo "Usage: $0 -top <lib>.<cell>:<view> [-cdslib <cdslib>] [-rundir <rundir>] [-clean] [-h | --help]"
    echo
    echo "Options:"
    echo "  -top       <lib>.<cell>:<view>  (Required) Specify the library, cell, and view for netlisting."
    echo "  -cdslib    <cdslib>             Path to cds.lib file, should be findable by CSF if not specified."
    echo "  -rundir    <rundir>             Directory where netlisting will be run. (default: ./SpectreNetlister.d)"
    echo "  -clean                          Clean the run directory before execution."
    echo "  -h, --help                      Show this help message and exit."
    exit 0
}

# Parse and validate input arguments
parse_args() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -top)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    TOP=$2
                    shift 2
                else
                    echo "Error: Missing value for -top parameter."
                    usage
                fi
                ;;
            -cdslib)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    CDSLIB=$2
                    shift 2
                else
                    echo "Error: Missing value for -cdslib parameter."
                    usage
                fi
                ;;
            -rundir)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    RUNDIR=$2
                    shift 2
                else
                    echo "Error: Missing value for -rundir parameter."
                    usage
                fi
                ;;
            -out)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    OUT=$2
                    shift 2
                else
                    echo "Error: Missing value for -out parameter."
                    usage
                fi
                ;;
            -clean)
                CLEAN=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                echo "Unknown parameter: $1"
                usage
                ;;
        esac
    done

    # Validate the required -top parameter
    if [[ -z "$TOP" ]]; then
        echo "Error: -top parameter is required."
        usage
    fi

    # Extract lib, cell, and view from the -top parameter
    if [[ "$TOP" =~ ^([a-zA-Z0-9_]+)\.([a-zA-Z0-9_]+):([a-zA-Z0-9_]+)$ ]]; then
        LIB=${BASH_REMATCH[1]}
        CELL=${BASH_REMATCH[2]}
        VIEW=${BASH_REMATCH[3]}
    else
        echo "Error: Invalid format for -top. Expected <lib>.<cell>:<view>"
        usage
    fi

    # Set default rundir if not provided
    RUNDIR=${RUNDIR:-./SpectreNetlister.d}
    OUT=${OUT:-$RUNDIR/$CELL.scs}
}

# Clean and prepare the run directory
prepare_rundir() {
    if [[ "$CLEAN" == "true" && -d "$RUNDIR" ]]; then
        echo "Cleaning directory $RUNDIR..."
        rm -rf "$RUNDIR"
    fi
    mkdir -p "$RUNDIR"
}

# Generate the si.env file
generate_si_env() {
    local si_env_file="$RUNDIR/si.env"
    cat > "$si_env_file" <<EOF
simLibName = "$LIB"
simCellName = "$CELL"
simViewName = "$VIEW"
simSimulator = "spectre"
simViewList = list("spectre" "schematic")
simStopList = list("spectre")
EOF
}

# Generate the .simrc file
generate_simrc() {
    local simrc_file="$RUNDIR/.simrc"
    cat > "$simrc_file" <<EOF
envSetVal("spectre.envOpts" "setTopLevelAsSubckt" 'boolean t)
EOF
    export ossUserSimrc=$simrc_file
}

# Build the netlister command
build_si_command() {
    SI_CMD="si $RUNDIR"
    if [[ -n "$CDSLIB" ]]; then
        SI_CMD+=" -cdslib $CDSLIB"
    fi
    SI_CMD+=" -batch -command nl"
}

# Run the netlisting process
run_netlisting() {
    echo "Running netlisting process..."
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

    eval "$SI_CMD" |& tee $RUNDIR/siOut.log
    local exit_code=${PIPESTATUS[0]}

    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    if [[ $exit_code -eq 0 ]]; then
        echo "Netlisting completed successfully."
    else
        echo "Netlisting failed. Check $RUNDIR/siOut.log for details."
        exit 1
    fi
}

post_processing() {
  cat "$RUNDIR/netlistHeader" "$RUNDIR/netlist" "$RUNDIR/netlistFooter" > $OUT
}

# Display configuration summary
display_config() {
    echo "Configuration:"
    echo "  Library: $LIB"
    echo "  Cell: $CELL"
    echo "  View: $VIEW"
    echo "  Run Directory: $RUNDIR"
    echo "  Output netlist: $OUT"
    echo "  Clean Directory: ${CLEAN:-false}"
    echo "  CDSLIB Path: ${CDSLIB:-Not provided -> CSF}"
}


# Main script logic
parse_args "$@"
prepare_rundir
generate_si_env
generate_simrc
build_si_command
display_config
run_netlisting
post_processing
