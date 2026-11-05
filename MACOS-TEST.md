# Temporary macOS testing machine

Run **Actions > macOS video-use > Run workflow** to prepare an Intel macOS
15 machine with Python 3.12, FFmpeg, Codex CLI and video-use. The workflow
runs the repository tests and a real synthetic-video render. It then keeps
the machine available for five hours, within GitHub's six-hour job limit.

Tailscale must be connected on the client computer. Read the private IP
from the **Enable private SSH** log or from Tailscale's Machines page.

On the Mac where this setup was prepared, connect with:

```sh
ssh -i ~/.ssh/video-use-macos -p 2222 runner@TAILSCALE_IP
```

The private key stays on this computer. The repository contains only its
public key in `MAC_SSH_PUBLIC_KEY`. Tailscale uses the existing integration
for `tag:video-use`.

The project is in `/Users/runner/work/video-use/video-use`. Activate its
environment with `source .venv/bin/activate`. Connect your own account in
Codex and configure ElevenLabs separately if you need transcription. No
paid API calls are made by setup verification.

## Graphical access limitation

Screen sharing is experimental and disabled by default. In the tested
session the VNC service accepted authentication but showed a black screen.
It is not a working graphical desktop configuration. macOS screen-sharing
permissions may require enabling from System Settings or managed-device
administration; these are not bypassed by this workflow.

If explicitly enabled, the experiment blocks external VNC traffic with PF
and expects VNC to be reached through an SSH tunnel only. Its separate VNC
password is a repository secret (`MAC_VNC_PASSWORD`), not a macOS user
account password.

Save files before the job ends. No personal video files, account credentials
or editing results are backed up automatically. Cancel the run when done.
