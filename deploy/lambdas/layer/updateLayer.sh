npm run build && \
aws s3 cp layer.zip \
    s3://matlau-lambdas-bucket/v1.0.0/layer.zip 