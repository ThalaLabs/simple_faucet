module simple_faucet::faucet {
    use std::option::Option;
    use std::signer;
    use std::string;
    use std::string::String;
    use std::vector;
    use aptos_framework::event;
    use aptos_framework::fungible_asset;
    use aptos_framework::fungible_asset::{Metadata, MintRef, BurnRef, TransferRef};
    use aptos_framework::object;
    use aptos_framework::object::Object;
    use aptos_framework::primary_fungible_store;

    const ERR_FAUCET_NOT_EXIST: u64 = 1;
    const ERR_ARRAY_LENGTH_MISMATCH: u64 = 2;

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Faucet has key {
        mint_ref: MintRef,
        transfer_ref: TransferRef,
        burn_ref: BurnRef
    }

    #[event]
    struct Created has drop, store {
        creator: address,
        metadata: Object<Metadata>
    }

    public entry fun create(
        account: &signer,
        name: String,
        symbol: String,
        decimals: u8,
        maximum_supply: Option<u128>
    ) {
        let faucet_cref = object::create_sticky_object(@simple_faucet);
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            &faucet_cref,
            maximum_supply,
            name,
            symbol,
            decimals,
            string::utf8(b""),
            string::utf8(b"")
        );

        let faucet_signer = object::generate_signer(&faucet_cref);
        move_to(
            &faucet_signer,
            Faucet {
                mint_ref: fungible_asset::generate_mint_ref(&faucet_cref),
                transfer_ref: fungible_asset::generate_transfer_ref(&faucet_cref),
                burn_ref: fungible_asset::generate_burn_ref(&faucet_cref)
            }
        );

        event::emit(
            Created {
                creator: signer::address_of(account),
                metadata: object::object_from_constructor_ref<Metadata>(&faucet_cref)
            }
        )
    }

    public entry fun mint(
        metadata: Object<Metadata>, amount: u64, account_addr: address
    ) acquires Faucet {
        assert_faucet_address_exists(metadata);

        let faucet = borrow_global<Faucet>(object::object_address(&metadata));
        primary_fungible_store::mint(&faucet.mint_ref, account_addr, amount);
    }

    public entry fun mint_to(
        metadata: Object<Metadata>, amounts: vector<u64>, recipients: vector<address>
    ) acquires Faucet {
        assert!(
            vector::length(&amounts) == vector::length(&recipients),
            ERR_ARRAY_LENGTH_MISMATCH
        );
        assert_faucet_address_exists(metadata);

        let mint_ref = &borrow_global<Faucet>(object::object_address(&metadata)).mint_ref;
        let recipient_stores = vector::map(
            recipients,
            |recipient| primary_fungible_store::ensure_primary_store_exists(
                recipient, metadata
            )
        );

        let i = 0;
        while (i < vector::length(&amounts)) {
            let amount = *vector::borrow(&amounts, i);
            let store = *vector::borrow(&recipient_stores, i);
            fungible_asset::mint_to(mint_ref, store, amount);
            i = i + 1;
        };
    }

    public fun burn(
        account: &signer, metadata: Object<Metadata>, amount: u64
    ) acquires Faucet {
        assert_faucet_address_exists(metadata);

        let faucet = borrow_global<Faucet>(object::object_address(&metadata));
        primary_fungible_store::burn(
            &faucet.burn_ref, signer::address_of(account), amount
        );
    }

    inline fun assert_faucet_address_exists(metadata: Object<Metadata>) {
        assert!(exists<Faucet>(object::object_address(&metadata)), ERR_FAUCET_NOT_EXIST)
    }
}
