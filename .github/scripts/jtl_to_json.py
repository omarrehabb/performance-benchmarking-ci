import xml.etree.ElementTree as ET
import json
import sys
import glob

if len(sys.argv) < 3:
    print("Usage: python jtl_to_json.py <input_jtl_files> <output_json_file>")
    sys.exit(1)

jtl_files = glob.glob(sys.argv[1])
json_output_file = sys.argv[2]

results = []

for jtl_file in jtl_files:
    try:
        tree = ET.parse(jtl_file)
        root = tree.getroot()
    except ET.ParseError as e:
        print(f"Error parsing JTL file {jtl_file}: {e}")
        continue

    for sample in root.findall("httpSample"):
        label = sample.get("lb")  
        response_time = int(sample.get("t"))  
        success = sample.get("s") == "true"

        results.append({
            "name": f"JMeter - {label}",
            "unit": "Milliseconds",
            "value": response_time,
            "extra": f"Success: {success}"
        })

if results:
    with open(json_output_file, "w") as json_file:
        json.dump(results, json_file, indent=4)

    print(f"Converted JTL files to {json_output_file}")
else:
    print("No valid JTL data found!")
