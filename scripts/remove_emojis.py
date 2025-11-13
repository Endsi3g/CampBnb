#!/usr/bin/env python3
"""
Script pour retirer tous les emojis des fichiers Markdown
"""

import re
import os
from pathlib import Path

# Liste des emojis courants à retirer
EMOJI_PATTERN = re.compile(
    r'['
    r'\U0001F300-\U0001F9FF'  # Emojis généraux
    r'\U00002600-\U000026FF'  # Symboles divers
    r'\U00002700-\U000027BF'  # Dingbats
    r'\U0001F600-\U0001F64F'  # Emoticons
    r'\U0001F680-\U0001F6FF'  # Transport
    r'\U0001F1E0-\U0001F1FF'  # Drapeaux
    r'\U0001F900-\U0001F9FF'  # Emojis supplémentaires
    r'\U00002600-\U000026FF'  # Symboles
    r'\U00002700-\U000027BF'  # Dingbats
    r']+'
)

def remove_emojis_from_text(text):
    """Retire tous les emojis d'un texte"""
    # Retire les emojis
    text = EMOJI_PATTERN.sub('', text)
    # Nettoie les espaces multiples
    text = re.sub(r' +', ' ', text)
    # Nettoie les espaces avant les deux-points
    text = re.sub(r' :', ':', text)
    return text.strip()

def process_markdown_file(file_path):
    """Traite un fichier Markdown"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Retire les emojis des titres (## avec emoji)
        lines = content.split('\n')
        new_lines = []
        
        for line in lines:
            # Retire les emojis de toutes les lignes
            cleaned = remove_emojis_from_text(line)
            # Nettoie les espaces multiples après #
            if cleaned.startswith('#'):
                cleaned = re.sub(r'^#+\s+', lambda m: m.group(0).rstrip() + ' ', cleaned)
            new_lines.append(cleaned)
        
        new_content = '\n'.join(new_lines)
        
        # Écrit seulement si le contenu a changé
        if new_content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"[OK] Traite: {file_path}")
            return True
        return False
    except Exception as e:
        print(f"[ERREUR] Erreur avec {file_path}: {e}")
        return False

def main():
    """Fonction principale"""
    root = Path('.')
    md_files = list(root.rglob('*.md'))
    
    print(f"Traitement de {len(md_files)} fichiers Markdown...")
    
    processed = 0
    for md_file in md_files:
        # Ignore les fichiers dans node_modules, .git, etc.
        if any(part.startswith('.') or part in ['node_modules', 'build', 'dist'] for part in md_file.parts):
            continue
        
        if process_markdown_file(md_file):
            processed += 1
    
    print(f"\nTerminé! {processed} fichiers modifiés.")

if __name__ == '__main__':
    main()

