// SPDX-License-Identifier: MIT


pragma solidity ^0.6.6;


interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

contract FundMe{
    mapping(address => uint256) public addressToAmountFunded;
    address public owner;
    address[] public funders;
    AggregatorV3Interface public priceFeed;

    //global pricefeesd
    constructor(address _priceFeed) public {
      priceFeed = AggregatorV3Interface(_priceFeed);
      owner = msg.sender;
    }


    function fund() public payable{
      //50$
      uint256 minimumUSD = 50 * 10 ** 18;
      //setting up minimum usd
      require(getConversionRate(msg.value) >= minimumUSD, "Need more eth!!!");
      addressToAmountFunded[msg.sender] += msg.value;
      funders.push(msg.sender);
      //msg.sender => sender of the function and msg.value = value of tehe function
      // what the eth->usd is? (conversion rate)
    }
    function getVersion() public view returns (uint256){
        //interacting with another contract from our contract
        //contract that has the aggregator functions at the given address
        return priceFeed.version();
    }

    function getPrice() public view returns(uint256){
        (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ) = priceFeed.latestRoundData();
    return uint256(answer * 10000000000);
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256){
      uint256 ethPrice = getPrice();
      uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
      //adjusting extra zeroes
      return ethAmountInUsd;
    }
    function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        // return (minimumUSD * precision) / price;
        // We fixed a rounding error found in the video by adding one!
        return ((minimumUSD * precision) / price) + 1;
    }
    modifier onlyOwner {
      require(msg.sender == owner);
      _;
    }
    function withdraw() payable onlyOwner public {
      //require msg.sender = owner
      address payable ourAddress = payable(owner);
      ourAddress.transfer(address(this).balance);
      for(uint256 funderIndex = 0; funderIndex<funders.length; funderIndex++ ){
        address funder = funders[funderIndex];
        addressToAmountFunded[funder] = 0;
      }
      funders = new address[](0);
    }
}