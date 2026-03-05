import io
import re

try:
    with io.open('build_out_utf8.txt', 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
        
    for i, line in enumerate(lines):
        if 'FAILED' in line or 'failed' in line:
            # exclude generic flutter failure summaries
            if "assembleDebug failed with exit code 1" not in line and "Build failed" not in line and "exiting with code" not in line:
                print(f"Line {i}: {line.strip()}")
except Exception as e:
    print(str(e))
