#!/bin/bash

#==============================================================================
# Docker | Docker Compose - Installation Script
# 
# This script automates the complete installation of the latest version of the
# Docker Engine and Docker Compose on Ubuntu 25.04+ and Fedora 42+.
# It ensures that the system is ready for running Docker containers, including
# setting up the necessary repositories, installing dependencies, and configuring
# Docker to run without requiring root privileges.
#
# Supported Systems:
# - Ubuntu 24.04 or later
# - Fedora 42 or later
#
# Author: Noé de Lima Bezerra
# Version: 1.2.0
# Date: 2025-07-31
#==============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Global variables for OS detection
DISTRO=""
DISTRO_VERSION=""

#==============================================================================
# Utility Functions
#==============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_fatal() {
    echo -e "${RED}[FATAL]${NC} $*" >&2
    exit 1
}

#==============================================================================
# OS Detection
#==============================================================================

detect_os() {
    log_info "Detecting operating system..."
    
    if [[ ! -f /etc/os-release ]]; then
        log_fatal "Cannot determine OS version. This script requires Ubuntu 25.04+ or Fedora 42+."
    fi
    
    source /etc/os-release
    DISTRO="$ID"
    DISTRO_VERSION="$VERSION_ID"
    
    case "$DISTRO" in
        "ubuntu")
            if [[ $(echo "$DISTRO_VERSION >= 24.04" | bc -l) -eq 1 ]] 2>/dev/null || [[ "$DISTRO_VERSION" == "24.04" ]]; then
                log_success "Detected compatible Ubuntu version: $DISTRO_VERSION"
            else
                log_fatal "Unsupported Ubuntu version: $DISTRO_VERSION. Minimum required: 24.04"
            fi
            ;;
        "fedora")
            if [[ "$DISTRO_VERSION" -ge 42 ]]; then
                log_success "Detected compatible Fedora version: $DISTRO_VERSION"
            else
                log_fatal "Unsupported Fedora version: $DISTRO_VERSION. Minimum required: 42"
            fi
            ;;
        *)
            log_fatal "Unsupported distribution: $DISTRO $DISTRO_VERSION. Only Ubuntu 25.04+ and Fedora 42+ are supported."
            ;;
    esac
}

#==============================================================================
# Docker Installation Functions
#==============================================================================

remove_old_docker() {
    log_info "Removing old Docker installations..."
    
    case "$DISTRO" in
        "ubuntu")
            sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
            ;;
        "fedora")
            sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine 2>/dev/null || true
            ;;
    esac
    
    log_success "Old Docker installations removed."
}

install_dependencies() {
    log_info "Installing dependencies..."
    
    case "$DISTRO" in
        "ubuntu")
            sudo apt-get update
            sudo apt-get install -y ca-certificates curl gnupg bc
            ;;
        "fedora")
            sudo dnf update -y
            sudo dnf install -y ca-certificates curl gnupg bc dnf-plugins-core
            ;;
    esac
    
    log_success "Dependencies installed."
}

setup_docker_repository() {
    log_info "Setting up Docker repository..."
    
    case "$DISTRO" in
        "ubuntu")
            sudo install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            
            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
              $(lsb_release -cs) stable" | \
              sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            sudo apt-get update
            ;;
        "fedora")
            sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
            ;;
    esac
    
    log_success "Docker repository configured."
}

install_docker() {
    log_info "Installing Docker Engine..."
    
    case "$DISTRO" in
        "ubuntu")
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker compose-plugin
            ;;
        "fedora")
            sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker compose-plugin
            ;;
    esac
    
    log_success "Docker Engine installed."
}

configure_docker() {
    log_info "Configuring Docker..."
    
    # Add current user to docker group
    sudo usermod -aG docker "$USER"
    
    # Enable and start Docker service
    sudo systemctl enable docker
    sudo systemctl start docker
    
    log_success "Docker configured and started."
}

verify_installation() {
    log_info "Verifying Docker installation..."
    
    # Check Docker version
    docker --version
    
    # Test Docker installation (as sudo since user needs to log out/in for group membership)
    if sudo docker run hello-world; then
        log_success "Docker installation verified successfully!"
        log_info "Please log out and log back in to use Docker without sudo."
    else
        log_error "Docker installation verification failed."
        return 1
    fi
}

#==============================================================================
# Main Installation Process
#==============================================================================

main() {
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                              ║"
    echo "║    🐳  Docker & Docker Compose Installation Script                          ║"
    echo "║                                                                              ║"
    echo "║    Supports Ubuntu 25.04+ and Fedora 42+                                   ║"
    echo "║                                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        log_fatal "This script should not be run as root. Please run as a regular user with sudo privileges."
    fi
    
    # Check sudo privileges
    if ! sudo -n true 2>/dev/null; then
        log_fatal "This script requires sudo privileges. Please ensure your user can run sudo commands."
    fi
    
    detect_os
    remove_old_docker
    install_dependencies
    setup_docker_repository
    install_docker
    configure_docker
    verify_installation
    
    echo
    log_success "Docker installation completed successfully!"
    log_info "You may need to log out and log back in to use Docker without sudo."
}

# Run main function
main "$@"
