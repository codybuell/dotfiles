#!/bin/bash
# wifi-uc-healthcheck.sh — one-shot health check + auto-repair for Wi-Fi /
# Universal Control problems between a pair of Apple silicon Macs.
#
# Checks, layer by layer:
#   1. Wi-Fi radio: channel (DFS?), width, signal
#   2. Wi-Fi link stability: en0 link drops (last 3h)
#   3. Routing: Wi-Fi service order, duplicate LAN interfaces
#   4. VPN/DNS: default route, WARP, real internet reachability
#   5. Power: womp / powernap / tcpkeepalive (wake churn)
#   6. Bluetooth: powered on, BLE disconnect storm (wedged CoreBluetooth)
#   7. AWDL + Continuity daemons (rapportd/sharingd/useractivityd)
#   8. Universal Control: per-host Disable pref (the silent killer) + MDM allow
#   9. CompanionLink flap (UC peer link interrupts) — the common UC failure
#  10. (optional) peer reachability
#
# HOST is any ssh target (hostname, host alias, or IP) reachable on the LAN.
#
# Usage:
#   ./wifi-uc-healthcheck.sh                     # check THIS machine
#   ./wifi-uc-healthcheck.sh HOST                # check a remote machine over SSH
#   ./wifi-uc-healthcheck.sh --peer HOST         # also ping-test that peer
#   ./wifi-uc-healthcheck.sh --fix               # check, then auto-repair UC/BT failures
#   ./wifi-uc-healthcheck.sh --fix --peer HOST   # repair BOTH this Mac and the peer
#
# --fix actions (only run when a related check FAILs):
#   * UC Disable=1        -> defaults write Disable=false + restart UC daemon
#   * BLE storm / CompanionLink flap -> Bluetooth off/on (requires blueutil on PATH)
#   * NoAWDL / awdl down  -> cycle Wi-Fi + restart Continuity daemons
#   On the peer (if --peer given with --fix), applies the same repairs over SSH.
#
# Exit: 0 = healthy, 1 = at least one FAIL remained.

REMOTE=""; PEER=""; DOFIX=0
while [ $# -gt 0 ]; do
  case "$1" in
    --peer) PEER="$2"; shift 2;;
    --fix)  DOFIX=1; shift;;
    -h|--help) sed -n '2,32p' "$0"; exit 0;;
    -*) echo "unknown flag $1"; exit 2;;
    *) REMOTE="$1"; shift;;
  esac
done

LOG=/usr/bin/log
FAILS=0; WARNS=0
# per-failure flags used to drive --fix
F_UCDISABLE=0; F_BLE=0; F_AWDL=0; F_BT_OFF=0

# run a command locally or on the (primary) remote target
R() { if [ -n "$REMOTE" ]; then ssh -o ConnectTimeout=8 "$REMOTE" "$1"; else bash -c "$1"; fi; }
# run a command on the peer host over ssh
RP() { ssh -o ConnectTimeout=8 "$PEER" "$1"; }

if [ -t 1 ]; then
  c_red=$'\033[31m'; c_grn=$'\033[32m'; c_yel=$'\033[33m'; c_dim=$'\033[2m'; c_bld=$'\033[1m'; c_off=$'\033[0m'
else c_red=; c_grn=; c_yel=; c_dim=; c_bld=; c_off=; fi
pass() { printf "  ${c_grn}PASS${c_off}  %s\n" "$1"; }
warn() { printf "  ${c_yel}WARN${c_off}  %s\n" "$1"; [ -n "$2" ] && printf "        ${c_dim}- %s${c_off}\n" "$2"; WARNS=$((WARNS+1)); }
fail() { printf "  ${c_red}FAIL${c_off}  %s\n" "$1"; [ -n "$2" ] && printf "        ${c_dim}fix: %s${c_off}\n" "$2"; FAILS=$((FAILS+1)); }
hd()   { printf "\n${c_bld}%s${c_off}\n" "$1"; }
num()  { echo "${1:-0}" | tr -dc '0-9'; }   # sanitize a possibly-empty/whitespace count

WHO=$(R 'scutil --get LocalHostName 2>/dev/null; sw_vers -productVersion 2>/dev/null' | tr '\n' ' ')
printf "${c_bld}=== Wi-Fi / Universal Control Health Check ===${c_off}\n"
printf "target: %s  %s\n" "${REMOTE:-localhost}" "$WHO"
printf "time:   %s\n" "$(R 'date "+%Y-%m-%d %H:%M:%S %Z"')"
[ "$DOFIX" = 1 ] && printf "${c_yel}mode:   --fix (will auto-repair failures)${c_off}\n"

