import sys

def read_template_file(template_file):
    with open(template_file, 'r') as file:
        template_content = file.read()
    return template_content

def read_weights_file(weights_file):
    with open(weights_file, 'r') as file:
        weights_lines = file.readlines()
    return [line.strip() for line in weights_lines]

def generate_vhdl(template_content, weights_lines):
    weights_array_entries = []
    for i, line in enumerate(weights_lines):
        weights_array_entries.append(f'      weights_array({i}) := "{line}";')
    weights_array_str = '\n'.join(weights_array_entries)
    
    return template_content.replace('$WEIGHTS_ARRAY', weights_array_str)

def write_vhdl_file(output_file, content):
    with open(output_file, 'w') as file:
        file.write(content)

def main(template_file, weights_file, output_file):
    template_content = read_template_file(template_file)
    weights_lines = read_weights_file(weights_file)
    vhdl_content = generate_vhdl(template_content, weights_lines)
    write_vhdl_file(output_file, vhdl_content)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <template_file> <weights_file> <output_file>")
        sys.exit(1)

    template_file = sys.argv[1]
    weights_file = sys.argv[2]
    output_file = sys.argv[3]
    
    main(template_file, weights_file, output_file)

