# Use the official Strapi image as a base image
FROM strapi/strapi

# Set environment variables
ENV NODE_ENV production

# Copy your Strapi project files
COPY ./my-project /srv/app

# Set the working directory
WORKDIR /srv/app

# Install dependencies
RUN npm install

# Expose the Strapi port
EXPOSE 1337

# Start the Strapi application
CMD ["npm", "start"]
