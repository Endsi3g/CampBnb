#!/usr/bin/env python3
"""
Script pour retirer tous les emojis des fichiers Dart
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
    return text.strip()

def process_dart_file(file_path):
    """Traite un fichier Dart"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Retire les emojis de toutes les lignes
        lines = content.split('\n')
        new_lines = []
        
        for line in lines:
            # Si la ligne contient un emoji dans une string
            if "'" in line or '"' in line:
                # Retire les emojis des strings
                cleaned = EMOJI_PATTERN.sub('', line)
                # Nettoie les espaces multiples
                cleaned = re.sub(r' +', ' ', cleaned)
                new_lines.append(cleaned)
            else:
                new_lines.append(line)
        
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
    root = Path('lib')
    if not root.exists():
        print("Dossier lib non trouve")
        return
    
    dart_files = list(root.rglob('*.dart'))
    
    print(f"Traitement de {len(dart_files)} fichiers Dart...")
    
    processed = 0
    for dart_file in dart_files:
        if process_dart_file(dart_file):
            processed += 1
    
    print(f"\nTermine! {processed} fichiers modifies.")

if __name__ == '__main__':
    main()

