import io

try:
    with io.open('build_out_utf8.txt', 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
    
    print(f"Total lines: {len(lines)}")
    
    # Search for FAILED task
    for i, line in enumerate(lines):
        s = line.strip()
        if 'FAILED' in s or 'Unresolved reference' in s or 'FAILURE:' in s or 'error:' in s.lower():
            print(f"[{i}] {s}")
    
    print("\n--- Last 20 lines ---")
    for l in lines[-20:]:
        print(l.strip())
except Exception as e:
    print(str(e))
