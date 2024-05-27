#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define INPUT_SIZE 768

#define BITWIDTH 64
#define INT_TYPE uint64_t

#define HIDDEN_SIZE 1024
#define OUTPUT_SIZE 10

void read_file(const char *filename, int rows, int cols, int data[rows][cols]) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("Unable to open file");
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < cols; ++j) {
            char c = fgetc(file);
            if (c == '0') {
                data[i][j] = -1;
            } else if (c == '1') {
                data[i][j] = 1;
            } else {
                --j; // Retry the current position if not 0 or 1
            }
        }
    }

    fclose(file);
}

// alternative way of reading file into array of rows * (INPUT_SIZE/BITWIDTH) * INT_TYPE
void read_file_alternative(const char *filename, int rows, int cols, INT_TYPE data[rows][cols / BITWIDTH]) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("Unable to open file");
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < cols; j += BITWIDTH) {
            printf("i: %d, j: %d\n", i, j);
            INT_TYPE value = 0;
            for (int k = 0; k < BITWIDTH; ++k) {
                char c = fgetc(file);
                if (c == '1') {
                    value |= 1 << k;
                } else if (c != '0') {
                    break;
                }
            }
            // print value in binary
//            for (int k = 0; k < BITWIDTH; ++k) {
//                printf("%d", (value >> (BITWIDTH - k - 1)) & 1);
//            }
//            printf("\n");
            data[i][j / BITWIDTH] = value;
        }
    }

    fclose(file);
}

void read_label_file(const char *filename, int rows, int cols, int data[rows][cols]) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("Unable to open file");
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < cols; ++j) {
            char c = fgetc(file);
            if (c == '0' || c == '1') {
                data[i][j] = c - '0';
            } else {
                --j; // Retry the current position if not 0 or 1
            }
        }
    }

    fclose(file);
}

void matmul_vector(int cols, int input[cols], int weights[HIDDEN_SIZE][cols], int Temp[HIDDEN_SIZE]) {
    for (int i = 0; i < HIDDEN_SIZE; ++i) {
        Temp[i] = 0;
        for (int j = 0; j < cols; ++j) {
            Temp[i] += input[j] * weights[i][j];
        }
    }
}

void matmul_output(int cols, int Temp[cols], int weights[OUTPUT_SIZE][cols], int Out[OUTPUT_SIZE]) {
    for (int i = 0; i < OUTPUT_SIZE; ++i) {
        Out[i] = 0;
        for (int j = 0; j < cols; ++j) {
            Out[i] += Temp[j] * weights[i][j];
        }
    }
}

void binarize_activation(int cols, int data[cols]) {
    for (int i = 0; i < cols; ++i) {
        data[i] = data[i] > 0 ? 1 : -1;
    }
}

int process_and_compare(int example, int fc1_weight[HIDDEN_SIZE][INPUT_SIZE], int fc2_weight[OUTPUT_SIZE][HIDDEN_SIZE], int test_data[INPUT_SIZE], int test_labels[OUTPUT_SIZE]) {
        int hidden_layer[HIDDEN_SIZE];
        int output_layer[OUTPUT_SIZE];

        // print the input data in chunks of 10, with the start index printed of each chunk
//        printf("Input data: ");
//        for (int j = 0; j < INPUT_SIZE; ++j) {
//            if (j % 10 == 0) {
//                printf("\n%d: ", j);
//            }
//            // make sure that the 1 and -1 take up the same amount of space
//            printf("%02d ", test_data[i][j]);
//        }

        // print fc1_weight in chunks of 10, with the start index printed of each chunk
//        printf("\nfc1_weight: ");
//        for (int j = 0; j < HIDDEN_SIZE; ++j) {
//            if (j % 10 == 0) {
//                printf("\n%d: \n", j);
//            }
//            for (int k = 0; k < INPUT_SIZE; ++k) {
//                if (k % 10 == 0) {
//                    printf("\n%d: ", k);
//                }
//                printf("%02d ", fc1_weight[j][k]);
//            }
//        }

        matmul_vector(INPUT_SIZE, test_data, fc1_weight, hidden_layer);

        // print the hidden layer in the same way as the input data
//        printf("\nHidden layer: ");
//        for (int j = 0; j < HIDDEN_SIZE; ++j) {
//            if (j % 10 == 0) {
//                printf("\n%d: ", j);
//            }
//            printf("%03d, ", hidden_layer[j]);
//        }


        binarize_activation(HIDDEN_SIZE, hidden_layer);

        // print the binarized hidden layer
//        printf("\nBinarized hidden layer: ");
//        for (int j = 0; j < HIDDEN_SIZE; ++j) {
//            printf("%d ", hidden_layer[j]);
//        }

        matmul_output(HIDDEN_SIZE, hidden_layer, fc2_weight, output_layer);

        // print the output layer
//        printf("\nOutput layer: ");
//        for (int j = 0; j < OUTPUT_SIZE; ++j) {
//            printf("%d ", output_layer[j]);
//        }

        int predicted_label = 0;
        int max_value = output_layer[0];
        for (int j = 1; j < OUTPUT_SIZE; ++j) {
            if (output_layer[j] > max_value) {
                max_value = output_layer[j];
                predicted_label = j;
            }
        }

        int correct_label = 0;
        for (int j = 0; j < OUTPUT_SIZE; ++j) {
            if (test_labels[j] == 1) {
                correct_label = j;
                break;
            }
        }

        if (predicted_label != correct_label) {
//            printf("Example %d - Predicted label: %d, Correct label: %d\n", example + 1, predicted_label, correct_label);
            return 0;
        }

        return 1;
//        printf("Example %d - Predicted label: %d, Correct label: %d\n", i + 1, predicted_label, correct_label);

//        if (predicted_label == correct_label) {
//            printf("Prediction is correct.\n");
//        } else {
//            printf("Prediction is incorrect.\n");
//        }
}


