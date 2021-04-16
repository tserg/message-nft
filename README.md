# Message NFT

This is an implementation of ERC721 in Vyper. Each NFT contains a message that is publicly viewable by all without any restrictions. Original ERC721 code is taken from the [official Vyper repository](https://github.com/vyperlang/vyper/blob/master/examples/tokens/ERC721.vy)

The following additional extensions have been implemented:
- ERC721Metadata
- ERC721Enumerable

## Installation

We use the Brownie framework for development and deployment. Please refer to the instructions below for installation.

### Vyper

See the (Vyper documentation)[https://vyper.readthedocs.io/en/latest/installing-vyper.html] for build instructions.

### Virtual Enviornment

We recommend working within a virtual environment whenever using Python for projects. This keeps your dependencies for each project separate and organaized. Instructions for setting up a virual enviornment for your platform can be found in the [python docs](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/)

### PIP dependencies

Once you have your virtual environment setup and running, install dependencies by running:
```bash
pip install -r requirements.txt
```
This will install all of the required packages we selected within the `requirements.txt` file.

## Testing

To run the tests, run `brownie test` in your Python console.

## Deployment

To deploy the contract on your local instance, run `brownie run deploy.py --network development`.

For deployment on Ropsten, replace `development` with `ropsten`.
