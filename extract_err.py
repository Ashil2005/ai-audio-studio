import io

try:
    with io.open('build_out_ps1.txt', 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
        
    out = []
    capture = False
    for i, line in enumerate(lines):
        line = line.strip()
        if "FAILURE: Build failed" in line or "What went wrong:" in line:
            capture = True
        if capture:
            out.append(line)
            if "Get more help at https://help.gradle.org" in line:
                for j in range(1, 10):
                    if i + j < len(lines):
                        out.append(lines[i+j].strip())
                break
    
    if not out:
        # Check for Kotlin errors
        for i, line in enumerate(lines):
            if "e: " in line and "Exception" not in line:
                capture = True
            if capture:
                out.append(line.strip())
                if len(out) > 30:
                    break
                    
    print('\n'.join(out))
except Exception as e:
    print(str(e))
