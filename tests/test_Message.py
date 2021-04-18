import pytest

from brownie import accounts, reverts

ZERO_ADDRESS = '0x0000000000000000000000000000000000000000'

@pytest.fixture(scope="module")
def MessageNFTContract(Message, accounts):
    yield Message.deploy({'from': accounts[0]})

def test_token_creation(MessageNFTContract, accounts):

    tx1 = MessageNFTContract.mint(accounts[1], 'Hello World!', {'from': accounts[0]})

    assert MessageNFTContract.balanceOf(accounts[1]) == 1
    assert MessageNFTContract.ownerOf(1) == accounts[1]
    assert MessageNFTContract.viewMessage(1, {'from': accounts[1]}) == 'Hello World!'
    assert MessageNFTContract.viewMessageCreator(1, {'from': accounts[1]}) == accounts[0]

    assert len(tx1.events) == 2

    assert MessageNFTContract.tokenOfOwnerByIndex(accounts[1], 1) == 1

    # Check Transfer event
    assert tx1.events[0]['tokenId'] == 1
    assert tx1.events[0]['sender'] == ZERO_ADDRESS
    assert tx1.events[0]['receiver'] == accounts[1]

    # Check MessageCreated event
    assert tx1.events[1]['message'] == 'Hello World!'
    assert tx1.events[1]['sender'] == accounts[0]

def test_token_transfer(MessageNFTContract, accounts):

    tx1 = MessageNFTContract.transferFrom(accounts[1], accounts[2], 1, {'from': accounts[1]})

    assert MessageNFTContract.balanceOf(accounts[1]) == 0
    assert MessageNFTContract.balanceOf(accounts[2]) == 1
    assert MessageNFTContract.ownerOf(1) == accounts[2]
    assert MessageNFTContract.viewMessage(1, {'from': accounts[2]}) == 'Hello World!'
    assert MessageNFTContract.viewMessageCreator(1, {'from': accounts[2]}) == accounts[0]

    assert MessageNFTContract.tokenOfOwnerByIndex(accounts[2], 1) == 1
    with reverts():
        assert MessageNFTContract.tokenOfOwnerByIndex(accounts[1], 1)

    # Check Transfer event
    assert tx1.events[0]['tokenId'] == 1
    assert tx1.events[0]['sender'] == accounts[1]
    assert tx1.events[0]['receiver'] == accounts[2]

def test_non_approved_transfer(MessageNFTContract, accounts):

    with reverts():
        MessageNFTContract.transferFrom(accounts[2], accounts[1], 1, {'from': accounts[1]})

    assert MessageNFTContract.balanceOf(accounts[1]) == 0
    assert MessageNFTContract.balanceOf(accounts[2]) == 1
    assert MessageNFTContract.ownerOf(1) == accounts[2]

def test_approved_transfer(MessageNFTContract, accounts):

    tx1 = MessageNFTContract.approve(accounts[0], 1, {'from': accounts[2]})

    assert MessageNFTContract.getApproved(1) == accounts[0]

    tx2 = MessageNFTContract.transferFrom(accounts[2], accounts[1], 1, {'from': accounts[0]})

    assert MessageNFTContract.balanceOf(accounts[1]) == 1
    assert MessageNFTContract.balanceOf(accounts[2]) == 0
    assert MessageNFTContract.ownerOf(1) == accounts[1]

def test_token_transfer_multiple_existing_tokens(MessageNFTContract, accounts):

    tx1 = MessageNFTContract.mint(accounts[1], 'Second Message', {'from': accounts[1]})

    current_balance = MessageNFTContract.balanceOf(accounts[1])

    assert current_balance == 2
    assert MessageNFTContract.tokenByIndex(2) == 2
    assert MessageNFTContract.tokenOfOwnerByIndex(accounts[1], current_balance) == 2

    tx2 = MessageNFTContract.transferFrom(accounts[1], accounts[0], 1, {'from': accounts[1]})

    updated_balance = MessageNFTContract.balanceOf(accounts[1])

    assert updated_balance == 1
    with reverts():
        MessageNFTContract.tokenOfOwnerByIndex(accounts[1], 2)
    assert MessageNFTContract.tokenOfOwnerByIndex(accounts[1], 1) == 2

    assert MessageNFTContract.balanceOf(accounts[0]) == 1
    with reverts():
        MessageNFTContract.tokenOfOwnerByIndex(accounts[0], 2)
    assert MessageNFTContract.tokenOfOwnerByIndex(accounts[0], 1) == 1

def test_token_transfer_multiple_existing_tokens_2(MessageNFTContract, accounts):

    tx1 = MessageNFTContract.mint(accounts[1], 'Third time around', {'from': accounts[1]})
    tx2 = MessageNFTContract.transferFrom(accounts[0], accounts[1], 1, {'from': accounts[0]})

    assert MessageNFTContract.tokenByIndex(3) == 3

    assert MessageNFTContract.balanceOf(accounts[1]) == 3
    assert MessageNFTContract.tokenOfOwnerByIndex(accounts[1], 1) == 2
    assert MessageNFTContract.tokenOfOwnerByIndex(accounts[1], 2) == 3
    assert MessageNFTContract.tokenOfOwnerByIndex(accounts[1], 3) == 1

    tx3 = MessageNFTContract.transferFrom(accounts[1], accounts[2], 1, {'from': accounts[1]})

    assert MessageNFTContract.balanceOf(accounts[1]) == 2
    with reverts():
        MessageNFTContract.tokenOfOwnerByIndex(accounts[1], 3)

    assert MessageNFTContract.balanceOf(accounts[2]) == 1
    assert MessageNFTContract.tokenOfOwnerByIndex(accounts[2], 1) == 1
