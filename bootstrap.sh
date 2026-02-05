#!/usr/bin/env bash
#
# 初始化 Linux 环境 (dnf only).
PKGS=(stow git gh keyd iwd)
SERVICES=(keyd iwd)
RESTART_SERVICES=(NetworkManager)

{
	set -euo pipefail

	err() { echo "❗ Error: $*" >&2; exit 1; }
	log() { echo "📜 $*"; }

	install_pkgs() {
        log "Installing dependencies..."
        command -v dnf &>/dev/null || err "dnf not found."
        dnf install -y "${PKGS[@]}"
    }

	deploy_configs() {
		log "Stowing configs..."
		local real_home=$(eval echo "~${SUDO_USER}")
		sudo -u "${SUDO_USER}" stow -v -R --adopt -t "${real_home}" home
		stow -v -R --adopt -t / system
		echo "⚠️ Adopted local configs. Use 'git status' to check changes. Use 'git checkout -- .' to revert."
	}

	setup_services() {
		log "Enabling services..."
		for svc in "${SERVICES[@]}"; do
			systemctl enable --now "${svc}" 2>/dev/null || echo "⚠️  Service ${svc} not found."
		done
		for svc in "${RESTART_SERVICES[@]}"; do
            log "Restarting ${svc}..."
            systemctl restart "${svc}" 2>/dev/null || true
        done
	}

	main() {
		if [[ $EUID -ne 0 ]]; then
			echo "🛡️ Need sudo powers to install..."
			exec sudo bash "$0" "$@"
		fi

		if [[ -z "${SUDO_USER:-}" ]]; then
            err "Please run via sudo (e.g. 'sudo ./bootstrap.sh'), so script finds real user 🥺"
        fi

		cd "$(dirname "$0")"
		install_pkgs
		deploy_configs
		setup_services

		echo "🎉 Done. Enjoy Linux!"
	}

	main "$@"
}
