import pytest

from brownie import accounts

TOKEN_NAME = 'Immutable Message Version 0'
TOKEN_SYMBOL = 'IMESSAGE0'

@pytest.fixture(scope="module")
def MessageNFTContract(Message, accounts):
    yield Message.deploy(TOKEN_NAME, TOKEN_SYMBOL, {'from': accounts[0]})

def test_message_creation(MessageNFTContract, accounts):

    tx1 = MessageNFTContract.mint(accounts[1], 'Hello World!', {'from': accounts[0]})

    assert MessageNFTContract.balanceOf(accounts[1]) == 1
    assert MessageNFTContract.ownerOf(0) == accounts[1]
    assert MessageNFTContract.viewMessage(0) == 'Hello World!'
    assert MessageNFTContract.viewMessageCreator(0) == accounts[0]


def test_message_transfer(MessageNFTContract, accounts):

    tx1 = MessageNFTContract.transferFrom(accounts[1], accounts[2], 0, {'from': accounts[1]})

    assert MessageNFTContract.balanceOf(accounts[1]) == 0
    assert MessageNFTContract.balanceOf(accounts[2]) == 1
    assert MessageNFTContract.ownerOf(0) == accounts[2]
    assert MessageNFTContract.viewMessage(0) == 'Hello World!'
    assert MessageNFTContract.viewMessageCreator(0) == accounts[0]
