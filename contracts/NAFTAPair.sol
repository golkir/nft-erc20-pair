pragma solidity >=0.6.2 <0.8.0;

// ERC721
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// ERC1155
import "@openzeppelin/contracts/token/ERC1155/ERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "./ERC20.sol";

import "@openzeppelin/contracts/utils/EnumerableSet.sol";

interface IFactory {
    function adminFee() external view returns (uint256);
}

contract NAFTAPair is ERC20, IERC721Receiver, ERC1155Receiver {

    using EnumerableSet for EnumerableSet.UintSet;
    
    address public PAIR_FACTORY;
    uint256 public NFT_TYPE;
    uint256 public NFT_VALUE; // NUMBER OF wrapped ERC20 tokens returned per one NFT
    address public NFT_ADDRESS;

    event Swap721 (
        uint NFTIdIn,
        uint NFTIdOut
    );

    EnumerableSet.UintSet lockedNfts;

    event Redeem(uint256[] indexed tokenIds, uint256[] indexed amounts);

    // create new token
    constructor() public {}

    function init(
        string memory _name,
        string memory _symbol,
        address nftAddress,
        uint256 nftType
    ) public payable {

        require(PAIR_FACTORY == address(0)); 

        PAIR_FACTORY = msg.sender;
        NFT_TYPE = nftType;
        name = _name;
        symbol = _symbol;
        decimals = 18;
        NFT_ADDRESS = nftAddress;
        NFT_VALUE = 50 * 1e18;
    }

    function getPairInfo()
        public
        view
        returns (
            uint256 nftType,
            string memory name,
            string memory symbol,
            uint256 supply
        )
    {
        nftType = NFT_TYPE;
        name = name;
        symbol = symbol;
        supply = totalSupply / 50e18;
    }

    function onERC721Received(
        address operator,
        address,
        uint256,
        bytes memory data
    ) public virtual override returns (bytes4) {

        require(NFT_ADDRESS == msg.sender, "Message call should be from NFT contract");

        uint256 adminFee = IFactory(PAIR_FACTORY).adminFee();

        _mint(operator, NFT_VALUE.mul(uint256(50).sub(adminFee)).div(50));
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address operator,
        address,
        uint256,
        uint256 value,
        bytes memory data
    ) public virtual override returns (bytes4) {

        require(NFT_ADDRESS == msg.sender, "Message call should be from NFT contract");

        if (keccak256(data) != keccak256("INTERNAL")) {
            uint256 adminFee = IFactory(PAIR_FACTORY).adminFee();
            _mint(
                operator,
                (NFT_VALUE.mul(value)).mul(uint256(50).sub(adminFee)).div(50)
            );
        }
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public virtual override returns (bytes4) {
        require(NFT_ADDRESS == msg.sender, "Message call should be from NFT contract");
        if (keccak256(data) != keccak256("INTERNAL")) {
            uint256 amount = 0;

            for (uint256 i = 0; i < ids.length; i++) {
                amount+= values[i];
            }
            uint256 adminFee = IFactory(PAIR_FACTORY).adminFee();

            _mint(
                operator,
                (NFT_VALUE.mul(amount)).mul(uint256(50).sub(adminFee)).div(50)
            );
        }
        return this.onERC1155BatchReceived.selector;
    }


    function deposite721Multiple(uint256[] memory ids, address _referral) public {
        uint256 adminFee = IFactory(PAIR_FACTORY).adminFee();

        for (uint256 i = 0; i < ids.length; i++) {
            IERC721(NFT_ADDRESS).transferFrom(
                msg.sender,
                address(this),
                ids[i]
            );
        }

        _mint(
            msg.sender,
            (NFT_VALUE.mul(ids.length)).mul(uint256(50).sub(adminFee)).div(50)
        );
    }

    // redeem nft and burn tokens
    function redeem(
        uint256[] calldata ids,
        uint256[] calldata amounts,
        address receipient
    ) external {

        if (NFT_TYPE == 1155) {
            if (ids.length == 1) {
                _burn(msg.sender, NFT_VALUE.mul(amounts[0]));
                _redeem1155(
                    address(this),
                    receipient,
                    ids[0],
                    amounts[0]
                );
            } else {
                _batchRedeem1155(
                    address(this),
                    receipient,
                    ids,
                    amounts
                );
            }
        } else if (NFT_TYPE == 721) {
            _burn(msg.sender, NFT_VALUE.mul(ids.length));
            for (uint256 i = 0; i < ids.length; i++) {
                _redeem721(address(this), receipient, ids[i]);
            }
        }

        emit Redeem(ids, amounts);
    }

    function _redeem1155(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount
    ) internal {
        IERC1155(NFT_ADDRESS).safeTransferFrom(from, to, tokenId, amount, "");
    }

    function _batchRedeem1155(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal {
        uint256 amount = 0;
        for (uint256 i = 0; i < ids.length; i++) {
            amount+= amounts[i];
        }
        // burn tokens
        _burn(msg.sender, NFT_VALUE.mul(amount));

        IERC1155(NFT_ADDRESS).safeBatchTransferFrom(
            from,
            to,
            ids,
            amounts,
            "0x0"
        );
    }

     function _redeem721(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        // lockedNfts.remove(_tokenId);
        IERC721(NFT_ADDRESS).safeTransferFrom(from, to, tokenId);
    }


    function swap721(uint256 IdIn, uint256 IdOut) external {
        IERC721(NFT_ADDRESS).safeTransferFrom(msg.sender, address(this), IdIn);
        IERC721(NFT_ADDRESS).safeTransferFrom(address(this), msg.sender, IdOut);
        emit Swap721(IdIn, IdOut);
    }

    // set new params
    function setInfo(
        uint256 nftType,
        string calldata _name,
        string calldata _symbol,
        uint256 nftValue
    ) external {
        require(msg.sender == PAIR_FACTORY, "Sender is not allowed to change pair info");
        NFT_TYPE = nftType;
        name = name;
        symbol = symbol;
        NFT_VALUE = nftValue;
    }

}