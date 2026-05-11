import json
import re
import os

def get_placeholders(text):
    # Match {name} but ignore those inside ICU select/plural blocks for simple analysis
    # This is a bit naive but good for finding mismatches in simple strings
    return set(re.findall(r'\{(\w+)\}', text))

def analyze_arb(en_path, target_path):
    lang = os.path.basename(target_path).split('_')[1].split('.')[0].upper()
    with open(en_path, 'r', encoding='utf-8') as f:
        en_data = json.load(f)
    with open(target_path, 'r', encoding='utf-8') as f:
        target_data = json.load(f)

    en_keys = {k for k in en_data.keys() if not k.startswith('@')}
    target_keys = {k for k in target_data.keys() if not k.startswith('@')}

    missing = en_keys - target_keys
    extra = target_keys - en_keys

    print(f"\n--- {lang} Analysis Report ---")
    print(f"Status: {len(target_keys)}/{len(en_keys)} keys ({len(target_keys)/len(en_keys)*100:.1f}%)")
    
    if missing:
        print(f"[!] Missing ({len(missing)}): {list(sorted(missing))[:10]} ...")
    else:
        print("[+] No missing keys.")

    if extra:
        print(f"[!] Extra ({len(extra)}): {list(sorted(extra))[:10]} ...")

    mismatches = 0
    for k in en_keys & target_keys:
        # Skip select/plural for placeholder mismatch check as it gives false positives
        if '{' in en_data[k] and ('select' in en_data[k] or 'plural' in en_data[k]):
            continue
            
        en_p = get_placeholders(en_data[k])
        target_p = get_placeholders(target_data[k])
        if en_p != target_p:
            mismatches += 1
            if mismatches <= 5:
                print(f"  - {k}: EN={en_p}, {lang}={target_p}")
    
    if mismatches > 5:
        print(f"  ... and {mismatches - 5} more mismatches.")
    elif mismatches == 0:
        print("[+] No placeholder mismatches.")

if __name__ == "__main__":
    base_en = 'lib/core/l10n/app_en.arb'
    for lang_file in ['app_tr.arb', 'app_de.arb', 'app_ku.arb']:
        path = os.path.join('lib/core/l10n', lang_file)
        if os.path.exists(path):
            analyze_arb(base_en, path)
