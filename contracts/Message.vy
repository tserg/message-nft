# @version ^0.2.0

# @dev Implementation of ERC-721 non-fungible token standard.
# @author Ryuya Nakamura (@nrryuya)
# Modified from: https://github.com/vyperlang/vyper/blob/de74722bf2d8718cca46902be165f9fe0e3641dd/examples/tokens/ERC721.vy

from vyper.interfaces import ERC721

implements: ERC721

# Interface for the contract called by safeTransferFrom()
interface ERC721Receiver:
    def onERC721Received(
            _operator: address,
            _from: address,
            _tokenId: uint256,
            _data: Bytes[1024]
        ) -> bytes32: view

# Interface for ERC721Metadata

interface ERC721Metadata:
    def name(
            _name: String[64]
        ) -> String[64]: view

    def symbol(
            _symbol: String[32]
        ) -> String[32]: view

    def tokenURI(
            _tokenId: uint256
        ) -> String[128]: view

# Interface for ERC721Enumerable

interface ERC721Enumerable:

    def totalSupply() -> uint256: view

    def tokenByIndex(
        _tokenId: uint256
    ) -> uint256: view

    def tokenOfOwnerByIndex(
        _owner: address,
        _tokenId: uint256
    ) -> uint256: view

# @dev Emits when ownership of any NFT changes by any mechanism. This event emits when NFTs are
#      created (`from` == 0) and destroyed (`to` == 0). Exception: during contract creation, any
#      number of NFTs may be created and assigned without emitting Transfer. At the time of any
#      transfer, the approved address for that NFT (if any) is reset to none.
# @param _from Sender of NFT (if address is zero address it indicates token creation).
# @param _to Receiver of NFT (if address is zero address it indicates token destruction).
# @param _tokenId The NFT that got transfered.
event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    tokenId: indexed(uint256)

# @dev This emits when the approved address for an NFT is changed or reaffirmed. The zero
#      address indicates there is no approved address. When a Transfer event emits, this also
#      indicates that the approved address for that NFT (if any) is reset to none.
# @param _owner Owner of NFT.
# @param _approved Address that we are approving.
# @param _tokenId NFT which we are approving.
event Approval:
    owner: indexed(address)
    approved: indexed(address)
    tokenId: indexed(uint256)

# @dev This emits when an operator is enabled or disabled for an owner. The operator can manage
#      all NFTs of the owner.
# @param _owner Owner of NFT.
# @param _operator Address to which we are setting operator rights.
# @param _approved Status of operator rights(true if operator rights are given and false if
# revoked).
event ApprovalForAll:
    owner: indexed(address)
    operator: indexed(address)
    approved: bool

event MessageCreated:
    sender: indexed(address)
    message: String[100]

tokenName: String[64]
tokenSymbol: String[32]
owner: address

# @dev Current count of token
tokenId: uint256

# @dev Mapping from NFT ID to the address that owns it.
idToOwner: HashMap[uint256, address]

# @dev Mapping from NFT ID to approved address.
idToApprovals: HashMap[uint256, address]

# @dev Mapping from owner address to count of his tokens.
ownerToNFTokenCount: HashMap[address, uint256]

# @dev Mapping from owner address to mapping of index to tokenIds
ownerToNFTokenIdList: HashMap[address, HashMap[uint256, uint256]]

# @dev Mapping from NFT ID to index of owner
tokenToOwnerIndex: HashMap[uint256, uint256]

# @dev Mapping from owner address to mapping of operator addresses.
ownerToOperators: HashMap[address, HashMap[address, bool]]

# @dev Address of URI contract
tokenBaseURI: public(String[128])

# @dev Mapping of interface id to bool about whether or not it's supported
supportedInterfaces: HashMap[bytes32, bool]

# @dev ERC165 interface ID of ERC165
ERC165_INTERFACE_ID: constant(bytes32) = 0x0000000000000000000000000000000000000000000000000000000001ffc9a7

