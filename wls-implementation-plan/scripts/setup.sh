#!/bin/bash
# WLS Automation Setup
# Source this file or add to your .bashrc/.zshrc

# Environment variables (adjust paths as needed)
export WLS_SPEC="${WLS_SPEC:-$HOME/code/github.com/whisker-language-specification-1.0}"
export WLS_TS="${WLS_TS:-$HOME/code/github.com/writewhisker/whisker-editor-web}"
export WLS_LUA="${WLS_LUA:-$HOME/code/github.com/writewhisker/whisker-core}"

# Add scripts to PATH
export PATH="$WLS_SPEC/wls-implementation-plan/scripts:$PATH"

# Convenience function: Execute a WLS stage with Claude
wls() {
  local cmd=$1
  shift

  case "$cmd" in
    stage)
      wls-execute stage "$@"
      ;;
    phase)
      wls-execute phase "$@"
      ;;
    group)
      wls-execute group "$@"
      ;;
    status)
      wls-execute status
      ;;
    help|*)
      wls-execute
      ;;
  esac
}

# Quick alias for the most common operation
alias execute-stage='wls-execute stage'

echo "WLS automation loaded. Commands:"
echo "  wls stage 2.13     # Execute stage 2.13"
echo "  wls phase 3        # List Phase 3 stages"
echo "  wls group E        # Show parallel group setup"
echo "  wls status         # Check completion status"
