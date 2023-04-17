import argparse
import json


def read_json_file(filename):
    with open(filename, 'r') as f:
        data = json.load(f)
    return data


def print_table(baseline_data, target_data, data):

    print("\n  Accuracy: {:.2%} vs {:.2%}".format(baseline_data["accuracy"], target_data["accuracy"]))
    print("\n                Label  |   Accuracy |     Recall |  Precision |         F1 |")
    print("  ==================== | ========== | ========== | ========== | ========== |")

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

        print("  -------------------- | ---------- | ---------- | ---------- | ---------- |")

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

    # Compare each pair
    for baseline_filename, target_filename in filenames:
        baseline_data = read_json_file(baseline_filename)
        target_data = read_json_file(target_filename)

        comparison = compare(baseline_data, target_data)
        print("\nComparison for {} vs {}: (Differences)".format(baseline_filename, target_filename))
        print_table(baseline_data, target_data, comparison)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Compare JSON performance files.")
    parser.add_argument(
        "files", nargs="+", help="List of pairs of JSON files to compare.")

    args = parser.parse_args()

    main(args.files)