# @dev ERC165 interface ID of ERC721
ERC721_INTERFACE_ID: constant(bytes32) = 0x0000000000000000000000000000000000000000000000000000000080ac58cd

# @dev ERC165 interface ID of ERC721Metadata
ERC721_METADATA_INTERFACE_ID: constant(bytes32) = 0x000000000000000000000000000000000000000000000000000000005b5e139f

# @dev ERC165 interface ID of ERC721Enumerable

ERC721_ENUMERABLE_INTERFACE_ID: constant(bytes32) = 0x00000000000000000000000000000000000000000000000000000000780e9d63

# @dev Mapping from NFT ID to message.
idToMessage: HashMap[uint256, String[100]]

# @dev Mapping from NFT ID to message creator
idToMessageCreator: HashMap[uint256, address]


@external
def __init__():
    """
    @dev Contract constructor.
    """
    self.tokenName = 'Immutable Messages V0'
    self.tokenSymbol = 'IMSG'
    self.owner = msg.sender
    self.tokenBaseURI = 'https://raw.githubusercontent.com/tserg/message-nft/main/IMSG_metadata'
    self.supportedInterfaces[ERC165_INTERFACE_ID] = True
    self.supportedInterfaces[ERC721_INTERFACE_ID] = True
    self.supportedInterfaces[ERC721_METADATA_INTERFACE_ID] = True
    self.supportedInterfaces[ERC721_ENUMERABLE_INTERFACE_ID] = True
    self.tokenId = 0


@view
@external
def supportsInterface(_interfaceID: bytes32) -> bool:
    """
    @dev Interface identification is specified in ERC-165.
    @param _interfaceID Id of the interface
    """
    return self.supportedInterfaces[_interfaceID]


### VIEW FUNCTIONS ###
@view
@internal
def _balanceOf(_owner: address) -> uint256:
    """
    @dev Returns the number of NFTs owned by `_owner`.
         Throws if `_owner` is the zero address. NFTs assigned to the zero address are considered invalid.
    @param _owner Address for whom to query the balance.
    """
    assert _owner != ZERO_ADDRESS
    return self.ownerToNFTokenCount[_owner]

@view
@external
def balanceOf(_owner: address) -> uint256:
    """
    @dev Returns the number of NFTs owned by `_owner`.
         Throws if `_owner` is the zero address. NFTs assigned to the zero address are considered invalid.
    @param _owner Address for whom to query the balance.
    """
    return self._balanceOf(_owner)


@view
@external
def ownerOf(_tokenId: uint256) -> address:
    """
    @dev Returns the address of the owner of the NFT.
         Throws if `_tokenId` is not a valid NFT.
    @param _tokenId The identifier for an NFT.
    """
    owner: address = self.idToOwner[_tokenId]
    # Throws if `_tokenId` is not a valid NFT
    assert owner != ZERO_ADDRESS
    return owner


@view
@external
def getApproved(_tokenId: uint256) -> address:
    """
    @dev Get the approved address for a single NFT.
         Throws if `_tokenId` is not a valid NFT.
    @param _tokenId ID of the NFT to query the approval of.
    """
    # Throws if `_tokenId` is not a valid NFT
    assert self.idToOwner[_tokenId] != ZERO_ADDRESS
    return self.idToApprovals[_tokenId]


@view
@external
def isApprovedForAll(_owner: address, _operator: address) -> bool:
    """
    @dev Checks if `_operator` is an approved operator for `_owner`.
    @param _owner The address that owns the NFTs.
    @param _operator The address that acts on behalf of the owner.
    """
    return (self.ownerToOperators[_owner])[_operator]

@view
@external
def viewMessage(_tokenId: uint256) -> String[100]:
    """
    @dev Get the message of a single NFT.
         Throws if `_tokenId` is not a valid NFT.
    @param _tokenId ID of the NFT to query the approval of.
    """
    # Throws if `_tokenId` is not a valid NFT
    assert self.idToOwner[_tokenId] != ZERO_ADDRESS

    return self.idToMessage[_tokenId]

