import argparse
import json


def read_json_file(filename):
    with open(filename, 'r') as f:
        data = json.load(f)
    return data

def sum_data(data_sum, data):
    data_sum["accuracy"] += data["accuracy"]
    for label in data["labels"]:
        if label in data_sum["labels"]:
            data_sum["labels"][label]["accuracy"] += data["labels"][label]["accuracy"]
            data_sum["labels"][label]["recall"] += data["labels"][label]["recall"]
            data_sum["labels"][label]["precision"] += data["labels"][label]["precision"]
            data_sum["labels"][label]["f1"] += data["labels"][label]["f1"]
        else:
            data_sum["labels"][label] = data["labels"][label]

def avg_data(data_sum, n):
    data_sum["accuracy"] /= n
    for label in data_sum["labels"]:
        data_sum["labels"][label]["accuracy"] /= n
        data_sum["labels"][label]["recall"] /= n
        data_sum["labels"][label]["precision"] /= n
        data_sum["labels"][label]["f1"] /= n

def print_table(baseline_data, target_data, data):

    print("\n  Accuracy: {:.2%} vs {:.2%}".format(baseline_data["accuracy"], target_data["accuracy"]))
    print("\n                Label  |   Accuracy |     Recall |  Precision |         F1 |")
    print("  -------------------- | ---------- | ---------- | ---------- | ---------- |")

    all_labels = set(baseline_data["labels"].keys()) | set(target_data["labels"].keys())
    for label in all_labels:
        if label in baseline_data["labels"] and label in target_data["labels"]:
            print("                       | {:10.2%} | {:10.2%} | {:10.2%} | {:10.2%} |".format(
                baseline_data["labels"][label]["accuracy"], baseline_data["labels"][label]["recall"], baseline_data["labels"][label]["precision"], baseline_data["labels"][label]["f1"]))
            print("  {:20} | {:10.2%} | {:10.2%} | {:10.2%} | {:10.2%} |".format(
                label, target_data["labels"][label]["accuracy"], target_data["labels"][label]["recall"], target_data["labels"][label]["precision"], target_data["labels"][label]["f1"]))
            print("                       | {:10.2%} | {:10.2%} | {:10.2%} | {:10.2%} |".format(
                data["labels"][label]["accuracy"], data["labels"][label]["recall"], data["labels"][label]["precision"], data["labels"][label]["f1"]))
        else:
            print("  {:20} | {:10.2%} | {:10.2%} | {:10.2%} | {:10.2%} |".format(
                label, data["labels"][label]["accuracy"], data["labels"][label]["recall"], data["labels"][label]["precision"], data["labels"][label]["f1"]))

        print("                       |            |            |            |            |")

def compare(baseline, target):
    comparison = {
        "accuracy": (target["accuracy"] - baseline["accuracy"]) / baseline["accuracy"],
        "labels": {}
    }
    labels = set(baseline["labels"].keys()) | set(target["labels"].keys())

    for label in labels:
        if label in baseline["labels"] and label in target["labels"]:
            comparison["labels"][label] = {key: (target["labels"][label][key] - baseline["labels"][label][key]) / baseline["labels"][label][key]
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
    filenames = [(filenames[i], filenames[i + 1]) for i in range(0, len(filenames), 2)]

    baseline_data_sum = None
    target_data_sum = None
    comparison_sum = None

    # Compare each pair
    for baseline_filename, target_filename in filenames:
        baseline_data = read_json_file(baseline_filename)
        target_data = read_json_file(target_filename)

        comparison = compare(baseline_data, target_data)
        print("\nComparison for {} vs {}: (Differences)".format(baseline_filename, target_filename))
        print_table(baseline_data, target_data, comparison)

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

    print("\nAverage comparison for {} pairs:".format(pairs_cnt))
    print_table(baseline_data_sum, target_data_sum, comparison_sum)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Compare JSON performance files.")
    parser.add_argument(
        "files", nargs="+", help="List of pairs of JSON files to compare.")

    args = parser.parse_args()

    main(args.files)
