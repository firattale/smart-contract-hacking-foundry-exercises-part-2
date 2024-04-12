// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

interface IPair {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Burn(
    address indexed sender,
    uint256 amount0,
    uint256 amount1,
    address indexed to
  );
  event Mint(address indexed sender, uint256 amount0, uint256 amount1);
  event Swap(
    address indexed sender,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out,
    address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function MINIMUM_LIQUIDITY() external view returns (uint256);

  function PERMIT_TYPEHASH() external view returns (bytes32);

  function allowance(address, address) external view returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function balanceOf(address) external view returns (uint256);

  function burn(address to) external returns (uint256 amount0, uint256 amount1);

  function decimals() external view returns (uint8);

  function factory() external view returns (address);

  function getReserves()
    external
    view
    returns (
      uint112 _reserve0,
      uint112 _reserve1,
      uint32 _blockTimestampLast
    );

  function initialize(address _token0, address _token1) external;

  function kLast() external view returns (uint256);

  function mint(address to) external returns (uint256 liquidity);

  function name() external view returns (string memory);

  function nonces(address) external view returns (uint256);

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  function price0CumulativeLast() external view returns (uint256);

  function price1CumulativeLast() external view returns (uint256);

  function skim(address to) external;

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes memory data
  ) external;

  function symbol() external view returns (string memory);

  function sync() external;

  function token0() external view returns (address);

  function token1() external view returns (address);

  function totalSupply() external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);
}