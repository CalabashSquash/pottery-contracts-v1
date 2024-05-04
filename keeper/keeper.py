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
        self.account = account

        if config["vrf"]:
            abi = "vrf_abi.json"
        else:
            abi = "abi.json"

        self.contract = self.web3.eth.contract(
            address=config["contract_address"], abi=abi
        )
        self.deadline = config["deadline"]

        print(f"Deadline is {datetime.datetime.fromtimestamp(self.deadline)}")
        print(f"Time now is {datetime.datetime.now()}")

        self.w3 = None
        self.w3.middleware_onion.add(
            construct_sign_and_send_raw_middleware(self.account)
        )

        print(f"Your hot wallet address is {self.account.address}")
        self.balance = self.w3.eth.get_balance(self.account.address)
        print(
            f"Your hot wallet balance is {OneInch.parse_float(self.w3.from_wei(self.balance, 'ether'))} {self.currency}"
        )

    def spin(self):
        while True:
            self.check()
            time.sleep(10)

    def check(self):
        # check if timestamp is after the deadline
        if time.time() > self.deadline:
            self.execute()

    def execute(self):
        if self.config["vrf"]:
            self._execute_vrf()
        elif self.config["blockhash_random"]:
            self._execute_blockhash_random()
        else:
            self._execute()

    def _execute_vrf(self):
        pass

    def _execute_blockhash_random(self):
        pass

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
    # print(keeper.get_balance())