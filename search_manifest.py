import io

try:
    with io.open('build_out_utf8.txt', 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()

    # First, search for processDebugMainManifest
    manifest_lines = []
    for i, line in enumerate(lines):
        if 'processDebugMainManifest' in line or 'Manifest merger failed' in line:
            manifest_lines.append(f"[{i}] {line.strip()}")

    with io.open('manifest_search.txt', 'w', encoding='utf-8') as out:
        if manifest_lines:
            out.write('\n'.join(manifest_lines))
        else:
            out.write("No processDebugMainManifest or Manifest merger failed found.\n")
            out.write("Actual failure block found:\n\n")
            capture = False
            for i, line in enumerate(lines):
                stripped = line.replace('\x00', '').strip()
                if 'FAILURE: Build failed' in stripped or 'compileDebugKotlin FAILED' in stripped:
                    capture = True
                if capture:
                    prefix = f"[{i}] "
                    out.write(prefix + stripped + '\n')
except Exception as e:
    print(str(e))
