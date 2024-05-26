import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
import torchvision
import torchvision.transforms as transforms
from torch.utils.data.dataloader import default_collate

torch.backends.quantized.engine = 'qnnpack'


def activation(x):
    # BNN-RBNT
    # 2 * sigmoid(beta * x)(1 + beta * sigmoid(beta * x)) - 1
    beta = 5

    return 2 * torch.sigmoid(beta * x) * (1 + beta * torch.sigmoid(beta * x)) - 1

    # return nn.Hardtanh(-1, 1)(x)


# Define the BNN model
class BNN(nn.Module):
    def __init__(self, hidden_size=128):
        super(BNN, self).__init__()

        kernel_size_1 = 16
        kernel_size_2 = 29 - kernel_size_1
        # kernel_size_2 = 5
        # intermediate_size = 32
        intermediate_size = hidden_size

        # self.fc1 = nn.Conv2d(in_channels=1, kernel_size=kernel_size_1, out_channels=intermediate_size)
        self.fc1 = nn.Linear(28 * 28, intermediate_size, bias=False)
        self.clip1 = nn.Hardtanh(-1, 1)


        # self.fc2 = nn.Conv2d(in_channels=intermediate_size, kernel_size=kernel_size_2, out_channels=1)
        # self.fc2 = nn.Conv2d(in_channels=intermediate_size, kernel_size=kernel_size_2, out_channels=10)
        self.fc2 = nn.Linear(intermediate_size, 10, bias=False)

        # self.clip2 = nn.Hardtanh(-1, 1)
        #
        # self.fc3 = nn.Conv2d(in_channels=1, kernel_size=20, out_channels=10)




    def forward(self, x):
        # x = x.view(-1, 1, 28, 28)
        x = x.view(-1, 1, 28 * 28)

        # print(f'input: {x[0, 0]}')
        x = self.fc1(x)
        # print(f'fc1: {x[0, 0]}')
        x = self.clip1(x)
        x = self.fc2(x)
        # x = self.clip2(x)
        # x = self.fc3(x)

        # reshape into batch_size x 10
        x = x.view(-1, 10)

        return x


def train(model, trainloader):
    # Initialize the model, loss function, and optimizer
    model.to(device)

    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=learning_rate)

    # Training the BNN

    for epoch in range(num_epochs):
        model.train()
        running_loss = 0.0
        current_done_batch = 0
        for inputs, labels in trainloader:
            optimizer.zero_grad()

            inputs = inputs.to(device)
            labels = labels.to(device)

            outputs = model(inputs)

            # labels into one-hot encoding
            labels = torch.nn.functional.one_hot(labels, num_classes=10).float()

            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            running_loss += loss.item()
            current_done_batch += batch_size
            # print(f'Batch {current_done_batch} / {len(trainloader) * batch_size}')
        print()
        print(f'Epoch {epoch + 1}, Loss: {running_loss / len(trainloader)}')
        test_numpy(model, testloader)
        test_normal(model, testloader)
        print()




