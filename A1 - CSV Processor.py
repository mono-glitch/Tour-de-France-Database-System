import csv

"""
Simple I/O Library
  We assume all files are in UTF-8
"""
# Text
def read_text(file):
  """
  Read a file as text.  The name of the file is
  given as `file`.  The file is treated as utf-8
  format.

  The return type is a String.
  """
  with open(file, encoding='utf-8') as f:
    return f.read()
  return ''
def write_text(file, data):
  """
  Write the data into a file as text.  The name
  of the file is given as `file`.  The data is
  given as `data`.  The file is treated as utf-8
  format.

  There is no return value.
  """
  with open(file, 'w', encoding='utf-8') as f:
    f.write(data)

# CSV
def read_csv(file):
  """
  Read a file as comma-separated value (csv).
  The name of the file is given as `file`.  The
  file is treated as utf-8 format.

  The return type is a list-of-list.
  """
  res = []
  with open(file, encoding='utf-8') as f:
    rd = csv.reader(f)
    for row in rd:
      res.append(row)
  return res
def write_csv(file, data):
  """
  Write the data into a file as a comma-separated
  value (csv).  The name of the file is given as
  `file`.  The data is given as `data`.  The file
  is treated as utf-8 format.  The data is treated
  as a list-of-list.

  There is no return value.
  """
  with open(file, 'w', encoding='utf-8') as f:
    wt = csv.write(f, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    for row in data:
      wt.writerow(row)




"""
Helper functions
"""
def as_str(v):
  """
  Return the value as a string that can be
  accepted by postgresql as string.
  """
  s = f'{v}'.replace("'", "''")
  return f"'{s}'"
def as_int(v):
  """
  Return the value as a string that can be
  accepted by postgresql as integer.
  """
  return f'{v}'




"""
EXAMPLE
  Study the following example on how to process
  the csv file and write a file containing the
  INSERT statements.
"""
def process(file, out):
  # reading the data
  data = read_csv(file)[1:]

  # the expected output
  line = ''

  # process line by line
  for bib,stage,reason in data:
    # produce an INSERT statement given a row
    line += f'INSERT INTO some_table VALUES ({as_int(bib)}, {as_int(stage)}, {as_str(reason)});\n'

  # write into a file
  write_text(out, line)

def process_stage1(file, out):
    data = read_csv(file)[1:]

    countries = {}
    teams = {}
    riders = {}
    locations = {}

    results = []

    stage_day = None
    stage_type = None
    stage_length = None
    start_loc = None
    finish_loc = None

    for row in data:
        stage = int(row[1])
        if stage != 1:
            continue

        stage_day = row[0]
        stage_number = int(row[1])
        bib = int(row[2])
        rank = int(row[3])

        time = int(row[4])
        bonus = int(row[5])
        penalty = int(row[6])

        start_location = row[7]
        start_cc = row[8]
        start_country = row[9]
        start_region = row[10]

        finish_location = row[11]
        finish_cc = row[12]
        finish_country = row[13]
        finish_region = row[14]

        length_km = row[15]
        stype = row[16]

        rider_name = row[17]
        team_name = row[18]
        dob = row[19]

        rider_cc = row[20]
        rider_country = row[21]
        rider_region = row[22]

        team_cc = row[23]
        team_country = row[24]
        team_region = row[25]

        countries[start_cc] = (start_country, start_region)
        countries[finish_cc] = (finish_country, finish_region)

        if rider_cc != "":
            countries[rider_cc] = (rider_country, rider_region)

        countries[team_cc] = (team_country, team_region)

        teams[team_name] = team_cc

        riders[bib] = (rider_name, dob, team_name, rider_cc if rider_cc != "" else None)

        locations[start_location] = start_cc
        locations[finish_location] = finish_cc

        start_loc = start_location
        finish_loc = finish_location
        stage_length = length_km
        stage_type = stype

        results.append((stage_number, bib, rank, time, bonus, penalty))

    sql = ""

    for code, (name, region) in countries.items():
        sql += f"INSERT INTO country VALUES ({as_str(code)}, {as_str(name)}, {as_str(region)});\n"

    sql += "\n"

    for team, cc in teams.items():
        sql += f"INSERT INTO team VALUES ({as_str(team)}, {as_str(cc)});\n"

    sql += "\n"

    for bib, (name, dob, team, cc) in riders.items():
        if cc is None:
            sql += f"INSERT INTO rider VALUES ({as_int(bib)}, {as_str(name)}, {as_str(dob)}, {as_str(team)}, NULL);\n"
        else:
            sql += f"INSERT INTO rider VALUES ({as_int(bib)}, {as_str(name)}, {as_str(dob)}, {as_str(team)}, {as_str(cc)});\n"

    sql += "\n"

    for loc, cc in locations.items():
        sql += f"INSERT INTO location VALUES ({as_str(loc)}, {as_str(cc)});\n"

    sql += "\n"

    sql += f"""INSERT INTO stage VALUES ({as_int(stage_number)}, {as_str(stage_day)}, {as_str(start_loc)}, {as_str(finish_loc)}, {stage_length}, {as_str(stage_type)});\n\n"""

    for (stage_number, bib, rank, time, bonus, penalty) in results:
        sql += f"""INSERT INTO stage_result VALUES ({as_int(stage_number)}, {as_int(bib)}, {as_int(rank)}, {as_int(time)}, {as_int(bonus)}, {as_int(penalty)});\n"""

    write_text(out, sql)

# Change the input filename and/or the output filename
process_stage1('tdf-2025.csv', 'P01-data.sql')
