FROM node:10

WORKDIR /app

RUN git clone https://github.com/andmulLABS01/Deployment_9 .

WORKDIR /app/frontend

RUN npm install --save-dev @babel/plugin-proposal-private-property-in-object

RUN npm install

EXPOSE 3000

CMD ["npm", "start"]