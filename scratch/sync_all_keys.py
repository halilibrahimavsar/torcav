import json
import os

def sync_all_keys(template_path, target_path):
    with open(template_path, "r", encoding="utf-8") as f:
        template = json.load(f)
    
    with open(target_path, "r", encoding="utf-8") as f:
        target = json.load(f)
    
    new_data = {}
    
    # We want to preserve @@locale if it exists in target
    for k in target:
        if k.startswith("@@"):
            new_data[k] = target[k]

    # Iterate through template keys to ensure they exist in target
    for k in template:
        if k.startswith("@@"):
            continue
        
        # If it is a main key (not metadata)
        if not k.startswith("@"):
            # If key exists in target, use target value
            if k in target:
                new_data[k] = target[k]
            else:
                # If key missing, use template value (as fallback)
                new_data[k] = template[k]
            
            # Now handle its metadata
            meta_key = "@" + k
            if meta_key in template:
                # Always sync metadata from template to ensure descriptions/placeholders are correct
                new_data[meta_key] = template[meta_key]

    # Re-insert @@locale at the end if it was there (or if it should be there)
    # Actually, let's keep it consistent
    if "@@locale" not in new_data:
        # Extract locale from filename app_tr.arb -> tr
        locale = os.path.basename(target_path).split("_")[1].split(".")[0]
        new_data["@@locale"] = locale

    with open(target_path, "w", encoding="utf-8") as f:
        json.dump(new_data, f, indent=4, ensure_ascii=False)
        f.write("\n")

def main():
    arb_dir = "lib/core/l10n"
    en_path = os.path.join(arb_dir, "app_en.arb")
    
    for lang in ["tr", "de", "ku"]:
        path = os.path.join(arb_dir, f"app_{lang}.arb")
        if os.path.exists(path):
            sync_all_keys(en_path, path)
            print(f"Synced {path}")

if __name__ == "__main__":
    main()
