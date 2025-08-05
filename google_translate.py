import pandas as pd
import re
from googletrans import Translator

# Use utf-8-sig (safer cross-platform) instead of windows-874
#file_path = '3f63ed50-e363-4490-9fc2-f2f0b83e42fc.csv'
file_path = 'happyhoursreal.csv'
df = pd.read_csv(file_path, encoding='utf-8-sig')  # You can try 'ISO-8859-11' if needed

# Initialize Google Translator
translator = Translator()

# Thai character detection pattern
thai_pattern = re.compile(r'[\u0E00-\u0E7F]')

# Function to translate Thai to English
def translate_if_thai(text):
    try:
        if isinstance(text, str) and re.search(thai_pattern, text):
            translated = translator.translate(text, src='th', dest='en')
            return translated.text
        return text
    except Exception as e:
        print(f"Translation error: {e} for text: {text}")
        return text

# Apply translation to each cell in the DataFrame
translated_df = df.applymap(translate_if_thai)

# Save to new CSV
translated_df.to_csv('translated_output.csv', index=False, encoding='utf-8-sig')
print("✅ Translation complete. Saved as 'translated_output.csv'.")
