from eth_account import Account
from eth_account.signers.local import LocalAccount
from web3 import Web3, EthereumTesterProvider
import web3
from web3.middleware import construct_sign_and_send_raw_middleware
from typing import Dict
import getpass

import os
import json
import argparse
import time
import datetime

def open_json(file):
    with open(file, 'r') as f:
        return json.load(f)


class Keeper:
    def __init__(self, config: Dict, account: LocalAccount):
        self.web3 = Web3(Web3.HTTPProvider(config["rpc_url"]))
        # get enviorment variable PRIVATE_KEY
        self.config = config
        self.account = account
        self.w3 = Web3(Web3.HTTPProvider(config["rpc_url"]))
        self.currency = config["currency"]
        if config["vrf"]:
            abi = "VRFDraw.json"
        else:
            abi = "BlockHashDraw.json"

        abi = open_json(abi)["abi"]

        self.contract = self.web3.eth.contract(
            address=config["contract_address"], abi=abi
        )
        self.kiln_address = config["kiln_address"]
        self.kiln_contract = self.w3.eth.contract(
            address=self.kiln_address, abi=open_json("Kiln.json")["abi"]
        )
        # get lotteryEnd public value from contract
        self.kiln_deadline = self.kiln_contract.functions.lotteryEnd().call()
        print(f"Kiln address is {self.kiln_address}")
        print(f"Initialising keeper on {config['chain_name']}")

        print(f"Deadline is {datetime.datetime.fromtimestamp(self.kiln_deadline)}")
        print(f"Time now is {datetime.datetime.now()}")

        self.w3.middleware_onion.add(
            construct_sign_and_send_raw_middleware(self.account)
        )

        print(f"Your hot wallet address is {self.account.address}")
        self.balance = self.w3.eth.get_balance(self.account.address)
        print(
            f"Your hot wallet balance is {self.w3.from_wei(self.balance, 'ether')} {self.currency}"
        )


    def spin(self):
        while True:
            self.check()
            time.sleep(10)

    def check(self):
        # check if timestamp is after the deadline
        if time.time() > self.kiln_deadline:
            print("=" * 50)
            print(f"[{datetime.datetime.now()}] Deadline reached, executing...")
            self.execute()
        else:
            print(f"[{datetime.datetime.now()}] Deadline not reached yet, waiting...")

    def execute(self):
        if self.config["vrf"]:
            self._execute_vrf()
        elif self.config["blockhash_random"]:
            self._execute_blockhash_random()
        else:
            self._execute()

    def _execute_vrf(self):
        # get address type to send to contract from string address
        address = self.w3.to_checksum_address(self.kiln_address)
        #self.contract.functions.upKeep(address).transact({"from": self.account.address}) 
        tx = self.contract.functions.upKeep(address).build_transaction(
            {
                "from": self.account.address,
                "nonce": self.w3.eth.get_transaction_count(self.account.address),
                "gas": 1000000,
                "gasPrice": self.w3.to_wei("5", "gwei"),
            }
        )
        signed_tx = self.account.sign_transaction(tx)
        # Send the signed transaction
        tx_hash = self.w3.eth.send_raw_transaction(signed_tx.rawTransaction)
        print(f"Transaction sent, tx hash: {tx_hash.hex()}")
        # get tx receipt
        tx_receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash)
        print(f"Transaction succeeded, block number: {tx_receipt['blockNumber']}")



    def _execute_blockhash_random(self):
        address = self.w3.to_checksum_address(self.kiln_address)
        tx = self.contract.functions.upKeep(address).build_transaction(
            {
                "from": self.account.address,
                "nonce": self.w3.eth.get_transaction_count(self.account.address),
                "gas": 1000000,
                "gasPrice": self.w3.to_wei("5", "gwei"),
            }
        )
        signed_tx = self.account.sign_transaction(tx)
        tx_hash = self.w3.eth.send_raw_transaction(signed_tx.rawTransaction)
        print(f"Transaction sent, tx hash: {tx_hash.hex()}")
        tx_receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash)
        block_number = tx_receipt["blockNumber"]
        block_hash = self.w3.eth.get_block(block_number)["hash"]
        print(f"Transaction succeeded, block number: {block_number}, block hash: {block_hash}")
        print(f"waiting for {self.config['delay']} seconds")
        time.sleep(self.config["delay"])
        tx = self.contract.functions.draw(block_hash).build_transaction(
            {
                "from": self.account.address,
                "nonce": self.w3.eth.get_transaction_count(self.account.address),
                "gas": 1000000,
                "gasPrice": self.w3.to_wei("5", "gwei"),
            }
        )
        signed_tx = self.account.sign_transaction(tx)
        tx_hash = self.w3.eth.send_raw_transaction(signed_tx.rawTransaction)
        print(f"Transaction sent, tx hash: {tx_hash.hex()}")
        tx_receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash)
        print(f"Transaction succeeded, block number: {tx_receipt['blockNumber']}")

    def get_balance(self):
        return self.web3.eth.getBalance(self.account.address)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", type=str, help="Path to config file")
    parser.add_argument("--keystore", type=str, help="Path to keystore file")
    args = parser.parse_args()
    print(args.config)
    try:
        with open(args.config, "r") as f:
            config = json.load(f)
    except Exception as e:
        raise Exception("Failed to load config file")
    keystore_file = args.keystore

    if os.path.isfile(keystore_file):
        priv_key = Account.decrypt(
            open_json(keystore_file),
            getpass.getpass(prompt="Input keystore password: "),
        )
        account = Account.from_key(priv_key)
    else:
        print("keystore file not found, creating one")
        private_key = getpass.getpass(prompt="Input private key: ")
        if not private_key.startswith("0x"):
            private_key = "0x" + private_key
        try:
            account = Account.from_key(private_key)
        except:
            raise Exception("invalid private key...")
        print(f"private key valid, account: {account.address}\ncreating keystore file")
        for i in range(3):
            password = getpass.getpass("Enter a password for the keystore file: ")
            password_confirmation = getpass.getpass("Confirm password: ")

            # Check that the passwords match
            if password != password_confirmation:
                print("Passwords do not match")
                print * (f"Please try again, attempt{i+2}/3")
            else:
                break
        if password != password_confirmation:
            raise Exception("Passwords do not match...")
        keystore = Account.encrypt(private_key, password=password)
        with open(keystore_file, "w") as f:
            f.write(json.dumps(keystore))

    keeper = Keeper(config, account)
    keeper.spin()
    # print(keeper.get_balance())
