module fund::project {
    use sui::transfer;
    use sui::sui::SUI;
    use sui::object::{Self, UID};
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{TxContext, sender};

    use std::string::{Self, String};
    use std::vector;

    /// Structure defining crowdfunding project data
    struct Project has key, store {
        id: UID,  // For key ability
        title: String,  // Project title
        targetAmount: u64,  // Target amount to collect
        balance: Balance<SUI>,  // Store the money collected
        supporters: vector<address>,  // List of supporters
        owner: address,  // Project owner's address
    }


    /// Create new crowdfunding project
    /// Args:
    ///     title_bytes: Project title which encoded with UTF-8
    ///     targetAmount: Target amount to collect
    entry public fun startProject(title_bytes: vector<u8>, targetAmount: u64, ctx: &mut TxContext) {
        // New project object
        let p = Project {
            id: object::new(ctx),
            title: string::utf8(title_bytes),
            targetAmount: targetAmount,
            balance: balance::zero(),
            supporters: vector::empty(),
            owner: sender(ctx)
        };

        // Publish project as share object
        transfer::share_object(p);
    }


    /// Send coin to project
    /// Args:
    ///     p: Project
    ///     coin: Sui Coin to be transferred to the project
    ///     amount: Amount to be transferred to the project
    entry public fun support(p: &mut Project, coin: &mut Coin<SUI>, amount: u64, ctx: &mut TxContext) {
        // Withdraw the amount from coin
        let coin_balance = coin::balance_mut(coin);
        let withdrawn = balance::split(coin_balance, amount);

        // Send withdrawn balance to project
        balance::join(&mut p.balance, withdrawn);

        // Record address as supporter
        vector::push_back(&mut p.supporters, sender(ctx));
    }


    /// Withdraw balance
    /// Args:
    ///     p: Project
    entry public fun withdraw(p: &mut Project, ctx: &mut TxContext) {
        // Project balance must exceed targetAmount
        let value = balance::value(&p.balance);
        assert! (value >= p.targetAmount, 0);

        // Sender of transaction must be the project owner
        assert! (sender(ctx) == owner(p), 0);

        // Transfer coin to owner
        let collectedCoin = coin::take(&mut p.balance, value, ctx);
        transfer::transfer(collectedCoin, owner(p));
    }

    fun owner(p: &Project): address {
        return p.owner
    }
}