# ---------- 1. Wi-Fi radio ----------
hd "1. Wi-Fi radio"
WIFI=$(R 'system_profiler SPAirPortDataType 2>/dev/null | awk "/Current Network Information:/{f=1} f&&/Channel:|Signal|PHY Mode|Transmit Rate/{print} /Other Local/{f=0}"')
CH=$(echo "$WIFI"  | awk -F'[: ]+' '/Channel/{print $3}')
BW=$(echo "$WIFI"  | grep -oE '[0-9]+MHz' | head -1 | tr -d 'MHz')
SIG=$(echo "$WIFI" | grep -oE '\-[0-9]+ dBm' | head -1 | grep -oE '\-[0-9]+')   # first -NN dBm = signal
if [ -z "$CH" ]; then
  fail "Not associated to any Wi-Fi network" "reconnect Wi-Fi; confirm router is up"
else
  if [ "$CH" -ge 52 ] && [ "$CH" -le 144 ]; then
    fail "On DFS channel $CH (${BW}MHz) — radar-avoidance causes random drops" "router 5GHz -> channel 149, 80MHz (non-DFS)"
  elif [ "$(num "$BW")" -ge 160 ]; then
    warn "160MHz width on ch $CH — flakier on Apple silicon" "set 80MHz in router"
  else
    pass "Channel $CH @ ${BW}MHz (non-DFS), signal ${SIG:-?}dBm"
  fi
  if [ -n "$SIG" ] && [ "${SIG#-}" -gt 75 ] 2>/dev/null; then
    warn "Weak signal ${SIG}dBm" "move closer to AP / check antenna"
  fi
fi

# ---------- 2. Link stability ----------
hd "2. Wi-Fi link stability (last 3h)"
DROPS=$(num "$(R "$LOG show --last 3h --predicate 'process == \"configd\"' 2>/dev/null | grep -c 'en0 link INACTIVE'")")
if   [ "$DROPS" -eq 0 ]; then pass "0 link drops in last 3h"
elif [ "$DROPS" -le 2 ]; then warn "$DROPS link drop(s) in 3h (1 may be a router reboot)" "watch; if recurring, recheck channel/roaming-assistant"
else fail "$DROPS link drops in 3h — Wi-Fi is flapping" "check DFS channel (#1), router Roaming Assistant off, interference"; fi

# ---------- 3. Routing ----------
hd "3. Network routing"
ORDER1=$(R 'networksetup -listnetworkserviceorder 2>/dev/null | grep -E "^\(1\)"')
if echo "$ORDER1" | grep -qi "Wi-Fi"; then pass "Wi-Fi is #1 in service order"
else warn "Wi-Fi not #1: ${ORDER1#*) }" "Network -> ... -> Set Service Order -> Wi-Fi to top"; fi
# any RFC1918 address on an enN interface counts as an active LAN interface
LANRE=' (10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.)'
ACTIVE=$(R "ifconfig 2>/dev/null | awk '/^en[0-9]+:/{i=\$1} /inet /{print i\" \"\$2}' | grep -E '$LANRE'")
NIP=$(echo "$ACTIVE" | grep -cE "$LANRE")
if [ "$(num "$NIP")" -gt 1 ]; then warn "Multiple interfaces hold LAN IPs (can cause 'connected but no internet')" "$(echo "$ACTIVE" | tr '\n' ' ')"
else pass "Single LAN interface active"; fi

# ---------- 4. VPN / DNS / internet ----------
hd "4. VPN, DNS & internet"
DEFIF=$(R 'route -n get default 2>/dev/null | awk "/interface:/{print \$2}"')
DNS0=$(R 'scutil --dns 2>/dev/null | awk "/nameserver\[0\]/{print \$3; exit}"')
WARP=$(R 'pgrep -x CloudflareWARP >/dev/null 2>&1 && echo yes || echo no')
if [ "$DEFIF" = "en0" ]; then pass "Default route on en0 (Wi-Fi), DNS=$DNS0"
else warn "Default route on ${DEFIF:-none} (not Wi-Fi), DNS=$DNS0" "if 'no internet', toggle that interface/VPN off"; fi

