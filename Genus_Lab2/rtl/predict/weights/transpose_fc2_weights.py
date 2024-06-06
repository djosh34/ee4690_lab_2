import sys

def transpose_file(input_file, output_file):
    # Read the input file
    with open(input_file, 'r') as f:
        lines = [line.strip() for line in f.readlines()]

    # Ensure there are exactly 10 lines
    assert len(lines) == 10, "Input file must have exactly 10 lines"

    # Ensure each line is exactly 1024 characters
    for line in lines:
        assert len(line) == 1024, "Each line must be exactly 1024 characters"

    # Transpose the matrix
    transposed_lines = [''.join([lines[row][col] for row in range(10)]) for col in range(1024)]

    # Write the transposed matrix to the output file
    with open(output_file, 'w') as f:
        for line in transposed_lines:
            f.write(line + '\n')

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python transpose.py <input_file> <output_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]

    transpose_file(input_file, output_file)