int majority(int output_cols, INT_TYPE input[INPUT_SIZE], INT_TYPE weights[INPUT_SIZE]) {
}

void xnor_majority(int output_cols, INT_TYPE input[INPUT_SIZE / BITWIDTH], INT_TYPE weights[HIDDEN_SIZE][INPUT_SIZE / BITWIDTH], INT_TYPE output[output_cols]) {
    for (int i = 0; i < output_cols; ++i) {
        INT_TYPE layer_weights[INPUT_SIZE / BITWIDTH];
        for (int j = 0; j < INPUT_SIZE / BITWIDTH; ++j) {
            layer_weights[j] = weights[i][j] ^ input[j];
        }
        majority(output_cols, input, layer_weights);
    }
}

int process_and_compare_alternative(int example, INT_TYPE fc1_weight[HIDDEN_SIZE][INPUT_SIZE / BITWIDTH], INT_TYPE fc2_weight[OUTPUT_SIZE][HIDDEN_SIZE / BITWIDTH], INT_TYPE test_data[INPUT_SIZE], int test_labels[OUTPUT_SIZE]) {
    int hidden_layer[HIDDEN_SIZE];
    INT_TYPE hidden_layer_alternative[HIDDEN_SIZE / BITWIDTH];
    INT_TYPE output_layer[OUTPUT_SIZE / BITWIDTH];

    xnor_majority(HIDDEN_SIZE, test_data, fc1_weight, hidden_layer);

    return 0;
}



int main(int argc, char *argv[]) {
    if (argc < 5) {
        fprintf(stderr, "Usage: %s <weight1> <weight2> <datafile> <labelfile>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    int fc1_weight[HIDDEN_SIZE][INPUT_SIZE];
    int fc2_weight[OUTPUT_SIZE][HIDDEN_SIZE];


    read_file(argv[1], HIDDEN_SIZE, INPUT_SIZE, fc1_weight);
    read_file(argv[2], OUTPUT_SIZE, HIDDEN_SIZE, fc2_weight);

    INT_TYPE fc1_weight_alternative[HIDDEN_SIZE][INPUT_SIZE / BITWIDTH];
    INT_TYPE fc2_weight_alternative[OUTPUT_SIZE][HIDDEN_SIZE / BITWIDTH];

    read_file_alternative(argv[1], HIDDEN_SIZE, INPUT_SIZE, fc1_weight_alternative);
    read_file_alternative(argv[2], OUTPUT_SIZE, HIDDEN_SIZE, fc2_weight_alternative);

    FILE *data_file = fopen(argv[3], "r");
    FILE *label_file = fopen(argv[4], "r");

    if (!data_file || !label_file) {
        perror("Unable to open data or label file");
        exit(EXIT_FAILURE);
    }

    // Count the number of lines in the data file
    int num_examples = 0;
    char c;
    while ((c = fgetc(data_file)) != EOF) {
        if (c == '\n') {
            num_examples++;
        }
    }
    rewind(data_file);

    int (*test_data)[INPUT_SIZE] = malloc(num_examples * INPUT_SIZE * sizeof(int));
    int (*test_labels)[OUTPUT_SIZE] = malloc(num_examples * OUTPUT_SIZE * sizeof(int));

    INT_TYPE (*test_data_alternative)[INPUT_SIZE / BITWIDTH] = malloc(num_examples * (INPUT_SIZE / BITWIDTH) * sizeof(INT_TYPE));
    int (*test_labels_alternative)[OUTPUT_SIZE] = malloc(num_examples * OUTPUT_SIZE * sizeof(int));

    if (!test_data || !test_labels || !test_data_alternative || !test_labels_alternative) {
        perror("Memory allocation failed");
        exit(EXIT_FAILURE);
    }

    read_file(argv[3], num_examples, INPUT_SIZE, test_data);
    read_label_file(argv[4], num_examples, OUTPUT_SIZE, test_labels);

    rewind(data_file);
    rewind(label_file);

    read_file_alternative(argv[3], num_examples, INPUT_SIZE, test_data_alternative);
    read_label_file(argv[4], num_examples, OUTPUT_SIZE, test_labels_alternative);

    fclose(data_file);
    fclose(label_file);
    int result = 0;

    for (int i = 0; i < num_examples; ++i) {
        result += process_and_compare(i, fc1_weight, fc2_weight, test_data[i], test_labels[i]);
        process_and_compare_alternative(i, fc1_weight_alternative, fc2_weight_alternative, test_data_alternative[i], test_labels_alternative[i]);
        if (i % 100 == 0) {
            printf("\rProcessed %d out of %d examples", i, num_examples);
            fflush(stdout);
        }
    }

    printf("\nAccuracy: %f\n", (float) result / num_examples * 100);

    free(test_data);
    free(test_labels);

    return 0;
}
