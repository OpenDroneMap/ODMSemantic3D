import json
import sys
import os

# The path of the json file
json_file_path = sys.argv[1]
# The list of file paths to add
files_to_add = sys.argv[2:]

with open(json_file_path, 'r+') as f:
    data = json.load(f)

    # Append new file paths to the training_set
    data["training_set"].extend(files_to_add)

    # Remove non-existing file paths from the training_set
    data["training_set"] = [f for f in data["training_set"] if os.path.isfile(f)]

    f.seek(0)
    json.dump(data, f, indent=4)
    f.truncate()