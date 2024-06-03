import numpy as np


def read_fc2_weights(file_path):
    with open(file_path, 'r') as f:
        lines = f.readlines()
    fc2_weights = np.array([[1 if char == '1' else -1 for char in line.strip()] for line in lines])
    return fc2_weights


def generate_input_row():
    return np.random.choice([1, -1], size=(1024))


def matrix_vector_multiply(fc2_weights, input_row):
    return np.dot(fc2_weights, input_row)


def one_hot_encode(sum_output_row):
    max_val = np.max(sum_output_row)
    return np.where(sum_output_row == max_val, 1, 0)


def convert_to_chars(arr):
    return ''.join(['1' if x == 1 else '0' for x in arr.flatten()])


def generate_test_cases(fc2_weights, generate_test_case_count, generated_input_file, generated_output_file):
    with open(generated_input_file, 'w') as input_file, open(generated_output_file, 'w') as output_file:
        for _ in range(generate_test_case_count):
            input_row = generate_input_row()
            sum_output_row = matrix_vector_multiply(fc2_weights, input_row)
            output_row = one_hot_encode(sum_output_row)

            input_line = convert_to_chars(input_row)
            output_line = convert_to_chars(output_row)

            input_file.write(input_line + '\n')
            output_file.write(output_line + '\n')

if __name__ == '__main__':

    # File paths
    fc2_weights_file = 'rtl/predict/weights/fc2_weight_bin.txt'
    generated_input_file = 'rtl/matrix_2_output/examples/input.txt'
    generated_output_file = 'rtl/matrix_2_output/examples/output.txt'
    generate_test_case_count = 10000  # Specify the number of test cases to generate

    # Execution
    fc2_weights = read_fc2_weights(fc2_weights_file)
    generate_test_cases(fc2_weights, generate_test_case_count, generated_input_file, generated_output_file)
