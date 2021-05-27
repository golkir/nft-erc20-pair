pragma solidity >=0.6.2 <0.8.0;

// Interface for our erc20 token
interface INAFTAPair {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenOwner)
        external
        view
        returns (uint256 balance);

    function allowance(address tokenOwner, address spender)
        external
        view
        returns (uint256 remaining);

    function transfer(address to, uint256 tokens)
        external
        returns (bool success);

    function approve(address spender, uint256 tokens)
        external
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) external returns (bool success);

    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    function NFT_TYPE() external view returns (uint256);

    function NFT_ADDRESS() external view returns (address);

    function setInfo(
        uint256 nftType,
        string calldata name,
        string calldata symbol,
        uint256 nftValue
    ) external;

    function getPairInfo()
        external
        view
        returns (
            uint256 nftType,
            string memory name,
            string memory symbol,
            uint256 supply
        );

    function init(
        string calldata name,
        string calldata symbol,
        address nftAddress,
        uint256 nftType
    ) external;
}