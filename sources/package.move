module simple_faucet::package {
    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::resource_account;

    friend simple_faucet::faucet;

    struct PackageManager has key {
        signer_cap: SignerCapability
    }

    fun init_module(account: &signer) {
        let signer_cap =
            resource_account::retrieve_resource_account_cap(
                account, @simple_faucet_deployer
            );
        move_to(account, PackageManager { signer_cap })
    }

    public(friend) fun get_signer(): signer acquires PackageManager {
        let PackageManager { signer_cap } = borrow_global<PackageManager>(@simple_faucet);
        account::create_signer_with_capability(signer_cap)
    }
}
