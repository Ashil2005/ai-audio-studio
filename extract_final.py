import io

try:
    with io.open('build_out_utf8.txt', 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
        
    with io.open('final_error.txt', 'w', encoding='utf-8') as out:
        capture = False
        for line in lines:
            if "FAILURE: Build failed with an exception" in line:
                capture = True
            if capture:
                # Strip the flutter time prefix like [        ] or [ +123 ms] 
                # to get the exact clean gradle log
                cleaned = line.split("] ", 1)[-1] if "] " in line[:20] else line
                out.write(cleaned)
except Exception as e:
    print(str(e))