# --- WARP tunnel health: the recurring 'no internet / connection reset' cause ---
if [ "$WARP" = "yes" ]; then
  # DNS via WARP loopback (127.x) => traffic is IN the tunnel; connection-resets on 172.x = tunnel drop
  case "$DNS0" in 127.*) TUN="in-tunnel";; *) TUN="bypassed";; esac
  RESETS=$(num "$(R "$LOG show --last 15m --predicate 'process == \"CloudflareWARP\" OR process == \"Cloudflare WARP\"' 2>/dev/null | grep -icE 'connection reset|reset by peer|nw_flow.*fail|register.*fail|Disconnected'")")
  REDIAL=$(num "$(R "$LOG show --last 15m --predicate 'process == \"CloudflareWARP\" OR process == \"Cloudflare WARP\"' 2>/dev/null | grep -icE 'path:satisfied_change|nw_flow_connected'")")
  if   [ "$TUN" = bypassed ]; then pass "WARP running but tunnel bypassed (DNS=$DNS0) — traffic direct on en0"
  elif [ "$RESETS" -gt 0 ]; then fail "WARP tunnel unstable ($RESETS drop/reset events in 15m; traffic IN tunnel)" "disconnect WARP for long transfers; review reconnect + split-tunnel policy"
  elif [ "$REDIAL" -gt 40 ]; then warn "WARP re-dialing heavily ($REDIAL flow re-connects/15m)" "tunnel is churning; watch for resets"
  else printf "        ${c_dim}- WARP tunnel up, DNS=$DNS0 ($REDIAL re-connects/15m — normal)${c_off}\n"; fi
fi

# Latency-aware reachability (not just up/down): flags 'barely responsive'
PINGOUT=$(R 'ping -c3 -t5 1.1.1.1 2>/dev/null | awk -F"/" "/round-trip|min\\/avg/{print \$5}"')
if [ -z "$PINGOUT" ]; then fail "No internet (ping 1.1.1.1 failed)" "cycle Wi-Fi, or toggle WARP off/on"
else
  AVG=${PINGOUT%.*}
  if   [ "${AVG:-0}" -lt 60 ];  then pass "Internet reachable (${PINGOUT}ms avg to 1.1.1.1)"
  elif [ "${AVG:-0}" -lt 250 ]; then warn "Internet slow (${PINGOUT}ms avg)" "if barely responsive: WARP tunnel likely degraded — disconnect WARP or cycle Wi-Fi"
  else fail "Internet barely responsive (${PINGOUT}ms avg)" "WARP tunnel degraded — disconnect WARP; if that fixes it, it's the tunnel not Wi-Fi"; fi
fi

# ---------- 5. Power ----------
hd "5. Power settings (prevent wake churn)"
PM=$(R 'pmset -g custom 2>/dev/null')
check_pm() { v=$(echo "$PM" | grep -iE "^ *$1 " | head -1 | awk '{print $2}'); \
  if [ "$v" = "$2" ]; then pass "$1 = $v"; else warn "$1 = ${v:-?} (want $2)" "sudo pmset -a $1 $2"; fi; }
check_pm womp 0
check_pm powernap 0
check_pm tcpkeepalive 0

# ---------- 6. Bluetooth ----------
hd "6. Bluetooth"
# Ground truth = system_profiler State (blueutil -p is unreliable over SSH — it can report 0
# while BT is actually On). Use SPBluetoothDataType for the power check.
BTSTATE=$(R 'system_profiler SPBluetoothDataType 2>/dev/null | awk "/State:/{print \$2; exit}"')
if   [ "$BTSTATE" = "On" ];  then pass "Bluetooth is ON"
elif [ "$BTSTATE" = "Off" ]; then fail "Bluetooth is OFF (UC & mouse need it)" "toggle on in Control Center (blueutil -p 1 can be unreliable over SSH)"; F_BT_OFF=1
else printf "        ${c_dim}- could not read BT state (SPBluetoothDataType); skipping${c_off}\n"; fi
BLEERR=$(num "$(R "$LOG show --last 5m --predicate 'process == \"sharingd\"' 2>/dev/null | grep -c 'handlePeerDisconnectionCompleted'")")
if   [ "$BLEERR" -le 3 ];  then pass "BLE peer link stable ($BLEERR disconnects/5m)"
elif [ "$BLEERR" -le 10 ]; then warn "$BLEERR BLE disconnects/5m (flapping)" "if UC misbehaving, toggle Bluetooth off/on"; F_BLE=1
else fail "BLE disconnect storm ($BLEERR/5m) — wedged CoreBluetooth" "toggle Bluetooth: blueutil -p 0 && sleep 6 && blueutil -p 1"; F_BLE=1; fi

