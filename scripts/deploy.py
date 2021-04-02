from brownie import Message, accounts

def main():
    acct = accounts.load('deployment_account')
    Message.deploy('Immutable Message Version 0', 'IMESSAGE0', {'from': acct})
