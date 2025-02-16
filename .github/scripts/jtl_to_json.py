import csv
import json
import sys
import glob

def parse_jtl_to_json(jtl_files, output_json):
    benchmark_data = {}

    for jtl_file in jtl_files:
        try:
            with open(jtl_file, 'r', encoding='utf-8') as file:
                reader = csv.reader(file)
                
                # JMeter CSV headers (assumed since JTL files often lack headers)
                headers = ["timestamp", "elapsed", "label", "responseCode", "responseMessage", 
                           "threadName", "dataType", "success", "bytes", "sentBytes", 
                           "grpThreads", "allThreads", "URL", "Latency", "IdleTime", "Connect"]
                
                for row in reader:
                    if len(row) < len(headers):  # Skip malformed rows
                        continue
                    
                    entry = dict(zip(headers, row))
                    
                    # Convert elapsed time to integer
                    try:
                        elapsed_time = int(entry["elapsed"])
                    except ValueError:
                        continue  # Skip invalid values

                    name = entry["label"]

                    # Aggregate data for each request type
                    if name not in benchmark_data:
                        benchmark_data[name] = {"total": 0, "count": 0}

                    benchmark_data[name]["total"] += elapsed_time
                    benchmark_data[name]["count"] += 1

        except Exception as e:
            print(f"Error reading JTL file {jtl_file}: {e}")
            continue
    
    # Compute average response time per request
    benchmark_results = [
        {
            "name": name,
            "unit": "ms",
            "value": round(data["total"] / data["count"], 2) if data["count"] > 0 else 0
        }
        for name, data in benchmark_data.items()
    ]

    # Write results to JSON file
    with open(output_json, 'w', encoding='utf-8') as json_file:
        json.dump(benchmark_results, json_file, indent=4)

    print(f"Successfully converted JTL to JSON with averaged results: {output_json}")

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