# ---------- 7. AWDL & Continuity ----------
hd "7. AWDL & Continuity daemons"
AWDL=$(R 'ifconfig awdl0 2>/dev/null | awk "/status:/{print \$2}"')
if [ "$AWDL" = "active" ]; then pass "awdl0 is active"
else fail "awdl0 not active (status=${AWDL:-none})" "cycle Wi-Fi"; F_AWDL=1; fi
for d in rapportd sharingd useractivityd; do
  P=$(R "pgrep -x $d | head -1")
  if [ -n "$P" ]; then pass "$d running (pid $P)"; else fail "$d NOT running" "auto-relaunches; pkill -x $d or reboot"; F_AWDL=1; fi
done

# ---------- 8. Universal Control feature ----------
hd "8. Universal Control feature state"
UCDIS=$(R 'defaults -currentHost read com.apple.universalcontrol Disable 2>/dev/null || echo "unset"')
if [ "$UCDIS" = "0" ] || [ "$UCDIS" = "unset" ]; then pass "UC enabled (per-host Disable=$UCDIS)"
else fail "UC DISABLED locally (per-host Disable=$UCDIS) — the silent killer" "defaults -currentHost write com.apple.universalcontrol Disable -bool false"; F_UCDISABLE=1; fi
MDMUC=$(R 'defaults read "/Library/Managed Preferences/com.apple.applicationaccess" allowUniversalControl 2>/dev/null || echo "unset"')
if   [ "$MDMUC" = "0" ]; then fail "MDM profile FORCE-DISABLES Universal Control" "MDM -> Restrictions -> allow Universal Control"
elif [ "$MDMUC" = "1" ]; then pass "MDM allows Universal Control"
else printf "        ${c_dim}- no MDM restriction for UC (user-controlled)${c_off}\n"; fi

# ---------- 9. UC peer link — correlates connection + failure signals (last 5m) ----------
# Calibration: a broken UC otherwise shows up only as two separate WARNs (no-connection +
# BLE flap), which never trips --fix. So correlate instead: an active FAILURE signature
# (stream Prepare-failed, -71148, No-request-handler) OR (BLE flapping AND no active
# connection) = FAIL, which drives --fix. No failures + no connection = genuinely idle =
# PASS (don't force a repair when UC simply isn't in use right now).
hd "9. Universal Control peer link (last 5m)"
FLAP=$(num "$(R "$LOG show --last 5m --predicate 'process == \"UniversalControl\"' 2>/dev/null | grep -c 'CONNECTION_INTERRUPTED'")")
CONN=$(num "$(R "$LOG show --last 5m --predicate 'process == \"UniversalControl\"' 2>/dev/null | grep -c 'Accepting (Connected)'")")
NOHANDLER=$(num "$(R "$LOG show --last 5m --predicate 'process == \"UniversalControl\"' 2>/dev/null | grep -c 'No request handler'")")
STREAMFAIL=$(num "$(R "$LOG show --last 5m --predicate 'process == \"UniversalControl\"' 2>/dev/null | grep -cE 'Prepare failed|RPErrorDomain.:-71148'")")
# BLEERR carried over from check 6 (handlePeerDisconnectionCompleted count/5m)
BLEFLAP=$(num "$BLEERR")

if [ "$NOHANDLER" -gt 0 ]; then
  fail "UC 'No request handler' ($NOHANDLER/5m) — peer's rapportd didn't register the stream handler" "restart Continuity daemons on BOTH Macs"; F_AWDL=1
elif [ "$STREAMFAIL" -gt 2 ]; then
  fail "UC stream failing ($STREAMFAIL Prepare-failed/-71148 in 5m) — wedged AWDL/CompanionLink" "restart Continuity on BOTH Macs; if awdl0 down, cycle Wi-Fi"; F_AWDL=1
elif [ "$FLAP" -gt 5 ]; then
  fail "UC peer link flapping ($FLAP interrupts/5m) — wedged CompanionLink" "BT toggle + restart Continuity on BOTH Macs"; F_BLE=1
elif [ "$CONN" -gt 0 ] && [ "$FLAP" -le 2 ]; then
  pass "UC peer link established (connected, $FLAP interrupts)"
elif [ "$CONN" -eq 0 ] && [ "$BLEFLAP" -gt 3 ]; then
  # no active session AND BLE is flapping = the broken state that used to slip through as 2 WARNs
  fail "UC not connected AND BLE flapping ($BLEFLAP disc/5m) — broken, not idle" "restart Continuity on BOTH Macs (--fix); then push cursor through edge"; F_BLE=1
elif [ "$CONN" -eq 0 ]; then
  warn "No UC connection in last 5m (no failures seen — may just be idle)" "if you expect it connected: push cursor through edge, or --fix"