def test_normal(model, testloader):
    correct = 0
    total = 0
    with torch.no_grad():
        for inputs, labels in testloader:
            inputs.to(device)
            outputs = model(inputs)
            _, predicted = torch.max(outputs.data, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()
    print(f'Accuracy of the network unrounded on the 10000 test images: {100 * correct / total} %')


def extract_weights(model):
    weights = {}
    for name, param in model.named_parameters():
        weights[name] = param.detach().cpu().numpy()
    return weights


def binarize_weights(weights):
    binarized_weights = {}
    for name, weight in weights.items():
        binarized_weights[name] = np.sign(weight).astype(np.int32)
        # binarized_weights[name] = np.array(weight, dtype=np.float32)
        # binarized_weights[name] = np.array(weight * 64, dtype=np.int32)
    return binarized_weights


def hardtanh(x, min_val=-1, max_val=1):
    # return np.maximum(np.minimum(x, max_val), min_val)
    return np.sign(x)

def numpy_conv2d(input_data, weights, bias=None):
    batch_size, in_channels, in_height, in_width = input_data.shape
    out_channels, _, kernel_height, kernel_width = weights.shape

    out_height = (in_height - kernel_height) + 1
    out_width = (in_width - kernel_width) + 1

    output = np.zeros((batch_size, out_channels, out_height, out_width))

    # print(f'input_data: {input_data[0, 0]}')

    for b in range(batch_size):
        for oc in range(out_channels):
            for ic in range(in_channels):
                # output[b, oc] += convolve2d(input_data[b, ic], weights[oc, ic], mode='valid')
                for i in range(out_height):
                    for j in range(out_width):
                        window = input_data[b, ic, i:i + kernel_height, j:j + kernel_width]
                        weights_window = weights[oc, ic]
                        sum = np.sum(window * weights_window)
                        output[b, oc, i, j] += sum
            # if bias is not None:
            #     output[b, oc] += bias[oc]

    # print(f'output: {output[0, 0]}')

    return output

def linear(input_data, weights):

    # using numpy dot product
    output = np.dot(input_data, weights.T)


    # for b in range(batch_size):
    #     for of in range(out_features):
    #         for if_ in range(in_features):
    #             output[b, of] += input_data[b, if_] * weights[of, if_]
    #         if bias is not None:
    #             output[b, of] += bias[of]

    return output

def numpy_model_forward(x, weights):
    x = x.reshape(-1, 28 * 28)
    # First convolutional layer
    fc1_weight = weights['fc1.weight']
    # fc1_bias = weights['fc1.bias']
    # x = numpy_conv2d(x, fc1_weight, fc1_bias)
    x = linear(x, fc1_weight)
    # x = hardtanh(x)
    x = np.where(x > 0, 1, -1)

    # Second convolutional layer
    fc2_weight = weights['fc2.weight']
    # x = numpy_conv2d(x, fc2_weight)
    x = linear(x, fc2_weight)

    # Reshape into batch_size x 10
    x = x.reshape(-1, 10)

    return x

def test_numpy(model, testloader):
    # Extract weights from the PyTorch model
    weights = extract_weights(model)
    weights = binarize_weights(weights)

    # Evaluate the NumPy model
    correct = 0
    total = 0

    with torch.no_grad():
        for data, target in testloader:
            np_data = data.cpu().numpy().astype(np.int32)
            np_target = target.cpu().numpy()

            # output = model(data)
            np_output = numpy_model_forward(np_data, weights)
            # pred = torch.argmax(output, dim=1).numpy()
            np_pred = np.argmax(np_output, axis=1)



            new_correct = (np_pred == np_target).sum()
            correct += new_correct
            total += np_target.size
            # print(f'Correct: {correct / total: .2f}, total: {total} / {len(testloader.dataset)}')

    accuracy = correct / total
    print(f'Accuracy of the NumPy model: {accuracy * 100:.2f}%')



if __name__ == '__main__':


    # training = True
    training = False
    device = "mps"
    # device = "cpu"

    batch_size = 2048
    test_batch_size = 20
    num_epochs = 10
    learning_rate = 0.0005
    hidden_size = 128

    # Load MNIST dataset
    # transform = transforms.Compose([transforms.ToTensor(), transforms.Normalize((0.5,), (0.5,))])
    # transform that everything is if x > 0 then 1 else -1
    transform = transforms.Compose([transforms.ToTensor(), transforms.Lambda(lambda x: np.where(x > 0, 1, -1).astype(np.float32))])

    trainset = torchvision.datasets.MNIST(root='./data', train=True, download=True, transform=transform)
    trainloader = torch.utils.data.DataLoader(trainset, batch_size=batch_size, shuffle=True, collate_fn=lambda x: tuple(x_.to(device) for x_ in default_collate(x)))
    # trainloader = torch.utils.data.DataLoader(trainset, batch_size=1000, shuffle=True)
    testset = torchvision.datasets.MNIST(root='./data', train=False, download=True, transform=transform)
    testloader = torch.utils.data.DataLoader(testset, batch_size=test_batch_size, shuffle=False, collate_fn=lambda x: tuple(x_.to(device) for x_ in default_collate(x)))
    # testloader = torch.utils.data.DataLoader(testset, batch_size=1000, shuffle=False)

    # Train the BNN
    if training:
        model = BNN(hidden_size=hidden_size)
        train(model, trainloader)


        # save the model
        test_normal(model, testloader)
        torch.save(model.state_dict(), 'bnn_model.pth')


    model = BNN(hidden_size=hidden_size)
    model.load_state_dict(torch.load('bnn_model.pth'))

    # Testing the BNN
    model.eval()

    test_numpy(model, testloader)



