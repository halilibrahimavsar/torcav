import re
import os

def find_hardcoded_strings(directory):
    # Regex for common Flutter string patterns
    # 1. Text('...')
    # 2. NeonText('...')
    # 3. label: '...'
    # 4. hintText: '...'
    # 5. tooltip: '...'
    
    patterns = [
        r"Text\(\s*['\"](.*?)['\"]\s*",
        r"NeonText\(\s*['\"](.*?)['\"]\s*",
        r"label:\s*['\"](.*?)['\"]",
        r"hintText:\s*['\"](.*?)['\"]",
        r"tooltip:\s*['\"](.*?)['\"]",
        r"title:\s*['\"](.*?)['\"]",
        r"subtitle:\s*['\"](.*?)['\"]",
    ]
    
    results = []
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                path = os.path.join(root, file)
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    for pattern in patterns:
                        matches = re.finditer(pattern, content)
                        for match in matches:
                            string_val = match.group(1)
                            # Basic filtering to avoid internal keys/ids
                            if string_val and any(c.isupper() for c in string_val) and len(string_val) > 1:
                                results.append({
                                    'file': path,
                                    'string': string_val,
                                    'line': content.count('\n', 0, match.start()) + 1
                                })
    return results

if __name__ == "__main__":
    directory = '/home/garuda/Masaüstü/torcav/lib'
    strings = find_hardcoded_strings(directory)
    # Sort by file and line
    strings.sort(key=lambda x: (x['file'], x['line']))
    
    for s in strings:
        print(f"{s['file']}:{s['line']}: {s['string']}")