else
  pass "UC peer link ok ($CONN connects, $FLAP interrupts)"
fi

# ---------- 10. Peer reachability ----------
if [ -n "$PEER" ]; then
  hd "10. Peer reachability -> $PEER"
  PING=$(R "ping -c2 -t3 $PEER >/dev/null 2>&1 && echo ok || echo no")
  [ "$PING" = "ok" ] && pass "Can reach peer $PEER on LAN" || fail "Cannot reach peer $PEER" "confirm both on same Wi-Fi/subnet"
fi

# ================= AUTO-FIX =================
if [ "$DOFIX" = 1 ] && [ "$FAILS" -gt 0 ]; then
  hd ">>> AUTO-FIX"

  fix_host() {  # $1 = "local" or "peer"; runner set accordingly
    local where="$1"; local RUN
    if [ "$where" = peer ]; then RUN=RP; local label="PEER ($PEER)"; else RUN=R; local label="THIS ($REMOTE${REMOTE:+ }${REMOTE:-localhost})"; fi
    printf "${c_bld}-- repairing %s --${c_off}\n" "$label"

    # 1. UC disabled -> enable + restart daemon
    if [ "$F_UCDISABLE" = 1 ]; then
      echo "  * enabling Universal Control pref"
      $RUN 'defaults -currentHost write com.apple.universalcontrol Disable -bool false; pkill -x UniversalControl 2>/dev/null; pkill -x sharingd 2>/dev/null; true'
    fi

    # 2. BLE storm -> Bluetooth off/on. Only when the BLE-storm flag is set (F_BLE from a real
    #    storm), NOT for generic UC failures. Verify via system_profiler (blueutil -p is
    #    unreliable over SSH) and ALWAYS end with BT On — never leave the peer's Bluetooth off.
    if [ "$F_BLE" = 1 ] && $RUN 'command -v blueutil >/dev/null 2>&1'; then
      echo "  * Bluetooth off/on (verifying via system_profiler)"
      $RUN 'blueutil -p 0 2>/dev/null; sleep 6; blueutil -p 1 2>/dev/null; sleep 3
            st=$(system_profiler SPBluetoothDataType 2>/dev/null | awk "/State:/{print \$2; exit}")
            if [ "$st" != On ]; then blueutil -p 1 2>/dev/null; sleep 4; fi
            st=$(system_profiler SPBluetoothDataType 2>/dev/null | awk "/State:/{print \$2; exit}")
            echo "    BT state after toggle: ${st:-unknown}"; true'
    fi

    # 3. awdl0 actually DOWN -> cycle Wi-Fi (heavier; only when the interface is down).
    #    A stuck stream handler / NoHandler does NOT need this — the daemon restart below fixes it.
    if [ "$F_AWDL" = 1 ]; then
      awdl_state=$($RUN 'ifconfig awdl0 2>/dev/null | awk "/status:/{print \$2}"')
      if [ "$awdl_state" != active ]; then
        echo "  * awdl0 down -> cycling Wi-Fi"
        $RUN 'networksetup -setairportpower en0 off; sleep 4; networksetup -setairportpower en0 on; sleep 6; true'
      fi
    fi

    # 4. Always refresh Continuity daemons — this is the common cure (incl. the 'No request
    #    handler' stuck-receiver case). Cheap, safe (input is local BT/trackpad).
    echo "  * restarting Continuity daemons (rapportd/sharingd/useractivityd/UniversalControl)"
    $RUN 'pkill -x rapportd 2>/dev/null; pkill -x sharingd 2>/dev/null; pkill -x useractivityd 2>/dev/null; pkill -x UniversalControl 2>/dev/null; true'
  }

  fix_host local
  [ -n "$PEER" ] && fix_host peer

  echo ""
  echo "Repairs applied. Wait ~15s, then trigger Universal Control (push cursor through the screen edge)."
  echo "Re-run without --fix to confirm all green:  $0 ${REMOTE}${PEER:+ --peer $PEER}"
fi

# ---------- summary ----------
printf "\n${c_bld}=== Summary ===${c_off}\n"
if [ "$FAILS" -eq 0 ] && [ "$WARNS" -eq 0 ]; then printf "  ${c_grn}All checks passed.${c_off}\n"
else printf "  ${c_red}%d FAIL${c_off}, ${c_yel}%d WARN${c_off}%s\n" "$FAILS" "$WARNS" "$([ "$DOFIX" = 1 ] && echo ' (fixes attempted — re-run to confirm)')"; fi
[ "$FAILS" -gt 0 ] && exit 1 || exit 0
