# Room Reservation Contract - Blockstack Clarity

## Scenario

This is a scenario where **user** are **Customer** and **hotel owner** are **Owner**.
**Customer** can reserve a room from a hotel through a website/application and **Owner** can receive the the payment through the contract

1. Important variables are set first before the next contract.
2. **Customer** should check first if he/she has the right amount of stack for the downpayment.
3. **Customer** also needs to check if its still available for rent.
4. **Customer** should deposit the downpayment in the **Owner**'s account in order to reserve the room.
5. **Customer** should deposit the remaining balance in the **Owner**'s account to get the room.

## Run the project step by step

### Set up room-reservation-clarity
Open a new terminal and run
```
git clone https://github.com/FhilF/room-reservation-clarity.git
cd room-reservation-clarity
npm install
```

### Generate keys for the Customer and Owner
In the current terminal run
```
npx blockstack-cli@1.1.0-beta.1 make_keychain -t > owner-keys.json
npx blockstack-cli@1.1.0-beta.1 make_keychain -t > customer-keys.json
```

### Set up testnet
Open a new terminal for testnet and run the coomands
```
git clone https://github.com/blockstack/stacks-blockchain.git
cd stacks-blockchain
cargo testnet start --config=testnet/stacks-node/Stacks.toml
```

### Before running testnet make sure to configure testnet first

Add stacks to the accounts in the `testnet/stacks-node/Stacks.toml` configuration file, accounts are defined in `owner-keys.json` and `customer-keys.json`
For example:
```
# Customer
[[mstx_balance]]
address = "ST1M1ZW33KV9MPFRW3DYNVYMVR5PSDMZ0YSM91K93"
amount = 67584

# Owner
[[mstx_balance]]
address = "ST2WWE6EZC1RWD82SPH7FWFF9SASA3RWCD3ZQNPQW"
amount = 256
```
and run again the command to start testnet terminal
`cargo testnet start --config=testnet/stacks-node/Stacks.toml`

### Run room-reservation-clarity

Run the contract in the room-reservation-clarity terminal using
`npm run reservation`

### Verify the balances by running the link to a browser

- [http://127.0.0.1:20443/v2/accounts/ST1M1ZW33KV9MPFRW3DYNVYMVR5PSDMZ0YSM91K93](http://127.0.0.1:20443/v2/accounts/ST1M1ZW33KV9MPFRW3DYNVYMVR5PSDMZ0YSM91K93)
- [http://127.0.0.1:20443/v2/accounts/ST2WWE6EZC1RWD82SPH7FWFF9SASA3RWCD3ZQNPQW](http://127.0.0.1:20443/v2/accounts/ST2WWE6EZC1RWD82SPH7FWFF9SASA3RWCD3ZQNPQW)




