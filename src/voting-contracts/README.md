### Deployment Steps 
1. Rename `.env.sample` to `.env` and fill in your private key and 
provider uri from Infura API 
2. Run migrate command for your network e.g. for rinkeby
    ```sh
    truffle migrate --network rinkeby 
    ```
3. Get deployment addresses using 
   ```sh
   truffle networks 
   ```
