# sx-custom-scripts

Custom scripts for the Pinnacle sound (SX) rooms.

## eucon-delayed-launch

Starts **WSControl**, then **DADman**, at login, but only once the EuCon network is ready.

WSControl's own "launch at login" opens it straight away. If the EuCon NIC or the S6 MTM isn't up yet, WSControl fails to reach the MTM's BootManager once (`HostUnreachable`, stuck in `WAITINGFORSERVICE`) and never retries. DADman then can't connect either. The usual fix has been to quit and relaunch both by hand.

The launcher:

1. waits for an address on the EuCon network (`192.168.50.x`)
2. waits for the MTRX to answer on its control port (`192.168.50.43:10003`). The MTM ignores ping, so ping isn't used.
3. waits a further 30 s so the MTM is ready if the console was restarted at the same time
4. launches WSControl, waits 15 s, then launches DADman, skipping either app if it's already running

If the EuCon address or the MTRX isn't there within 3 minutes, it gives up and **launches nothing**. That means something else is wrong, and apps starting minutes after login would surprise whoever is using the room. The log says which step it timed out on. Launch the apps by hand once the network problem is sorted.

### Files

| File | What it is |
|---|---|
| `sx-eucon-launch.sh` | The launcher. Bash, because the studio Macs have no Command Line Tools and so no working `python3`. |
| `com.pinnaclepost.sx-eucon-launch.plist` | LaunchAgent template. Per-room settings go in `EnvironmentVariables`. |
| `install.sh` / `uninstall.sh` | Install or remove it for the current user. No sudo needed. |

### Settings

Set these in the plist's `EnvironmentVariables` (defaults in brackets):

| Variable | Meaning |
|---|---|
| `EUCON_SUBNET` | Prefix of the EuCon network (`192.168.50.`) |
| `MTRX_HOST` / `MTRX_PORT` | MTRX control address (`192.168.50.43` / `10003`) |
| `APPS` | Apps to launch, in order (`WSControlApp DADman`) |
| `SETTLE_SECS` | Extra wait after the MTRX answers (`30`) |
| `APP_GAP_SECS` | Wait between apps (`15`) |
| `TIMEOUT_SECS` | Give up waiting and launch nothing (`180`) |

### Install

Copy the folder to the studio Mac, then run as the login user:

```bash
scp -r eucon-delayed-launch pinnaclemix02@192.168.40.159:/tmp/ && ssh pinnaclemix02@192.168.40.159 'bash /tmp/eucon-delayed-launch/install.sh'
```

Then **turn off WSControl's own "launch at login"** so it doesn't still start early. The launcher takes effect from the next login and doesn't launch anything at install time.

The log is at `~/Library/Logs/sx-eucon-launch.log`.

### Remove

```bash
bash /tmp/eucon-delayed-launch/uninstall.sh
```

Then turn WSControl's "launch at login" back on.
