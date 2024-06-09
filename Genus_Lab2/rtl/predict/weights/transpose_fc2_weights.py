import sys

def transpose_file(input_file, output_file, hidden_layer_size):
    # Read the input file
    with open(input_file, 'r') as f:
        lines = [line.strip() for line in f.readlines()]

    # Ensure there are exactly 10 lines
    assert len(lines) == 10, "Input file must have exactly 10 lines"

    # Ensure each line is exactly 1024 characters
    for line in lines:
        assert len(line) == hidden_layer_size, "Each line must be exactly 1024 characters"

    # Transpose the matrix
    transposed_lines = [''.join([lines[row][col] for row in range(10)]) for col in range(hidden_layer_size)]

    # Write the transposed matrix to the output file
    with open(output_file, 'w') as f:
        for line in transposed_lines:
            f.write(line + '\n')

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python transpose.py <input_file> <output_file> <hidden_layer_size>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    hidden_layer_size = int(sys.argv[3])

    transpose_file(input_file, output_file, hidden_layer_size)

