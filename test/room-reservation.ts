const BigNum = require("bn.js");
import * as fs from "fs";
import axios from "axios"
import {
    makeSmartContractDeploy,
    makeContractCall,
    TransactionVersion,
    FungibleConditionCode,
    uintCV,
    ChainID,
    makeStandardSTXPostCondition,
    makeContractSTXPostCondition,
    StacksTestnet,
    broadcastTransaction,
} from "@blockstack/stacks-transactions";
import { Client, Provider, ProviderRegistry, Result } from "@blockstack/clarity";
import { assert } from "chai";

const STACKS_API_URL = "http://localhost:20443";
const network = new StacksTestnet();
network.coreApiUrl = STACKS_API_URL;
const roomPrice = 8192;
const roomNo = "101"

let ownerKeys, customerKeys, payment, remainingBalance;

describe("room reservation contract test suite", async () => {
    ownerKeys = JSON.parse(fs.readFileSync("./owner-keys.json").toString());
    customerKeys = JSON.parse(fs.readFileSync("./customer-keys.json").toString());
    let ownerClient: Client;
    let provider: Provider;
    before(async () => {
        provider = await ProviderRegistry.createProvider();
        ownerClient = new Client(`${ownerKeys.keyInfo.address}.room-reservation`, "room-reservation", provider);
    });
    it("should have a valid syntax", async () => {
        await ownerClient.checkContract();
    });

    describe("deploying an instance of the hotel clients", () => {

        const execMethod = async (method: string, args) => {
            const tx = ownerClient.createTransaction({
                method: {
                    name: method,
                    args: [args],
                },
            });
            await tx.sign(ownerKeys.keyInfo.address);
            const receipt = await ownerClient.submitTransaction(tx);
            let result = Result.extract(receipt);
            return result;
        }

        const queryMethod = async (method: string, args) => {
            const query = ownerClient.createQuery({
                method: { name: method, args: [args] }
            });
            const receipt = await ownerClient.submitQuery(query);
            return receipt;
        }

        const querySetPrice = async (method: string, dp: string, bal: string) => {
            const tx = ownerClient.createTransaction({
                method: {
                    name: method,
                    args: [dp, bal],
                },
            });
            await tx.sign(ownerKeys.keyInfo.address);
            const receipt = await ownerClient.submitTransaction(tx);
            let result = Result.extract(receipt);
            return result;
        }

        before(async () => {
            await ownerClient.deployContract();
        });

        it("Room should be available for rent", async () => {
            let room = await queryMethod("get-room-info", roomNo);
            const result = Result.unwrap(room)
            assert.equal(result, "(ok true)")
        });

        it("Owner should set a price for the room", async () => {
            const downPayment = Math.round(roomPrice * 0.20);
            const balance = (roomPrice - downPayment)
            const receipt = await querySetPrice("set-room-price", downPayment.toString(), balance.toString());
            assert.equal(receipt.success, true)
        });

        it("Customer should check if his/her stacks is suited for the downpayment", async () => {
            const getBalanceAPI = network.getAccountApiUrl(customerKeys.keyInfo.address);
            const result = await axios.get(getBalanceAPI);
            const receipt = await execMethod("check-downpayment", parseInt(result.data.balance).toString());
            assert.equal(receipt.success, true)
        });

        it("customer should check if room is available for rent", async () => {
            const query = await queryMethod("check-room-availability", roomNo);
            const roomAvailability = Result.unwrap(query)
            assert.equal(roomAvailability, "(ok true)")
        });

        it("customer should ready the downpayment", async () => {
            const query = await queryMethod("get-downpayment", null);
            const dp = Result.unwrapUInt(query)
            payment = dp;
        });

        it("should deposit reservation fee", async () => {
            var fee = new BigNum(5289);
            const customerStacksAddress = customerKeys.keyInfo.address;
            const ownerStacksAddress = ownerKeys.keyInfo.address;
            const customerKey = customerKeys.keyInfo.privateKey;
            const ownerKey = ownerKeys.keyInfo.privateKey;
            const contractName = "room-reservation";
            const codeBody = fs
                .readFileSync("./contracts/room-reservation.clar")
                .toString();

            var transaction = await makeSmartContractDeploy({
                contractName,
                codeBody,
                fee,
                senderKey: customerKey,
                nonce: new BigNum(0),
                network,
            });
            console.log(await broadcastTransaction(transaction, network));
            await new Promise((r) => setTimeout(r, 15000));
            fee = new BigNum(256);

            transaction = await makeContractCall({
                contractAddress: customerStacksAddress,
                contractName,
                functionName: "deposit-downpayment",
                functionArgs: [uintCV(payment), uintCV(parseInt(roomNo))],
                fee,
                senderKey: customerKey,
                nonce: new BigNum(1),
                network,
                postConditions: [
                    makeStandardSTXPostCondition(
                        customerStacksAddress,
                        FungibleConditionCode.Equal,
                        new BigNum(payment)
                    ),
                ],
            });
            console.log(await broadcastTransaction(transaction, network));

        });

        it("customer should ready the balance to be paid", async () => {
            const query = await queryMethod("get-balance", null);
            const bal = Result.unwrapUInt(query)
            payment = bal;
        });

        it("customer should deposit balance", async () => {
            var fee = new BigNum(5289);
            const customerStacksAddress = customerKeys.keyInfo.address;
            const ownerStacksAddress = ownerKeys.keyInfo.address;
            const customerKey = customerKeys.keyInfo.privateKey;
            const ownerKey = ownerKeys.keyInfo.privateKey;
            const contractName = "deposit-balance";
            const codeBody = fs
                .readFileSync("./contracts/room-reservation.clar")
                .toString();

            var transaction = await makeSmartContractDeploy({
                contractName,
                codeBody,
                fee,
                senderKey: customerKey,
                nonce: new BigNum(1),
                network,
            });
            console.log(await broadcastTransaction(transaction, network));
            await new Promise((r) => setTimeout(r, 15000));
            fee = new BigNum(256);

            transaction = await makeContractCall({
                contractAddress: customerStacksAddress,
                contractName,
                functionName: "deposit-downpayment",
                functionArgs: [uintCV(payment), uintCV(parseInt(roomNo))],
                fee,
                senderKey: customerKey,
                nonce: new BigNum(2),
                network,
                postConditions: [
                    makeStandardSTXPostCondition(
                        customerStacksAddress,
                        FungibleConditionCode.Equal,
                        new BigNum(payment)
                    ),
                ],
            });
            console.log(await broadcastTransaction(transaction, network));

        });


    });


    after(async () => {
        await provider.close();
    });
});
