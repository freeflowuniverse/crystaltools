# Mermaid

Instructions see https://mermaid-js.github.io/mermaid/#/

just put the mermaid code in `mermaid` block

![](img/mermaid.png)

### example:

```
journey
    title My working day
    section Go to work
      Make tea: 5: Me
      Go upstairs: 3: Me
      Do work: 1: Me, Cat
    section Go home
      Go downstairs: 5: Me
      Sit down: 5: Me
```

this results in the following

![](img/mermaid2.png)

## How to use links

```
graph TB
    subgraph Stellar Blockchain
        stellar_blockchain --- account1a
        stellar_blockchain --- account2a
        stellar_blockchain --- account3a
        account1a --> money_user_1
        account2a --> money_user_2
        account3a --> money_user_3
        click stellar_blockchain "/threefold/#stellar_blockchain"

    end
    subgraph ThreeFold Blockchain
        TFBlockchain --- account1b[account 1]
        TFBlockchain --- account2b[account 2]
        TFBlockchain --- account3b[account 3]
        account1b --- smart_contract_data_1
        account2b --- smart_contract_data_2
        account3b --- smart_contract_data_3
        click TFBlockchain "/threefold/#tfchain"
    end

    account1b ---- account1a[account 1]
    account2b ---- account2a[account 2]
    account3b ---- account3a[account 3]

    consensus_engine --> smart_contract_data_1[fa:fa-ban smart contract metadata]
    consensus_engine --> smart_contract_data_2[fa:fa-ban smart contract metadata ]
    consensus_engine --> smart_contract_data_3[fa:fa-ban smart contract metadata]
    consensus_engine --> account1a
    consensus_engine --> account2a
    consensus_engine --> account3a
    click consensus_engine "/threefold/#consensus_engine"

```

see ```click $name "$thelink"```

nameis the name of the element

example

```
click consensus_engine "/threefold/#consensus_engine"
```

this liks to threeefold main wiki for page or def consensus_engine

