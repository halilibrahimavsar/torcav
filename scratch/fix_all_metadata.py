import json
import os
import re

def humanize(s):
    # dnsProtocol -> Dns Protocol
    # netInfoSsidTitle -> Net Info Ssid Title
    res = re.sub(r"([a-z])([A-Z])", r"\1 \2", s)
    return res.capitalize()

def process_arb(file_path, template_data=None):
    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    
    new_data = {}
    keys = list(data.keys())
    
    # Identify non-meta keys
    main_keys = [k for k in keys if not k.startswith("@")]
    
    for k in main_keys:
        new_data[k] = data[k]
        meta_key = "@" + k
        
        if meta_key in data:
            new_data[meta_key] = data[meta_key]
        elif template_data and meta_key in template_data:
            new_data[meta_key] = template_data[meta_key]
        else:
            # Generate generic metadata
            new_data[meta_key] = {
                "description": humanize(k)
            }
            
    # Add any global metadata (like @@locale) if present
    for k in keys:
        if k.startswith("@@"):
            new_data[k] = data[k]

    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(new_data, f, indent=4, ensure_ascii=False)
        f.write("\n")

def main():
    arb_dir = "lib/core/l10n"
    en_path = os.path.join(arb_dir, "app_en.arb")
    
    # First process English to ensure it has all metadata
    process_arb(en_path)
    
    # Load the updated English as template
    with open(en_path, "r", encoding="utf-8") as f:
        en_data = json.load(f)
        
    # Process other files
    for lang in ["tr", "de", "ku"]:
        path = os.path.join(arb_dir, f"app_{lang}.arb")
        if os.path.exists(path):
            process_arb(path, template_data=en_data)
            print(f"Processed {path}")

if __name__ == "__main__":
    main()
