import openpyxl
import psycopg2
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'dbname': 'builtin',
    'user': 'postgres',
    'password': ''
}

XLSX_PATH = 'BE/src/resources/קטלוג פטרה(1).xlsx'
PROVIDER_NAME = 'פטרה'
PROVIDER_EMAIL = 'petra@builtin.com'


def infer_unit(description: str) -> str:
    if not description:
        return 'UNIT'
    desc_lower = str(description).lower()
    if 'kg' in desc_lower or 'ק"ג' in description or 'קג' in description:
        return 'KG'
    if 'gram' in desc_lower or 'גרם' in description:
        return 'GRAM'
    if 'liter' in desc_lower or 'ליטר' in description:
        return 'LITER'
    if 'ml' in desc_lower or "מ'ל" in description or 'מל' in description:
        return 'MILLILITER'
    if 'meter' in desc_lower or 'מטר' in description:
        return 'METER'
    if 'cm' in desc_lower or 'ס"מ' in description:
        return 'CENTIMETER'
    if 'mm' in desc_lower or 'מ"מ' in description:
        return 'MILLIMETER'
    if 'm2' in desc_lower or 'מ"ר' in description:
        return 'SQUARE_METER'
    if 'pack' in desc_lower or 'חבילה' in description:
        return 'PACK'
    if 'box' in desc_lower or 'קופסה' in description or 'ארגז' in description:
        return 'BOX'
    if 'dozen' in desc_lower or 'תריסר' in description:
        return 'DOZEN'
    return 'UNIT'


def main():
    print('Connecting to database...')
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    # Ensure provider exists (commit separately so it's not rolled back on item errors)
    cur.execute('SELECT id FROM providers WHERE name = %s', (PROVIDER_NAME,))
    row = cur.fetchone()
    if row:
        provider_id = row[0]
        print(f'Provider "{PROVIDER_NAME}" already exists with id={provider_id}')
    else:
        cur.execute(
            'INSERT INTO providers (name, email) VALUES (%s, %s) RETURNING id',
            (PROVIDER_NAME, PROVIDER_EMAIL)
        )
        provider_id = cur.fetchone()[0]
        conn.commit()
        print(f'Created provider "{PROVIDER_NAME}" with id={provider_id}')

    # Read xlsx
    print(f'Reading {XLSX_PATH}...')
    wb = openpyxl.load_workbook(XLSX_PATH, read_only=True)
    ws = wb['מוצרים']

    rows = list(ws.iter_rows(values_only=True))
    header = rows[0]
    data_rows = rows[1:]
    print(f'Header: {header}')
    print(f'Data rows: {len(data_rows)}')

    inserted = 0
    skipped = 0
    errors = 0

    for row in data_rows:
        if not row or row[0] is None:
            continue

        serial_number = str(row[0]).strip()
        name = str(row[1]).strip() if row[1] else None
        description = str(row[2]).strip() if row[2] else None
        price_raw = row[3]

        if not name:
            skipped += 1
            continue

        try:
            price = float(price_raw) if price_raw is not None else 0.0
        except (ValueError, TypeError):
            price = 0.0

        unit = infer_unit(description)

        # Truncate fields to column limits
        name_trunc = name[:255] if name else name
        desc_trunc = description[:255] if description else description
        serial_trunc = serial_number[:255] if serial_number else serial_number

        try:
            cur.execute(
                '''INSERT INTO items (name, item_type, serial_number, price, quantity, unit, provider_id)
                   VALUES (%s, %s, %s, %s, %s, %s, %s)
                   ON CONFLICT (serial_number) DO NOTHING''',
                (name_trunc, desc_trunc, serial_trunc, price, 1, unit, provider_id)
            )
            if cur.rowcount > 0:
                inserted += 1
            else:
                skipped += 1
        except Exception as e:
            print(f'Error inserting row serial={serial_number}: {e}')
            conn.rollback()
            errors += 1
            continue

    conn.commit()
    conn.close()

    print(f'\nDone!')
    print(f'  Inserted: {inserted}')
    print(f'  Skipped (duplicates/empty): {skipped}')
    print(f'  Errors: {errors}')


if __name__ == '__main__':
    main()
