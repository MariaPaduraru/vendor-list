import pandas as pd
import json

# 1. Definirea numelor fișierelor
csv_file = 'presales_data_sample.csv'
json_file = 'presales_data_sample.json'


def convert_csv_to_json(csv_path, json_path):
    try:
        # Citim CSV-ul
        # Folosim keep_default_na=False pentru a avea string-uri goale în loc de NaN (care strică JSON-ul)
        df = pd.read_csv(csv_path, encoding='utf-8', keep_default_na=False)

        # Transformăm DataFrame-ul într-o listă de dicționare (orientare 'records')
        data = df.to_dict(orient='records')

        # Salvăm fișierul JSON
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=4, ensure_ascii=False)

        print(f"Succes! Fișierul a fost salvat ca: {json_path}")
        print(f"Număr total de rânduri procesate: {len(df)}")

    except Exception as e:
        print(f"A apărut o eroare: {e}")


if __name__ == "__main__":
    convert_csv_to_json(csv_file, json_file)