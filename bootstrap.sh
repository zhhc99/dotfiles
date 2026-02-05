#!/usr/bin/env bash
#
# 初始化 Linux 环境 (dnf only).
PKGS=(stow git gh keyd iwd ibus-rime)
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

	setup_rime_ice() {
        local rime_dir=$(eval echo "~${SUDO_USER}/.config/ibus/rime")
        if [ ! -d "${rime_dir}/.git" ]; then
			log "Removing Rime default configs and Cloning Rime Ice..."
            rm -rf "${rime_dir}"
            sudo -u "${SUDO_USER}" git clone --depth 1 https://github.com/iDvel/rime-ice.git "${rime_dir}"
        fi
    }

	deploy_configs() {
		local real_home=$(eval echo "~${SUDO_USER}")

		log "Removing old symlinks..."
		(cd home && find . -type f) | while read -r f; do
            target="${real_home}/${f#./}"
            if [[ -L "$target" ]]; then
                rm -v "$target" || true
            fi
        done

		(cd system && find . -type f) | while read -r f; do
            target="/${f#./}"
            if [[ -L "$target" ]]; then
                sudo rm -v "$target" || true
            fi
        done

		log "Stowing configs..."
		sudo -u "${SUDO_USER}" stow -v -R --adopt --no-folding -t "${real_home}" home
		stow -v -R --adopt --no-folding -t / system
		echo "💡 Adopted local configs. Use 'git status' to check changes. Use 'git checkout -- .' to revert."
	}

	setup_services() {
		log "Enabling services..."
		for svc in "${SERVICES[@]}"; do
			echo "Enabling ${svc}..."
			systemctl enable --now "${svc}" 2>/dev/null || echo "⚠️  Service ${svc} not found."
		done
		for svc in "${RESTART_SERVICES[@]}"; do
            echo "Restarting ${svc}..."
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
		setup_rime_ice
		deploy_configs
		setup_services

		echo "🎉 Done. Enjoy Linux!"
	}

	main "$@"
}
