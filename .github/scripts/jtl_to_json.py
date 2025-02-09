import csv
import json
import sys
import glob

def parse_jtl_to_json(jtl_files, output_json):
    benchmark_results = []
    
    for jtl_file in jtl_files:
        try:
            with open(jtl_file, 'r', encoding='utf-8') as file:
                reader = csv.reader(file)
                
                # JMeter CSV headers are usually missing, so we define them manually
                headers = ["timestamp", "elapsed", "label", "responseCode", "responseMessage", 
                           "threadName", "dataType", "success", "bytes", "sentBytes", 
                           "grpThreads", "allThreads", "URL", "Latency", "IdleTime", "Connect"]
                
                for row in reader:
                    if len(row) < len(headers):  # Skip malformed rows
                        continue
                    
                    entry = dict(zip(headers, row))
                    
                    # Convert necessary fields to numbers
                    try:
                        elapsed_time = int(entry["elapsed"])
                    except ValueError:
                        elapsed_time = None

                    # Only keep useful benchmark data
                    benchmark_results.append({
                        "name": f"{entry['label']}",
                        "unit": "ms",
                        "value": elapsed_time if elapsed_time is not None else 0
                    })

        except Exception as e:
            print(f"Error reading JTL file {jtl_file}: {e}")
            continue
    
    # Write to JSON file
    with open(output_json, 'w', encoding='utf-8') as json_file:
        json.dump(benchmark_results, json_file, indent=4)
    
    print(f"Successfully converted JTL to JSON: {output_json}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 jtl_to_json.py <jtl_files> <output_json>")
        sys.exit(1)

    jtl_files = glob.glob(sys.argv[1])  # Get all JTL files
    output_json = sys.argv[2]
    
    if not jtl_files:
        print("No JTL files found!")
        sys.exit(1)

    parse_jtl_to_json(jtl_files, output_json)
