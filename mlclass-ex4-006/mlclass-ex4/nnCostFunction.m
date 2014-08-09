function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%



a1 = [ones(m,1) X];
z2 = a1*(Theta1)';
a2 = sigmoid(z2);
a2 = [ones(m, 1) a2];
z3 = a2*(Theta2)';
a3 = sigmoid(z3);

% compute cost function without regularization
%{ method1:
for i=1:m
	y_mat = zeros(1, num_labels);
	y_mat(y(i)) = 1;
	Ji = 1/m *sum(-y_mat .* log(a3(i,:)) - (1 - y_mat) .* log(1 - a3(i,:)));
	J += Ji;
end
%}

% method2:
y_matrix = eye(num_labels)(y,:);

J = 1/m * sum(sum(-1 * y_matrix .* log(a3) - (1 - y_matrix) .* log(1 - a3)));

%--------------------------------------------------------------
% compute cost function with regularization 
regularization = lambda / (2*m) * (sum(sum((Theta1(:,2:end)) .^ 2)) + sum(sum((Theta2(:,2:end)) .^ 2)));
J += regularization;
	
%--------------------------------------------------------------
% compute gradient with Backpropagation algorithm
delta1_sum = zeros(hidden_layer_size, input_layer_size + 1);
delta2_sum = zeros(num_labels, hidden_layer_size + 1);

a1 = [ones(m,1) X];		%matrix 5000x401
z2 = a1*(Theta1)';		%5000x25
a2 = sigmoid(z2);
a2 = [ones(m, 1) a2];	%matrix 5000x26
z3 = a2*(Theta2)';		%5000x10
a3 = sigmoid(z3);		%matrix 5000x10

%Theta1	matrix 25x401
%Theta2 matrix 10x26

%{ compute gradient method1:
for i = 1:m
	y_mat= zeros(1, num_labels);
	y_mat(y(i)) = 1;
	delta3 = a3(i,:) - y_mat;		% matrix 1x10
	delta2 = delta3 * (Theta2(:, 2:end)) .* sigmoidGradient(z2(i, :));
	%delta2 = delta2(2:end);		% matrix 1x25
	delta1_sum = delta1_sum + (delta2)' * a1(i,:); 	% matrix 25x401
	delta2_sum =  delta2_sum + (delta3)' * a2(i,:);	% matrix 10x26

end

Theta1_grad = 1/m * delta1_sum;
Theta2_grad = 1/m * delta2_sum;
%}


%compute gradient method2
delta3 = a3 - y_matrix;			% matrix 5000x10
delta2 = delta3 * Theta2(:, 2:end) .*sigmoidGradient(z2);		% matrix 5000x25

delta1_sum = (delta2)' * a1;	%result: matrix 25x401
delta2_sum = (delta3)' * a2;	%result: matrix 10x26

Theta1_grad = 1/m * delta1_sum;
Theta2_grad = 1/m * delta2_sum;



%--------------------------------------------------------------
% compute gradient Regularization
Theta1_grad += lambda/m * [zeros(hidden_layer_size, 1) Theta1(:, 2:end)];
Theta2_grad += lambda/m * [zeros(num_labels, 1) Theta2(:, 2:end)];



% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];



end
