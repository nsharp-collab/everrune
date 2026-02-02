import os

FILE_PATH = "assets/Everrune.rbxlx"
OUTPUT_DIR = "src"

if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

print("--- [VERSION 8.0 - THE BIG FILE SEARCHLIGHT] ---")

count = 0
current_name = "Unknown"
source_buffer = []
is_recording = False

# We open with 'rb' (read binary) then decode to handle weird characters in big files
with open(FILE_PATH, 'rb') as f:
    for line_bytes in f:
        try:
            line = line_bytes.decode('utf-8', errors='ignore')
        except:
            continue

        # 1. Catch the Name (looking for any string tag with name="Name")
        if 'name="Name"' in line or "name='Name'" in line:
            if '<string' in line:
                try:
                    current_name = line.split('>')[1].split('</')[0]
                except:
                    pass

        # 2. Detect the start of a Source block
        if 'name="Source"' in line or "name='Source'" in line:
            is_recording = True
            source_buffer = []
            # Check if it's a one-liner
            if '</string>' in line:
                try:
                    content = line.split('>')[1].split('</')[0]
                    source_buffer.append(content)
                    is_recording = False
                    # Trigger the save immediately for one-liners
                except:
                    is_recording = False
            else:
                continue

        # 3. If we are recording, keep adding lines until we hit the end tag
        if is_recording:
            if '</string>' in line:
                end_part = line.split('</string>')[0]
                source_buffer.append(end_part)
                
                # SAVE THE FILE
                full_code = "".join(source_buffer).strip()
                if full_code:
                    # Clean the code
                    full_code = full_code.replace('&gt;', '>').replace('&lt;', '<').replace('&amp;', '&').replace('&#13;', '')
                    
                    # Clean the filename
                    safe_name = "".join([c for c in current_name if c.isalnum() or c in (' ', '.', '_')]).strip()
                    if not safe_name: safe_name = f"Script_{count}"
                    
                    with open(os.path.join(OUTPUT_DIR, f"{safe_name}.lua"), "w", encoding="utf-8") as out:
                        out.write(full_code)
                    
                    print(f"Success: {safe_name}.lua")
                    count += 1
                
                is_recording = False
                source_buffer = []
            else:
                source_buffer.append(line)

print(f"--- Finished! Successfully grabbed {count} scripts ---")