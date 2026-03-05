import io

try:
    with io.open('build_result.txt', 'r', encoding='utf-16-le', errors='ignore') as f:
        content = f.read()
    
    # Find the failure block
    lines = content.split('\n')
    capture = False
    out_lines = []
    for i, line in enumerate(lines):
        if 'FAILURE: Build failed' in line or ('compileDebugKotlin FAILED' in line):
            capture = True
        if capture:
            out_lines.append(line)
        if capture and 'Get more help at https://help.gradle.org' in line:
            for j in range(1, 5):
                if i+j < len(lines):
                    out_lines.append(lines[i+j])
            break
    
    if not out_lines:
        # also search for FAILED
        for i, line in enumerate(lines):
            if 'FAILED' in line and 'assembleDebug' not in line:
                out_lines.append(f"[{i}] {line}")
    
    if not out_lines:
        print("No known error found. Last 50 lines:")
        print('\n'.join(lines[-50:]))
    else:
        print('\n'.join(out_lines[:100]))
except Exception as e:
    print(str(e))
