```vyper
# This contract aims to arbitrage the price difference between OpenSea and Blur
# It executes trades when there's a 20% or more price difference

# Import necessary interfaces for interacting with ERC721 (NFT) contracts
import erc721 as interface.ERC721

# Define the contract structure
contract NFTArbiter:

    # Define the addresses of the OpenSea and Blur marketplaces
    opensea_address: public(address)
    blur_address: public(address)

    # Define the minimum price difference threshold for arbitrage (20%)
    min_price_difference: public(uint256) = 20

    # Constructor to set the marketplace addresses
    def __init__(_opensea_address: address, _blur_address: address):
        self.opensea_address = _opensea_address
        self.blur_address = _blur_address

    # Function to check the price of an NFT on OpenSea
    @external
    def get_opensea_price(token_id: uint256) -> uint256:
        # Call the OpenSea marketplace contract to get the price
        opensea_contract: address = self.opensea_address
        return interface.ERC721(opensea_contract).getPrice(token_id)

    # Function to check the price of an NFT on Blur
    @external
    def get_blur_price(token_id: uint256) -> uint256:
        # Call the Blur marketplace contract to get the price
        blur_contract: address = self.blur_address
        return interface.ERC721(blur_contract).getPrice(token_id)

    # Function to calculate the percentage difference between two prices
    @internal
    def calculate_price_difference(price1: uint256, price2: uint256) -> uint256:
        if price1 > price2:
            return ((price1 - price2) * 100) / price2
        else:
            return ((price2 - price1) * 100) / price1

    # Function to execute the arbitrage trade
    @external
    def execute_arbitrage(token_id: uint256):
        # Get the prices from both marketplaces
        opensea_price: uint256 = self.get_opensea_price(token_id)
        blur_price: uint256 = self.get_blur_price(token_id)

        # Calculate the price difference percentage
        price_difference: uint256 = self.calculate_price_difference(opensea_price, blur_price)

        # Check if the price difference is greater than or equal to 20%
        if price_difference >= self.min_price_difference:
            # If OpenSea price is lower, buy from OpenSea and sell on Blur
            if opensea_price < blur_price:
                # Buy NFT from OpenSea
                interface.ERC721(self.opensea_address).buy(token_id, opensea_price)
                # Sell NFT on Blur
                interface.ERC721(self.blur_address).sell(token_id, blur_price)

            # If Blur price is lower, buy from Blur and sell on OpenSea
            else:
                # Buy NFT from Blur
                interface.ERC721(self.blur_address).buy(token_id, blur_price)
                # Sell NFT on OpenSea
                interface.ERC721(self.opensea_address).sell(token_id, opensea_price)

        # If the price difference is less than 20%, do nothing
        else:
            pass

    # Fallback function to receive Ether
    @payable
    def __default__():
        pass
```

### Explanation of Key Parts:

- **Marketplace Addresses**: The contract takes the addresses of OpenSea and Blur marketplaces as inputs in the constructor.
- **Price Checking Functions**: `get_opensea_price` and `get_blur_price` functions are used to fetch the current prices of an NFT on both platforms.
- **Price Difference Calculation**: The `calculate_price_difference` function calculates the percentage difference between two prices.
- **Arbitrage Execution**: The `execute_arbitrage` function checks if the price difference is 20% or more. If so, it buys from the cheaper platform and sells on the more expensive one.

### Note:
- This script assumes that the OpenSea and Blur contracts have methods like `getPrice`, `buy`, and `sell`. In a real-world scenario, you would need to refer to the actual contract interfaces provided by these platforms.
- The fallback function allows the contract to receive Ether, which might be necessary for buying NFTs.

