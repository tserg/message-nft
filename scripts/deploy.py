from brownie import Message, accounts

def main():
    acct = accounts.load('deployment_account')
    Message.deploy({'from': acct})
