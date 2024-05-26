import numpy as np
import torch
from bnn import QNN
import torchvision.transforms as transforms
import torchvision.datasets as datasets


class NumpyQNN:
    def __init__(self, weight_file):
        self.load_weights_from_pytorch(weight_file)

    def load_weights_from_pytorch(self, weight_file):
        model = QNN()
        model.load_state_dict(torch.load(weight_file))
        fc1_weight = model.fc1.weight.detach().numpy()
        fc1_bias = model.fc1.bias.detach().numpy()
        fc2_weight = model.fc2.weight.detach().numpy()
        fc2_bias = model.fc2.bias.detach().numpy()

        self.fc1_weight = fc1_weight * 32
        self.fc1_bias = fc1_bias * 32
        self.fc2_weight = fc2_weight * 32
        self.fc2_bias = fc2_bias * 32

        self.fc1_weight_q = self.fc1_weight.astype(np.int32)
        self.fc1_bias_q = self.fc1_bias.astype(np.int32)
        self.fc2_weight_q = self.fc2_weight.astype(np.int32)
        self.fc2_bias_q = self.fc2_bias.astype(np.int32)



    def relu(self, x):
        return np.maximum(0, x)

    def forward(self, x):
        saved_x = x.copy()

        x = x.flatten()
        x_q = saved_x.flatten()

        x = np.dot(self.fc1_weight, x) + self.fc1_bias
        # x_q = x_q * 32
        x_q = np.dot(self.fc1_weight_q, x_q) + self.fc1_bias_q

        x = self.relu(x)
        x_q = self.relu(x_q)

        x = np.clip(x, -1, 1)
        x_q = x_q / 256
        x_q = np.clip(x_q, -32, 32)

        x = np.dot(self.fc2_weight, x) + self.fc2_bias
        x_q = np.dot(self.fc2_weight_q, x_q) + self.fc2_bias_q






        return x_q




def load_mnist_test_data():
    transform = transforms.Compose([transforms.ToTensor(), transforms.Normalize((0.5,), (0.5,))])
    testset = datasets.MNIST(root='./data', train=False, download=True, transform=transform)
    testloader = torch.utils.data.DataLoader(testset, batch_size=1, shuffle=False)
    return testloader


def evaluate_numpy_model(model, testloader):
    correct = 0
    total = 0
    for data in testloader:
        inputs, labels = data
        inputs = inputs.numpy().astype(np.int8).squeeze()  # Remove batch dimension and convert to int8
        # inputs = inputs * 32
        labels = labels.numpy()

        outputs = model.forward(inputs)
        predicted = np.argmax(outputs)

        total += labels.size
        correct += (predicted == labels).sum()

    accuracy = 100 * correct / total
    return accuracy

if __name__ == '__main__':
    # Example usage
    numpy_model = NumpyQNN('qnn_model.pth')

    # Load test data
    testloader = load_mnist_test_data()

    # Evaluate the Numpy model
    accuracy = evaluate_numpy_model(numpy_model, testloader)
    print(f'Accuracy of the Numpy model on the 10000 test images: {accuracy} %')