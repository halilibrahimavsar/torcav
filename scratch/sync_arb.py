import json
import collections
import os

def sync_arb(en_path, target_path):
    with open(en_path, 'r', encoding='utf-8') as f:
        en_data = json.load(f, object_pairs_hook=collections.OrderedDict)
    with open(target_path, 'r', encoding='utf-8') as f:
        target_data = json.load(f, object_pairs_hook=collections.OrderedDict)
    
    lang = os.path.basename(target_path).split('_')[1].split('.')[0]
    new_data = collections.OrderedDict()
    
    for k, v in en_data.items():
        if k == '@@locale':
            new_data[k] = lang
        elif k.startswith('@'):
            new_data[k] = v
        else:
            if k in target_data:
                new_data[k] = target_data[k]
            else:
                new_data[k] = v
            
    with open(target_path, 'w', encoding='utf-8') as f:
        json.dump(new_data, f, ensure_ascii=False, indent=4)
    print(f"Synced {target_path} with {en_path} (Preserved Locale: {lang})")

if __name__ == "__main__":
    en = 'lib/core/l10n/app_en.arb'
    for f in ['app_tr.arb', 'app_de.arb', 'app_ku.arb']:
        path = os.path.join('lib/core/l10n', f)
        if os.path.exists(path):
            sync_arb(en, path)
