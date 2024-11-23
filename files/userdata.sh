#!/bin/bash

# Add the repository key 
# curl -fsSL https://example.com/gpg.key | sudo apt-key add -

# Add the repository to your sources list 
# echo "deb https://example.com/repo stable main" | sudo tee /etc/apt/sources.list.d/example.com.list

# Update package lists
sudo apt-get update

# Install the package (replace with your actual package name)
if sudo apt-get install -y nginx; then
  echo "Package installation successful!"

  # Start the application (replace with your application start command)
  sudo systemctl start nginx 

  echo "Application started."
else
  echo "Package installation failed!"
fi