// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface ISifu is IERC20 {
    function mint(address account, uint256 amount) external;
}

contract Migration is Ownable {
    using SafeERC20 for IERC20;
    using SafeERC20 for ISifu;
    using EnumerableSet for EnumerableSet.AddressSet;

    // Old token address
    IERC20 public prevToken;

    // New token address
    ISifu public sifuToken;

    // Exchange rate for swapping old token to new one
    uint256 public exchangeRate;

    // Exchange rate divider
    uint256 constant DIVIDER = 1e18;

    // deadline - migration end timestamp
    uint256 public deadline;

    // Declare a set state variable
    EnumerableSet.AddressSet private blacklist;

    // events
    event SetExchangeRate(uint256 rate);
    event SetDeadline(uint256 deadline);
    event Migrated(address account, uint256 prev, uint256 migrated);
    event AddedToBlacklist(address account);
    event RemovedFromBlacklist(address account);

    modifier isBlacklist() {
        require(
            blacklist.contains(msg.sender),
            "Address is listed in blacklist"
        );
        _;
    }

    /**
     * @notice constructor
     * @param _prev address of previous token
     * @param _migrated address of migrated token
     * @param _rate exchange rate
     * @param _deadline deadline timestamp
     */
    constructor(
        address _prev,
        address _migrated,
        uint256 _rate,
        uint256 _deadline
    ) {
        require(_prev != address(0), "Invalid address");
        require(_migrated != address(0), "Invalid address");
        require(_rate != 0, "Invalid exchange rate");
        require(_deadline >= block.timestamp, "Invalid deadline timestamp");

        prevToken = IERC20(_prev);
        sifuToken = ISifu(_migrated);
        exchangeRate = _rate;

        emit SetExchangeRate(_rate);
    }

    function migrate(uint256 _amount) external isBlacklist {
        require(_amount != 0, "Invalid migration amount");
        require(exchangeRate != 0, "ExchangeRate not set");

        // 1. receive previous token
        prevToken.safeTransferFrom(msg.sender, address(this), _amount);

        // 2. migrate to new token
        uint256 migratedAmt = (_amount * exchangeRate) / DIVIDER;
        require(migratedAmt != 0, "Invalid migrated amount");

        sifuToken.safeTransfer(msg.sender, migratedAmt);
        emit Migrated(msg.sender, _amount, migratedAmt);
    }

    ///////////////////////
    /// Owner Functions ///
    ///////////////////////

    /**
     * @notice Set exchange rate
     * @param _rate new exchange rate
     */
    function setExchangeRate(uint256 _rate) external onlyOwner {
        require(_rate != 0, "Invalid exchange rate");

        exchangeRate = _rate;
        emit SetExchangeRate(_rate);
    }

    /**
     * @notice Set deadline
     * @param _deadline new deadline
     */
    function setDeadline(uint256 _deadline) external onlyOwner {
        require(_deadline >= block.timestamp, "Invalid deadline timestamp");

        deadline = _deadline;
        emit SetDeadline(_deadline);
    }

    /**
     * @notice Add to blacklist
     * @param _list array of blacklist accounts
     */
    function addBlacklist(address[] memory _list) external onlyOwner {
        require(_list.length != 0, "Invalid array length");

        for (uint i; i < _list.length; ) {
            if (!blacklist.contains(_list[i])) blacklist.add(_list[i]);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Remove from blacklist
     * @param _list array of accounts
     */
    function removeBlacklist(address[] memory _list) external onlyOwner {
        require(_list.length != 0, "Invalid array length");

        for (uint i; i < _list.length; ) {
            if (blacklist.contains(_list[i])) blacklist.remove(_list[i]);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Emergency Withdraw to Owner
     */
    function emergencyWithdraw(IERC20 _token) external onlyOwner {
        _token.safeTransfer(owner(), _token.balanceOf(address(this)));
    }
}
