pragma solidity >=0.6.2 <0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";

import "./NAFTAPair.sol";
import "./interfaces/INAFTAPair.sol";

contract NAFTAFactory is Initializable, OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;

    mapping(address => address) public nftToWrapped;
    mapping(uint256 => address) public wrappedToNft;

    uint256 public ntokens;
    uint256 public adminFee;

    event pairCreated(
        address indexed originalNFT,
        address newPair,
        uint256 _type
    );

    constructor() public {}

    function initialize() public initializer {
        OwnableUpgradeable.__Ownable_init();
        adminFee = 10;
    }

    function createNAFTAPair(
        string calldata name,
        address nft,
        uint256 nftType
    ) external {
        // if pair exists then throw.
        require(
            nftToWrapped[nft] == address(0),
            "A wrapped token for this NFT already exists"
        );

        NAFTAPair naftaPair = new NAFTAPair();

        naftaPair.init(
            string(abi.encodePacked("NAFTA:", name)),
            string(abi.encodePacked("n", name)),
            nft,
            nftType
        );
        nftToWrapped[nft] = address(naftaPair);
        wrappedToNft[ntokens] = nft;
        ntokens+=1;
        emit pairCreated(nft, address(naftaPair), nftType);
    }

    function changeFee(uint256 newFee) external onlyOwner {
        adminFee = newFee;
    }

    function getPairInfo(uint256 index)
        public
        view
        returns (
            address naftaPair,
            address nftOrigin,
            uint256 nftType,
            string memory name,
            string memory symbol,
            uint256 supply
        )
    {
        nftOrigin = wrappedToNft[index];
        naftaPair = nftToWrapped[nftOrigin];
        
        (nftType, name, symbol, supply) = INAFTAPair(naftaPair).getPairInfo();
    }


    function setPairInfo(
        address pair,
        uint256 nftType,
        string calldata name,
        string calldata symbol,
        uint256 value
    ) external onlyOwner {
        INAFTAPair(pair).setInfo(nftType, name, symbol,value);
    }

}

// edited