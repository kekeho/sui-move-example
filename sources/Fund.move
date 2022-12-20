module fund::project {
    use sui::transfer;
    use sui::sui::SUI;
    use sui::object::{Self, UID};
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{TxContext, sender};
    use std::string::{Self, String};


    struct Project has key {
        id: UID,
        title: String,
        targetAmount: u64,
        balance: Balance<SUI>,
        owner: address,
    }


    entry public fun startProject(title_bytes: vector<u8>, targetAmount: u64, ctx: &mut TxContext) {
        let p = Project {
            id: object::new(ctx),
            title: string::utf8(title_bytes),
            targetAmount: targetAmount,
            balance: balance::zero(),
            owner: sender(ctx)
        };

        transfer::share_object(p);
    }


    entry public fun support(p: &mut Project, coin: &mut Coin<SUI>, amount: u64) {
        let coin_balance = coin::balance_mut(coin);
        let paid = balance::split(coin_balance, amount);

        balance::join(&mut p.balance, paid);
    }


    entry public fun withdraw(p: &mut Project, ctx: &mut TxContext) {
        let value = balance::value(&p.balance);
        assert! (value >= p.targetAmount, 0);
        assert! (sender(ctx) == owner(p), 0);

        let collectedCoin = coin::take(&mut p.balance, value, ctx);
        transfer::transfer(collectedCoin, owner(p));
    }

    fun owner(p: &Project): address {
        return p.owner
    }

}