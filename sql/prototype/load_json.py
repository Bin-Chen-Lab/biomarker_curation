#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Quick load of JSON file into database for demo.

_NOT FOR PRODUCITON USE_

Created on Sun Mar 15 17:04:53 2020
"""
import json
from BiomarkerTranslatorAPI.common.query import Query
from dotenv import load_dotenv

load_dotenv()

json_file = 'data/released/json/biomarkers.json'

dat = json.load(open(json_file, 'rt'))

db = Query()

sql_statement = '''INSERT INTO json (record_id, body) VALUES (%s, %s)'''

for record in dat:
    db.cursor.execute(
        sql_statement,
        (record['biolink:id'], json.dumps(record)))

db.conn.commit()
