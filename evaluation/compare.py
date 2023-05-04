import argparse
import json

def read_json_file(filename):
    with open(filename, 'r') as f:
        data = json.load(f)
    return data

def safe(val):
    return val if val is not None else 0

def sum_data(data_sum, data):
    data_sum["accuracy"] += data["accuracy"]
    for label in data["labels"]:
        if label in data_sum["labels"]:
            data_sum["labels"][label]["accuracy"] = safe(data_sum["labels"][label]["accuracy"]) + safe(data["labels"][label]["accuracy"])
            data_sum["labels"][label]["recall"] = safe(data_sum["labels"][label]["recall"]) + safe(data["labels"][label]["recall"])
            data_sum["labels"][label]["precision"] = safe(data_sum["labels"][label]["precision"]) + safe(data["labels"][label]["precision"])
            data_sum["labels"][label]["f1"] = safe(data_sum["labels"][label]["f1"]) + safe(data["labels"][label]["f1"])
        else:
            data_sum["labels"][label] = data["labels"][label]


def avg_data(data_sum, n):
    data_sum["accuracy"] /= n
    for label in data_sum["labels"]:
        data_sum["labels"][label]["accuracy"] /= n
        data_sum["labels"][label]["recall"] /= n
        data_sum["labels"][label]["precision"] /= n
        data_sum["labels"][label]["f1"] /= n


def safe_format(value, format_string="{:.2%}"):
    return format_string.format(value) if value is not None else "N/A"


def print_table(baseline_data, target_data, data):

    print("\n  Accuracy: {:.2%} vs {:.2%}".format(
        baseline_data["accuracy"], target_data["accuracy"]))
    print("\n |               Label  |   Accuracy |     Recall |  Precision |         F1 |")
    print(" | -------------------- | ---------- | ---------- | ---------- | ---------- |")

    all_labels = set(baseline_data["labels"].keys()) | set(
        target_data["labels"].keys())
    for label in all_labels:

        d = data["labels"][label]

        if label in baseline_data["labels"] and label in target_data["labels"]:

            bd = baseline_data["labels"][label]
            td = target_data["labels"][label]

            print(" |                      | {:>10} | {:>10} | {:>10} | {:>10} |".format(
                safe_format(bd["accuracy"]), safe_format(bd["recall"]), safe_format(bd["precision"]), safe_format(bd["f1"], "{:.2f}")))
            print(" | {:20} | {:>10} | {:>10} | {:>10} | {:>10} |".format(
                label, safe_format(td["accuracy"]), safe_format(td["recall"]), safe_format(td["precision"]), safe_format(td["f1"], "{:.2f}")))
            print(" |                      | {:>10} | {:>10} | {:>10} | {:>10} |".format(
                safe_format(d["accuracy"]), safe_format(d["recall"]), safe_format(d["precision"]), safe_format(d["f1"])))
        else:
            print(" | {:20} | {:>10%} | {:>10} | {:>10} | {:>10} |".format(
                label, safe_format(d["accuracy"]), safe_format(d["recall"]), safe_format(d["precision"]), safe_format(d["f1"], "{:.2f}")))

        print(
            " |                      |            |            |            |            |")


def compare(baseline, target):
    comparison = {
        "accuracy": (target["accuracy"] - baseline["accuracy"]) / baseline["accuracy"],
        "labels": {}
    }
    labels = set(baseline["labels"].keys()) | set(target["labels"].keys())

    for label in labels:
        if label in baseline["labels"] and label in target["labels"]:

            tgs = target["labels"][label]
            bgs = baseline["labels"][label]

            comparison["labels"][label] = {key: (tgs[key] - bgs[key]) / bgs[key]
                                           if bgs[key] != 0 and
                                           tgs[key] is not None and
                                           bgs[key] is not None else None
                                           for key in ["accuracy", "recall", "precision", "f1"]}
        else:
            comparison["labels"][label] = {key: None
                                           for key in ["accuracy", "recall", "precision", "f1"]}

    return comparison


def main(filenames):

    # Check if even number of filenames
    if len(filenames) % 2 != 0:
        raise ValueError("Must provide an even number of filenames.")

    # Make files in pairs
    filenames = [(filenames[i], filenames[i + 1])
                 for i in range(0, len(filenames), 2)]

    baseline_data_sum = None
    target_data_sum = None
    comparison_sum = None

    # Compare each pair
    for baseline_filename, target_filename in filenames:
        baseline_data = read_json_file(baseline_filename)
        target_data = read_json_file(target_filename)

        # get last folder name of baseline_filename
        baseline_folder_name = baseline_filename.split("/")[-2]

        # get last folder name of target_filename
        target_folder_name = target_filename.split("/")[-2]

        comparison = compare(baseline_data, target_data)
        print("\n<details><summary>Comparison for {} (Differences)</summary>\n".format(baseline_folder_name))
        print_table(baseline_data, target_data, comparison)
        print("</details>")

        if baseline_data_sum is None:
            baseline_data_sum = baseline_data
            target_data_sum = target_data
            comparison_sum = comparison
        else:
            sum_data(baseline_data_sum, baseline_data)
            sum_data(target_data_sum, target_data)
            sum_data(comparison_sum, comparison)

    pairs_cnt = len(filenames)

    # Average the sums
    avg_data(baseline_data_sum, pairs_cnt)
    avg_data(target_data_sum, pairs_cnt)
    avg_data(comparison_sum, pairs_cnt)

    print("\n**Average ({} datasets)**".format(pairs_cnt))
    print_table(baseline_data_sum, target_data_sum, comparison_sum)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Compare JSON performance files.")
    parser.add_argument(
        "files", nargs="+", help="List of pairs of JSON files to compare.")

    args = parser.parse_args()

    main(args.files)
