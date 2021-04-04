import pytest

from brownie import accounts

TOKEN_NAME = 'Immutable Message Version 0'
TOKEN_SYMBOL = 'IMESSAGE0'
ZERO_ADDRESS = '0x0000000000000000000000000000000000000000'

@pytest.fixture(scope="module")
def MessageNFTContract(Message, accounts):
    yield Message.deploy(TOKEN_NAME, TOKEN_SYMBOL, {'from': accounts[0]})

def test_message_creation(MessageNFTContract, accounts):

    tx1 = MessageNFTContract.mint(accounts[1], 'Hello World!', {'from': accounts[0]})

    assert MessageNFTContract.balanceOf(accounts[1]) == 1
    assert MessageNFTContract.ownerOf(0) == accounts[1]
    assert MessageNFTContract.viewMessage(0) == 'Hello World!'
    assert MessageNFTContract.viewMessageCreator(0) == accounts[0]

    assert len(tx1.events) == 2

    # Check Transfer event
    assert tx1.events[0]['tokenId'] == 0
    assert tx1.events[0]['sender'] == ZERO_ADDRESS
    assert tx1.events[0]['receiver'] == accounts[1]

    # Check MessageCreated event
    assert tx1.events[1]['message'] == 'Hello World!'
    assert tx1.events[1]['sender'] == accounts[0]


def test_message_transfer(MessageNFTContract, accounts):

    tx1 = MessageNFTContract.transferFrom(accounts[1], accounts[2], 0, {'from': accounts[1]})

    assert MessageNFTContract.balanceOf(accounts[1]) == 0
    assert MessageNFTContract.balanceOf(accounts[2]) == 1
    assert MessageNFTContract.ownerOf(0) == accounts[2]
    assert MessageNFTContract.viewMessage(0) == 'Hello World!'
    assert MessageNFTContract.viewMessageCreator(0) == accounts[0]

    # Check Transfer event
    assert tx1.events[0]['tokenId'] == 0
    assert tx1.events[0]['sender'] == accounts[1]
    assert tx1.events[0]['receiver'] == accounts[2]
