# XRef Token Contract

### Sumary
* Stake REF token to lock in the contract and get XREF on price P,  
XREF_amount = staked_REF / P,  
where P = locked_REF_token_amount / XREF_total_supply.  

* Redeem REF by unstake using XREF token on price P,  
redeemed_REF = unstaked_XREF * P,  
where P = locked_REF_token_amount / XREF_total_supply. 

* Anyone can add REF as reward for those locked REF users.  
locked_REF_token amount would increase `reward_per_sec` per second.  

* Owner can modify `reward_per_sec`.

### Compiling

You can build release version by running next scripts inside each contract folder:

```
source ./build_docker.sh
```

### Deploying to TestNet

To deploy to TestNet, you can use next command:
```
near dev-deploy
```

This will output on the contract ID it deployed.

### Contract Metadata
```rust
pub struct ContractMetadata {
    pub version: String,
    pub owner_id: AccountId,
    /// backend locked token id
    pub locked_token: AccountId,
    /// reward token that haven't distribute yet
    pub undistribute_reward: U128,
    /// backend locked token amount
    pub locked_token_amount: U128,
    /// XREF token supply
    pub supply: U128,
    /// previous reward distribution time in nano secs
    pub prev_distribution_time: u64,
    /// reward token amount per seconds
    pub reward_per_sec: U128,
}
```

### FT Metadata
```rust
FungibleTokenMetadata {
    spec: FT_METADATA_SPEC.to_string(),
    name: String::from("XRef Finance Token"),
    symbol: String::from("XREF"),
    // see code for the detailed icon content
    icon: Some(String::from("data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0i......=")),
    reference: None,
    reference_hash: None,
    decimals: 18,
}
```

### Initialize

```shell
export REF_TOKEN=ref.token
export XREF_TOKEN=xref.token
export XREF_OWNER=xref.owner
near call $XREF_TOKEN new '{"owner_id": "'$XREF_OWNER'", "locked_token": "'$REF_TOKEN'"}' --account_id=$XREF_TOKEN
```

### Usage

#### view functions
```bash
# contract metadata gives contract details
near view $XREF_TOKEN contract_metadata
# get the X-REF / REF price in 1e8
near view $XREF_TOKEN get_virtual_price

# ************* from NEP-141 *************
# see user if registered
near view $XREF_TOKEN storage_balance_of '{"account_id": "alice.testnet"}'
# token metadata
near view $XREF_TOKEN ft_metadata
# user token balance
near view $XREF_TOKEN ft_balance_of '{"account_id": "alice.testnet"}'
```

#### register
from NEP-141.
```bash
near view $XREF_TOKEN storage_balance_of '{"account_id": "alice.testnet"}'
near call $XREF_TOKEN storage_deposit '{"account_id": "alice.testnet", "registration_only": true}' --account_id=alice.testnet --amount=0.1
```

#### stake REF to get XREF
```bash
near call $REF_TOKEN ft_transfer_call '{"receiver_id": "'$XREF_TOKEN'", "amount": "10'$ZERO18'", "msg": ""}' --account_id=alice.testnet --amount=$YN --gas=$GAS100
```

#### add REF as reward
```bash
near call $REF_TOKEN ft_transfer_call '{"receiver_id": "'$XREF_TOKEN'", "amount": "10'$ZERO18'", "msg": "reward"}' --account_id=alice.testnet --amount=$YN --gas=$GAS100
```

#### unstake XREF get REF and reward back
```bash
near call $XREF_TOKEN unstake '{"amount": "8'$ZERO18'"}' --account_id=alice.testnet --amount=$YN --gas=$GAS100
```

#### owner modify reward_per_sec
```bash
near call $XREF_TOKEN modify_reward_per_sec '{"reward_per_sec": "1'$ZERO18'"}' --account_id=$XREF_OWNER --gas=$GAS100
```