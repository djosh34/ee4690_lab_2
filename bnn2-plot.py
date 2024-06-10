import os
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np


def load_data(folder_path, hidden_sizes):
    results = []
    for file_name in os.listdir(folder_path):
        if file_name.endswith(".csv") and 'accuracy_numpy_' in file_name and not "best" in file_name:
            # Extract hidden size from file name
            hidden_size = int(file_name.split('_')[-1].split('.')[0])
            if hidden_size in hidden_sizes:
                file_path = os.path.join(folder_path, file_name)
                df = pd.read_csv(file_path)
                epochs = df['epoch'].values
                accuracies = df['accuracy'].values
                results.append((hidden_size, epochs, accuracies))
    return results


def smooth_data(data, window_size=1):
    return np.convolve(data, np.ones(window_size) / window_size, mode='valid')


def plot_line_chart(results, low=0.80, high=0.96):
    # Sort results by hidden size in ascending order
    results.sort(key=lambda x: x[0])

    plt.figure(figsize=(12, 6))
    for hidden_size, epochs, accuracies in results:
        # Smooth the accuracy values
        smoothed_accuracies = smooth_data(accuracies)
        # Adjust the epochs to match the length of smoothed data
        smoothed_epochs = epochs[:len(smoothed_accuracies)]
        plt.plot(smoothed_epochs, smoothed_accuracies, label=f'Hidden Size {hidden_size}')

    plt.ylim(low, high)  # y-axis limits
    plt.yticks(np.arange(low, high + 0.01, 0.01))
    plt.title('Epochs vs. Accuracy for Different Hidden Layer Sizes')
    plt.xlabel('Epoch')
    plt.ylabel('Accuracy (%)')

    # Place the legend outside the plot area on the right with space
    plt.legend(title='Hidden Layer Size', bbox_to_anchor=(1.05, 1), loc='upper left')
    plt.grid(True)
    plt.tight_layout()
    plt.show()


def plot_chunky_rectangles(results):
    # Sort results by hidden size in ascending order
    results.sort(key=lambda x: x[0])

    hidden_sizes = [hidden_size for hidden_size, _, _ in results]
    max_accuracies = [max(accuracies) for _, _, accuracies in results]

    bar_width = 0.8  # Make bars wider
    bar_positions = range(len(hidden_sizes))

    plt.figure(figsize=(12, 6))
    colors = plt.cm.tab20(range(len(hidden_sizes)))  # Default color map for bars

    bars = plt.bar(bar_positions, max_accuracies, color=colors, edgecolor='black', width=bar_width)

    plt.title('Maximum Accuracy for Different Hidden Layer Sizes')
    plt.xlabel('Hidden Layer Size')
    plt.ylabel('Maximum Accuracy (%)')
    plt.ylim(0.88, 0.97)  # Limiting the Y-axis
    plt.xticks(bar_positions, hidden_sizes)

    # Adding values on top of the bars
    for bar in bars:
        height = bar.get_height()
        plt.text(bar.get_x() + bar.get_width() / 2.0, height + 0.002, f'{height:.3f}',
                 ha='center', va='bottom', fontsize=12)  # Larger text and more distance from bars

    plt.grid(axis='y', linestyle='--', alpha=0.7)
    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    folder_path = "save_accuracy"  # Update this to your actual folder path

    # Define hidden sizes inside main block
    # hidden_sizes = [x for x in range(512, 1024, 32)]

    # hidden_sizes = [64, 128, 256, 512]
    # hidden_sizes = hidden_sizes + [768, 768 + 1 * 32, 768 + 2 * 32, 768 + 3 * 32, 768 + 4 * 32, 768 + 5 * 32, 768 + 6 * 32, 768 + 7 * 32,
    #                 768 + 8 * 32]
    # hidden_sizes = hidden_sizes + [1024 + 1 * 256, 1024 + 2 * 256, 1024 + 3 * 256, 1024 + 4 * 256]
    hidden_sizes = [64, 256, 512, 1024, 2048, 4096]

    results = load_data(folder_path, hidden_sizes)

    # Plotting both charts
    plot_line_chart(results)
    plot_chunky_rectangles(results)