@view
@external
def viewMessageCreator(_tokenId: uint256) -> address:
    """
    @dev Get the creator of a single NFT.
         Throws if `_tokenId` is not a valid NFT.
    @param _tokenId ID of the NFT to query the approval of.
    """
    # Throws if `_tokenId` is not a valid NFT
    assert self.idToOwner[_tokenId] != ZERO_ADDRESS

    return self.idToMessageCreator[_tokenId]

#   Implementation of ERC721Metadata

@view
@external
def name() -> String[64]:
    """
    @dev Get the name of the NFT.
    """
    return self.tokenName

@view
@external
def symbol() -> String[32]:
    """
    @dev Get the symbol of the NFT.
    """
    return self.tokenSymbol

@view
@external
def tokenURI(_tokenId: uint256) -> String[128]:
    """
    @dev Returns current token URI metadata
    @param _tokenId Token ID to fetch URI for.
    """
    return self.tokenBaseURI

#   Implementation of ERC721Enumerable

@view
@external
def tokenSupply() -> uint256:
    """
    @dev  Get the total number of tokens
    """
    return self.tokenId

@view
@external
def tokenByIndex(_tokenId: uint256) -> uint256:
    """
    @dev  Get token by index
          Throws if '_tokenId' is larger than totalSupply()
    """
    assert _tokenId <= self.tokenId

    return self.tokenId

@view
@external
def tokenOfOwnerByIndex(_owner: address, _tokenIndex: uint256) -> uint256:
    """
    @dev  Get token by index
          Throws if '_tokenIndex' is larger than balance of '_owner'
          Throws if value has been set to 0
    """
    assert _tokenIndex <= self._balanceOf(_owner)

    # Checks if token has been transferred and set to default value of 0
    assert self.ownerToNFTokenIdList[_owner][_tokenIndex] != 0
    return self.ownerToNFTokenIdList[_owner][_tokenIndex]

### TRANSFER FUNCTION HELPERS ###

@view
@internal
def _isApprovedOrOwner(_spender: address, _tokenId: uint256) -> bool:
    """
    @dev Returns whether the given spender can transfer a given token ID
    @param spender address of the spender to query
    @param tokenId uint256 ID of the token to be transferred
    @return bool whether the msg.sender is approved for the given token ID,
        is an operator of the owner, or is the owner of the token
    """
    owner: address = self.idToOwner[_tokenId]
    spenderIsOwner: bool = owner == _spender
    spenderIsApproved: bool = _spender == self.idToApprovals[_tokenId]
    spenderIsApprovedForAll: bool = (self.ownerToOperators[owner])[_spender]
    return (spenderIsOwner or spenderIsApproved) or spenderIsApprovedForAll

@internal
def _addTokenToOwnerList(_to: address, _tokenId: uint256):
    """
    @dev Add a NFT to an index mapping to a given address
    @param to address of the receiver
    @param tokenId uint256 ID Of the token to be added
    """
    current_count: uint256 = self._balanceOf(_to)

    self.ownerToNFTokenIdList[_to][current_count] = _tokenId
    self.tokenToOwnerIndex[_tokenId] = current_count

@internal
def _removeTokenFromOwnerList(_from: address, _tokenId: uint256):
    """
    @dev Remove a NFT from an index mapping to a given address
    @param from address of the sender
    @param tokenId uint256 ID Of the token to be removed
    """
    # Delete
    current_count: uint256 = self._balanceOf(_from)
    current_index: uint256 = self.tokenToOwnerIndex[_tokenId]

    if current_count == current_index:
        # update ownerToNFTokenIdList
        self.ownerToNFTokenIdList[_from][current_count] = 0
        # update tokenToOwnerIndex
        self.tokenToOwnerIndex[_tokenId] = 0

    else:
        lastTokenId: uint256 = self.ownerToNFTokenIdList[_from][current_count]

        # Add
        # update ownerToNFTokenIdList
        self.ownerToNFTokenIdList[_from][current_index] = lastTokenId
        # update tokenToOwnerIndex
        self.tokenToOwnerIndex[lastTokenId] = current_index

        # Delete
        # update ownerToNFTokenIdList
        self.ownerToNFTokenIdList[_from][current_count] = 0
        # update tokenToOwnerIndex
        self.tokenToOwnerIndex[_tokenId] = 0

