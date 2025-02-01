#!/usr/bin/env python3

def calculate_gc_content(sequence):
    """
    Calculate the GC content of a DNA sequence.
    """
    sequence = sequence.upper()  # Ensure the sequence is in uppercase
    gc_count = sequence.count('G') + sequence.count('C')
    total_length = len(sequence)
    gc_content = (gc_count / total_length) * 100 if total_length > 0 else 0
    return gc_content

def main():
    """
    Main function to execute the GC content analysis.
    """
    print("GC Content Analyzer")
    print("-------------------")
    print("Enter a DNA sequence (or 'exit' to quit):")

    while True:
        sequence = input("> ").strip().upper()  # Get user input and clean it
        if sequence == "EXIT":
            print("Exiting the program. Goodbye!")
            break
        if not all(base in "ACGT" for base in sequence):  # Validate the sequence
            print("Invalid DNA sequence. Please enter only A, C, G, or T.")
            continue
        gc_content = calculate_gc_content(sequence)
        print(f"GC Content: {gc_content:.2f}%")

if __name__ == "__main__":
    main()
