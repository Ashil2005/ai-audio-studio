import io

try:
    with io.open('build_out_utf8.txt', 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
        
    with io.open('error_snippet.txt', 'w', encoding='utf-8') as out:
        for i in range(max(0, 2740), min(len(lines), 2820)):
            out.write(f"[{i}] {lines[i].strip()}\n")
except Exception as e:
    print(str(e))
