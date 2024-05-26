import torch
import torch.nn as nn
import torch.optim as optim
import torchvision
import torchvision.transforms as transforms
from torch.utils.data.dataloader import default_collate

torch.backends.quantized.engine = 'qnnpack'
#
# # Define a function to binarize the tensor
# def binarize(tensor):
#     return tensor.sign()
#
#
# # Define a custom binary layer
# class BinaryLayer(nn.Module):
#     def __init__(self, input_features, output_features):
#         super(BinaryLayer, self).__init__()
#         self.fc = nn.Linear(input_features, output_features)
#
#     def forward(self, x):
#         x = self.fc(x)
#         x = binarize(x)
#         return x


# Define the BNN model
class QNN(nn.Module):
    def __init__(self, k=8, hidden_size=1024):
        super(QNN, self).__init__()
        # self.fc1 = BinaryLayer(28 * 28, 256)
        # self.fc2 = BinaryLayer(256, 128)
        # self.fc3 = nn.Linear(128, 10)

        # self.fc1 = torch.ao.nn.quantized.Linear(28 * 28, 10, dtype=torch.qint8)

        self.fc1 = nn.Linear(28 * 28, hidden_size)
        self.relu = nn.ReLU()
        self.fc2 = nn.Linear(hidden_size, 10)

        self.quant = torch.quantization.QuantStub()
        self.dequant = torch.quantization.DeQuantStub()

        self.k = k

    def forward(self, x, round=32):
        x = x.view(-1, 28 * 28)

        if not self.training:
            x = torch.round(x * round) / round

        x = self.fc1(x)

        if not self.training:
            x = torch.round(x * round) / round


        x = self.relu(x)
        x = torch.div(x, 256)

        x = torch.clamp(x, -1, 1)

        if not self.training:
            x = torch.round(x * round) / round

        x = self.fc2(x)
        # x = torch.clamp(x, -1, 1)

        if not self.training:
            x = torch.round(x * round) / round

        # x = torch.round(x * self.k) / self.k
        return x


class QuantizationLoss(nn.Module):
    def __init__(self, k=8):
        super(QuantizationLoss, self).__init__()
        self.k = k

    def forward(self, model):
        quantization_loss = 0.0

        for param in model.parameters():
            # Quantize the parameter values
            quantized_param = torch.round(param.data * self.k) / self.k

            # Compute the squared difference
            squared_diff = (param.data - quantized_param)

            # Sum the squared differences
            quantization_loss += squared_diff.sum()

        return quantization_loss


class CombinedLoss(nn.Module):
    def __init__(self, quantization_loss_weight=0.1, k=8):
        super(CombinedLoss, self).__init__()
        self.cross_entropy_loss = nn.CrossEntropyLoss()
        self.quantization_loss = QuantizationLoss(k=k)
        self.quantization_loss_weight = quantization_loss_weight

    def forward(self, output, target, model):
        """
        Forward pass for the combined loss.

        Parameters:
        output (torch.Tensor): The model predictions.
        target (torch.Tensor): The true labels.
        model (torch.nn.Module): The model containing parameters to quantize.

        Returns:
        torch.Tensor: The combined loss.
        """
        ce_loss = self.cross_entropy_loss(output, target)
        q_loss = self.quantization_loss(model)

        combined_loss = ce_loss + self.quantization_loss_weight * q_loss

        return combined_loss




if __name__ == '__main__':


    device = "cpu"
    backend = "qnnpack"

    # Load MNIST dataset
    transform = transforms.Compose([transforms.ToTensor(), transforms.Normalize((0.5,), (0.5,))])
    trainset = torchvision.datasets.MNIST(root='./data', train=True, download=True, transform=transform)
    trainloader = torch.utils.data.DataLoader(trainset, batch_size=100, shuffle=True, collate_fn=lambda x: tuple(x_.to(device) for x_ in default_collate(x)))
    testset = torchvision.datasets.MNIST(root='./data', train=False, download=True, transform=transform)
    testloader = torch.utils.data.DataLoader(testset, batch_size=100, shuffle=False, collate_fn=lambda x: tuple(x_.to(device) for x_ in default_collate(x)))

    # Initialize the model, loss function, and optimizer
    model = QNN()
    # model.qconfig = torch.quantization.get_default_qat_qconfig(backend)

    # model_qat = torch.quantization.prepare_qat(model, inplace=False)
    model_qat = model

    # model_qat.to(device)
    # criterion = CombinedLoss(quantization_loss_weight=0.25, k=8)
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model_qat.parameters(), lr=0.001)

    # Training the BNN
    num_epochs = 20

    for epoch in range(num_epochs):
        model_qat.train()
        running_loss = 0.0
        for inputs, labels in trainloader:
            optimizer.zero_grad()

            inputs = inputs.to(device)
            labels = labels.to(device)

            outputs = model_qat(inputs)

            # loss = criterion(outputs, labels, model_qat)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            running_loss += loss.item()
        print(f'Epoch {epoch + 1}, Loss: {running_loss / len(trainloader)}')





    # Testing the BNN
    # model_qat = torch.quantization.convert(model_qat.eval(), inplace=False)
    model_qat.eval()


    # round the weights to signed 1 / 4-bit integers, so we have 16 unique values:
    # -8, -7, ..., 7 which are -1/8, -7/8, ..., 7/8 in float which will be the only values allowed in the weights
    # for the quantized model




    correct = 0
    total = 0
    with torch.no_grad():
        for inputs, labels in testloader:
            inputs.to(device)
            outputs = model_qat(inputs)
            _, predicted = torch.max(outputs.data, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()
    print(f'Accuracy of the network unrounded on the 10000 test images: {100 * correct / total} %')

    for param in model_qat.parameters():
        param.data = torch.round(param.data * 32) / 32
    torch.save(model.state_dict(), 'qnn_model.pth')


    for round in [32, 16, 8, 4, 2, 1]:
        for param in model_qat.parameters():
            param.data = torch.round(param.data * round) / round

        correct = 0
        total = 0
        with torch.no_grad():
            for inputs, labels in testloader:
                inputs.to(device)
                outputs = model_qat(inputs, round=round)
                _, predicted = torch.max(outputs.data, 1)
                total += labels.size(0)
                correct += (predicted == labels).sum().item()

        print(f'Accuracy of the network rounded {round} on the 10000 test images: {100 * correct / total} %')
