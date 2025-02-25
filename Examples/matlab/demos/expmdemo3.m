function E = expmdemo3(A)
%EXPMDEMO3  Matrix exponential via eigenvalues and eigenvectors.
%   E = EXPMDEMO3(A) illustrates one possible way to compute the matrix
%   exponential.  As a practical numerical method, the accuracy
%   is determined by the condition of the eigenvector matrix.
%
%   See also EXPM, EXPMDEMO1, EXPMDEMO2.

%   Copyright 1984-2014 The MathWorks, Inc.

[V,D] = eig(A);
E = V * diag(exp(diag(D))) / V;
