import json
import collections
import re

def fix_metadata(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f, object_pairs_hook=collections.OrderedDict)
    
    new_data = collections.OrderedDict()
    for k, v in data.items():
        if k.startswith('@'):
            continue
            
        new_data[k] = v
        meta_key = '@' + k
        
        # If metadata exists, use it, but check for placeholders
        meta = data.get(meta_key, {})
        
        if '{' in v:
            placeholders = meta.get('placeholders', {})
            p_names = re.findall(r'\{(\w+)\}', v)
            if p_names:
                for p in p_names:
                    if p not in placeholders:
                        placeholders[p] = {"type": "String"}
                meta['placeholders'] = placeholders
        
        if 'description' not in meta:
            # Generate a simple description if missing
            meta['description'] = f"Label for {k}"
            
        new_data[meta_key] = meta

    # Custom fixes for specific types
    if '@bandwidthLabel' in new_data:
        new_data['@bandwidthLabel']['placeholders']['width'] = {"type": "int"}
    if '@throughputLabel' in new_data:
        new_data['@throughputLabel']['placeholders']['mbps'] = {"type": "int"}

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(new_data, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    import sys
    fix_metadata(sys.argv[1])