@internal
def _addTokenTo(_to: address, _tokenId: uint256):
    """
    @dev Add a NFT to a given address
         Throws if `_tokenId` is owned by someone.
    """
    # Throws if `_tokenId` is owned by someone
    assert self.idToOwner[_tokenId] == ZERO_ADDRESS
    # Change the owner
    self.idToOwner[_tokenId] = _to
    # Change count tracking
    self.ownerToNFTokenCount[_to] += 1
    # Update owner token index tracking
    self._addTokenToOwnerList(_to, _tokenId)

@internal
def _removeTokenFrom(_from: address, _tokenId: uint256):
    """
    @dev Remove a NFT from a given address
         Throws if `_from` is not the current owner.
    """
    # Throws if `_from` is not the current owner
    assert self.idToOwner[_tokenId] == _from
    # Change the owner
    self.idToOwner[_tokenId] = ZERO_ADDRESS
    # Update owner token index tracking
    self._removeTokenFromOwnerList(_from, _tokenId)
    # Change count tracking
    self.ownerToNFTokenCount[_from] -= 1


@internal
def _clearApproval(_owner: address, _tokenId: uint256):
    """
    @dev Clear an approval of a given address
         Throws if `_owner` is not the current owner.
    """
    # Throws if `_owner` is not the current owner
    assert self.idToOwner[_tokenId] == _owner
    if self.idToApprovals[_tokenId] != ZERO_ADDRESS:
        # Reset approvals
        self.idToApprovals[_tokenId] = ZERO_ADDRESS


@internal
def _transferFrom(_from: address, _to: address, _tokenId: uint256, _sender: address):
    """
    @dev Exeute transfer of a NFT.
         Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
         address for this NFT. (NOTE: `msg.sender` not allowed in private function so pass `_sender`.)
         Throws if `_to` is the zero address.
         Throws if `_from` is not the current owner.
         Throws if `_tokenId` is not a valid NFT.
    """
    # Check requirements
    assert self._isApprovedOrOwner(_sender, _tokenId)
    # Throws if `_to` is the zero address
    assert _to != ZERO_ADDRESS
    # Clear approval. Throws if `_from` is not the current owner
    self._clearApproval(_from, _tokenId)
    # Remove NFT. Throws if `_tokenId` is not a valid NFT
    self._removeTokenFrom(_from, _tokenId)
    # Add NFT
    self._addTokenTo(_to, _tokenId)
    # Log the transfer
    log Transfer(_from, _to, _tokenId)

### MESSAGE FUNCTION HELPERS ###


@internal
def _createMessage(_from: address, _tokenId: uint256, _message: String[100]):
    """
    @dev Store message
    """
    self.idToMessage[_tokenId] = _message
    self.idToMessageCreator[_tokenId] = _from

### TRANSFER FUNCTIONS ###

@external
def transferFrom(_from: address, _to: address, _tokenId: uint256):
    """
    @dev Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
         address for this NFT.
         Throws if `_from` is not the current owner.
         Throws if `_to` is the zero address.
         Throws if `_tokenId` is not a valid NFT.
    @notice The caller is responsible to confirm that `_to` is capable of receiving NFTs or else
            they maybe be permanently lost.
    @param _from The current owner of the NFT.
    @param _to The new owner.
    @param _tokenId The NFT to transfer.
    """
    self._transferFrom(_from, _to, _tokenId, msg.sender)


