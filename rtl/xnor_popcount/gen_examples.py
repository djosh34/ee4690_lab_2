import random

def generate_random_vector(length):
    return ''.join(random.choice('01') for _ in range(length))

def xnor_vectors(vec_a, vec_b):
    return ''.join('1' if a == b else '0' for a, b in zip(vec_a, vec_b))

def count_ones(vec):
    return vec.count('1')

def generate_test_vectors(n, vector_length, file_name):
    with open(file_name, "w") as f:
        for _ in range(n):
            vec_a = generate_random_vector(vector_length)
            vec_b = generate_random_vector(vector_length)
            xnor_vec = xnor_vectors(vec_a, vec_b)
            ones_count = count_ones(xnor_vec)
            
            f.write(f"{vec_a}\n")
            f.write(f"{vec_b}\n")
            f.write(f"{xnor_vec}\n")
            f.write(f"{ones_count}\n")
            f.write("\n")

if __name__ == "__main__":
    n = 1000  # Number of test examples to generate
    vector_length = 64  # Length of each vector
    file_name = f"./xnor_popcount/examples/{n}_examples.txt"
    generate_test_vectors(n, vector_length, file_name)

