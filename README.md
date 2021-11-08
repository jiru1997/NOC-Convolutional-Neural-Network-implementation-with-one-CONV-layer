# NOC-Convolutional-Neural-Network-implementation-with-one-CONV-layer
NOC-Convolutional-Neural-Network-implementation with one CONV layer

In this project, we built four CNNs to take the knowledge we learned from classes and papers into practice. Based on the modules we built for homeworks, we implemented the basic network by which we can fetch data from a .txt file, perform convolution calculations, compare the final result with the golden result and report the errors. We also achieved some enhancements like 2D PEs arrays, convolutional layers and data pooling. By doing this project, we learned the basic calculation mechanism of machine learning, and enhanced our skills of using SystemVerilog and teamwork.

In the initialization state, all PEs will load corresponding data from memory by using the same scheme described in the 1D PE system. After each round of computation, PEs in the same group will exchange filter data and load a new row of feature map from memory. The sum module will receive the result of each PEs and classify them by using index and sum them together before sending them back to the memory. Finally, three 5x5 result matrices will be stored back to the memory module. 

You can use QuestaSim to build and run this project.

<img width="662" alt="image" src="https://user-images.githubusercontent.com/66343787/140835214-a5fe1048-080e-451a-bc26-75d99c470583.png">