@external
def safeTransferFrom(
        _from: address,
        _to: address,
        _tokenId: uint256,
        _data: Bytes[1024]=b""
    ):
    """
    @dev Transfers the ownership of an NFT from one address to another address.
         Throws unless `msg.sender` is the current owner, an authorized operator, or the
         approved address for this NFT.
         Throws if `_from` is not the current owner.
         Throws if `_to` is the zero address.
         Throws if `_tokenId` is not a valid NFT.
         If `_to` is a smart contract, it calls `onERC721Received` on `_to` and throws if
         the return value is not `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
         NOTE: bytes4 is represented by bytes32 with padding
    @param _from The current owner of the NFT.
    @param _to The new owner.
    @param _tokenId The NFT to transfer.
    @param _data Additional data with no specified format, sent in call to `_to`.
    """
    self._transferFrom(_from, _to, _tokenId, msg.sender)
    if _to.is_contract: # check if `_to` is a contract address
        returnValue: bytes32 = ERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data)
        # Throws if transfer destination is a contract which does not implement 'onERC721Received'
        assert returnValue == method_id("onERC721Received(address,address,uint256,bytes)", output_type=bytes32)


@external
def approve(_approved: address, _tokenId: uint256):
    """
    @dev Set or reaffirm the approved address for an NFT. The zero address indicates there is no approved address.
         Throws unless `msg.sender` is the current NFT owner, or an authorized operator of the current owner.
         Throws if `_tokenId` is not a valid NFT. (NOTE: This is not written the EIP)
         Throws if `_approved` is the current owner. (NOTE: This is not written the EIP)
    @param _approved Address to be approved for the given NFT ID.
    @param _tokenId ID of the token to be approved.
    """
    owner: address = self.idToOwner[_tokenId]
    # Throws if `_tokenId` is not a valid NFT
    assert owner != ZERO_ADDRESS
    # Throws if `_approved` is the current owner
    assert _approved != owner
    # Check requirements
    senderIsOwner: bool = self.idToOwner[_tokenId] == msg.sender
    senderIsApprovedForAll: bool = (self.ownerToOperators[owner])[msg.sender]
    assert (senderIsOwner or senderIsApprovedForAll)
    # Set the approval
    self.idToApprovals[_tokenId] = _approved
    log Approval(owner, _approved, _tokenId)


@external
def setApprovalForAll(_operator: address, _approved: bool):
    """
    @dev Enables or disables approval for a third party ("operator") to manage all of
         `msg.sender`'s assets. It also emits the ApprovalForAll event.
         Throws if `_operator` is the `msg.sender`. (NOTE: This is not written the EIP)
    @notice This works even if sender doesn't own any tokens at the time.
    @param _operator Address to add to the set of authorized operators.
    @param _approved True if the operators is approved, false to revoke approval.
    """
    # Throws if `_operator` is the `msg.sender`
    assert _operator != msg.sender
    self.ownerToOperators[msg.sender][_operator] = _approved
    log ApprovalForAll(msg.sender, _operator, _approved)


### MINT FUNCTION ###

@external
def mint(_to: address, _message: String[100]) -> bool:
    """
    @dev Function to mint tokens
         Throws if `_to` is zero address.
         Throws if `_tokenId` is owned by someone.
    @param _to The address that will receive the minted tokens.
    @param _message The message to store
    @return A boolean that indicates if the operation was successful.
    """

    # Throws if `_to` is zero address
    assert _to != ZERO_ADDRESS
    # Add NFT. Throws if `_tokenId` is owned by someone
    self.tokenId += 1
    _tokenId: uint256 = self.tokenId

    self._addTokenTo(_to, _tokenId)
    log Transfer(ZERO_ADDRESS, _to, _tokenId)

    # Create message
    self._createMessage(msg.sender, _tokenId, _message)
    log MessageCreated(msg.sender, _message)

    return True

@external
def setTokenURI(_tokenURI: String[128]):
    """
    @dev  Set token URI contract address
          Throws unless `msg.sender` is the current owner
    @param _tokenURI URI to set
    """
    assert msg.sender == self.owner
    self.tokenBaseURI = _tokenURI
