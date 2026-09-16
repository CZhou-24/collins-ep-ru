"""Run one owned helper and stop its process group when its driver stops."""
import os
import signal
import subprocess


def run_owned(command, *, parent_pid, **kwargs):
    """Preserve the parent's lifetime across Wolfram's separate process groups.

    Wolfram RunProcess gives the Python driver its own process group. The
    driver's parent can therefore be killed by the validator while its helper
    survives. Check the original parent and own each helper's complete group.
    This changes process lifetime only; commands, inputs and limits are intact.
    """
    if os.getppid() != parent_pid:
        raise RuntimeError('Native stage parent exited before helper launch')
    previous = signal.getsignal(signal.SIGTERM)
    process = None

    def stopped(signum, frame):
        raise SystemExit(128 + signum)

    signal.signal(signal.SIGTERM, stopped)
    try:
        process = subprocess.Popen(command, start_new_session=True, **kwargs)
        while True:
            if os.getppid() != parent_pid:
                raise RuntimeError('Native stage parent exited during helper execution')
            try:
                code = process.wait(timeout=0.25)
                return subprocess.CompletedProcess(command, code)
            except subprocess.TimeoutExpired:
                pass
    except BaseException:
        if process is not None and process.poll() is None:
            try:
                os.killpg(process.pid, signal.SIGTERM)
            except ProcessLookupError:
                pass
            try:
                process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                try:
                    os.killpg(process.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
                process.wait()
        raise
    finally:
        signal.signal(signal.SIGTERM, previous)
