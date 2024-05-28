import numpy as np

# file is a binary file but in txt so
# each line looks like 0100011.....
# and needs to be divided into 64 bits chunks which is a 64 bit unsigned integer
def load(file_path, data):
    with open(file_path, 'r') as f:
        for i, line in enumerate(f):
            line = line.strip()
            for j in range(len(line) // bit_width):
                data[i, j] = int(line[j * bit_width:(j + 1) * bit_width], 2)

def load_label(file_path, data, zero_value=0):
    with open(file_path, 'r') as f:
        for i, line in enumerate(f):
            for (j, c) in enumerate(line.strip()):
                if c == '1':
                    data[i, j] = 1
                if c == '0':
                    data[i, j] = zero_value

def print_data(data, breaking=False):
    for i in range(data.shape[0]):
        for j in range(data.shape[1]):
            string_data = format(data[i, j], f'0{bit_width}b')
            # every 8 bits add a space
            for k in range(len(string_data)):
                print(string_data[k], end='')
                if k % 8 == 7:
                    print(' ', end='')

        print()
        if breaking:
            break
def print_real_data(data):
    for i in range(data.shape[0]):
        if data[i] == 1:
            print(1, end='')
        else:
            print(0, end='')
        if i % 8 == 7:
            print(' ', end='')
    print()

def xnor_vector(input_data, weight_vector, output_vector):
    for i in range(output_vector.shape[0]):
        output_vector[i] = ~(input_data[i] ^ weight_vector[i])

def xnor_matrix(input_data, weight_matrix, output_matrix):
    for i in range(weight_matrix.shape[0]):
        xnor_vector(input_data, weight_matrix[i], output_matrix[i])


def popcount_majority(xnored):
    # popcount is the number of 1s in the binary representation of the number
    return bin(xnored).count('1')


def faster_xnor_vector(input_data, weight_vector, bit_width=64):
    temp = 0
    for i in range(weight_vector.shape[0]):
        temp += popcount_majority(~(input_data[i] ^ weight_vector[i]))
        if temp >= weight_vector.shape[0] * bit_width // 2:
            return 1
    return 0


def faster_xnor_matrix(input_data, weight_matrix, output_matrix):
    for i in range(weight_matrix.shape[0]):
        output_matrix[i] = faster_xnor_vector(input_data, weight_matrix[i])


def convert_to_second_stage_input(faster_temp_matrix, second_stage_input):
    for i in range(faster_temp_matrix.shape[0]):
        item = np.uint64(faster_temp_matrix[i]) << np.uint64(63 - (i % bit_width))
        second_stage_input[0, i // bit_width] |= item
    pass


def perform_matrix_multiplication(input, weight_matrix_1, temp_matrix):
    # perform matrix multiplication with numpy
    # temp_matrix = np.dot(input, weight_matrix_1.T)
    np.dot(input, weight_matrix_1.T, out=temp_matrix)



    pass


if __name__ == '__main__':
    input_file = './1_test_data_bin.txt'
    label_file = './1_test_labels_bin.txt'
    # input_file = './20_test_data_bin.txt'
    # label_file = './20_test_labels_bin.txt'
    # input_file = './all_test_data_bin.txt'
    # label_file = './all_test_labels_bin.txt'

    weight_matrix_1_file = './fc1_weight_bin.txt'
    weight_matrix_2_file = './fc2_weight_bin.txt'

    input_size = 768
    hidden_size = 1024
    input_data_len = len(open(input_file).readlines())

    int_type = np.uint64
    real_int_type = np.int64
    bit_width = 64

    input_data = np.zeros((input_data_len, 768 // bit_width), dtype=int_type)
    real_input_data = np.zeros((input_data_len, 768), dtype=real_int_type)
    load(input_file, input_data)
    load_label(input_file, real_input_data, zero_value=-1)

    label = np.zeros((input_data_len, 10), dtype=int_type)
    load_label(label_file, label)

    weight_matrix_1 = np.zeros((1024, 768 // bit_width), dtype=int_type)
    real_weight_matrix_1 = np.zeros((1024, 768), dtype=real_int_type)
    load(weight_matrix_1_file, weight_matrix_1)
    load_label(weight_matrix_1_file, real_weight_matrix_1, zero_value=-1)

    weight_matrix_2 = np.zeros((10, 1024 // bit_width), dtype=int_type)
    real_weight_matrix_2 = np.zeros((10, 1024), dtype=real_int_type)
    load(weight_matrix_2_file, weight_matrix_2)
    load_label(weight_matrix_2_file, real_weight_matrix_2, zero_value=-1)

    correct = 0
    real_correct = 0

    for item_number in range(input_data_len):
    # for item_number in range(1):
    #     print(f'Item number: {item_number}')

        # print_data(input_data)
        # print_data(weight_matrix_1, breaking=True)

        temp_matrix = np.zeros((1024, 768 // bit_width), dtype=int_type)
        real_temp_matrix = np.zeros(1024, dtype=real_int_type)

        xnor_matrix(input_data[item_number], weight_matrix_1, temp_matrix)
        # print_data(temp_matrix, breaking=True)
        # temp matrix to 1024 x 768//64 of popcounts
        # use pythons int.bit_count() to get the popcount
        temp_matrix = np.vectorize(lambda x: bin(x).count('1'))(temp_matrix)
        # output the temp matrix to file like this
        # first take temp_matrix[0][0 to 11] where each number is one line
        # 36
        # 44
        # ....
        # then when you're done with a row add an empty line

        # with open(f'./rtl/predict/examples/temp_matrix_unsummed.txt', 'w') as f:
        #     for i in range(1024):
        #         for j in range(768 // bit_width):
        #             f.write(f'{temp_matrix[i][j]}\n')
        #         f.write('\n')

        temp_matrix = temp_matrix.sum(axis=1)

        # with open(f'./rtl/predict/examples/temp_matrix_summed.txt', 'w') as f:
        #     for i in range(1024):
        #         f.write(f'{temp_matrix[i]}\n')

        temp_matrix = temp_matrix >= 384

        # with open(f'./rtl/predict/examples/temp_matrix_binary.txt', 'w') as f:
        #     for i in range(1024):
        #         if temp_matrix[i] == True:
        #             f.write('1\n')
        #         else:
        #             f.write('0\n')

        # also perform a real matrix multiplication with each bit being one element
        perform_matrix_multiplication(real_input_data[item_number], real_weight_matrix_1, real_temp_matrix)

        # real temp matrix to either 1 or -1
        compare_real_temp_matrix = np.where(real_temp_matrix >= 0, 1, 0)
        if not (temp_matrix == compare_real_temp_matrix).all():
            print('Error matrices do not match:')
            print(temp_matrix)
            print(compare_real_temp_matrix)
            print()
        real_temp_matrix = np.where(real_temp_matrix >= 0, 1, -1)


        faster_temp_matrix = np.zeros(1024, dtype=int_type)
        faster_xnor_matrix(input_data[item_number], weight_matrix_1, faster_temp_matrix)

        # print((temp_matrix == faster_temp_matrix).all())

        second_stage_input = np.zeros((1, 1024 // bit_width), dtype=int_type)

        convert_to_second_stage_input(faster_temp_matrix, second_stage_input)

        # print_real_data(faster_temp_matrix)
        # print_real_data(real_temp_matrix)
        # print_data(second_stage_input, breaking=True)



        end_matrix = np.zeros((10, 1024 // bit_width), dtype=int_type)
        real_end_matrix = np.zeros(10, dtype=real_int_type)

        xnor_matrix(second_stage_input[0], weight_matrix_2, end_matrix)
        perform_matrix_multiplication(real_temp_matrix, real_weight_matrix_2, real_end_matrix)
        real_first_output = real_temp_matrix * real_weight_matrix_2[0]

        # print()
        # print_real_data(real_first_output)
        # print_data(end_matrix, breaking=True)

        # print_data(end_matrix, breaking=True)
        # print_real_data(real_end_matrix)

        end_matrix_ones = np.vectorize(lambda x: bin(x).count('1'))(end_matrix)
        # end_matrix_zeros = np.vectorize(lambda x: 64 - bin(x).count('1'))(end_matrix)

        end_matrix_ones = end_matrix_ones.sum(axis=1)
        # end_matrix_zeros = end_matrix_zeros.sum(axis=1)
        # end_matrix = end_matrix_ones - end_matrix_zeros
        end_matrix = end_matrix_ones

        # make endmatrix one hot encoded of the max value
        end_matrix = np.argmax(end_matrix)
        end_matrix = np.eye(10)[end_matrix]
        end_matrix = end_matrix.astype(int_type)

        # real end matrix choice
        real_end_matrix = np.argmax(real_end_matrix)
        real_end_matrix = np.eye(10)[real_end_matrix]
        real_end_matrix = real_end_matrix.astype(real_int_type)


        correct += (end_matrix == label[item_number]).all()
        real_correct += (real_end_matrix == label[item_number]).all()
        if item_number % 100 == 0:
            print(f'Correct: {correct} / {item_number + 1} \t Accuracy: {correct / (item_number + 1) * 100:.2f}%')
        # print(f'Real Correct: {real_correct} / {item_number + 1}')

            # print()
