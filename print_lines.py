import io

try:
    with io.open('build_out_utf8.txt', 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
        
    for i in range(max(0, 2740), min(len(lines), 2820)):
        print(f"[{i}] {lines[i].strip()}")
except Exception as e:
    print(str(e))
