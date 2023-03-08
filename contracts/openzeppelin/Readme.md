This folder contains following modules fetched from github without further changes:

- [openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts): Fetched at commit #[eedca5d](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/eedca5d873a559140d79cc7ec674d0e28b2b6ebd)

Modifications:
- token/ERC1155/IERC1155Receiver.sol @ line 6:
    import "../../utils/introspection/IERC165.sol";
    ->
    import "../../../safe/interfaces/IERC165.sol";

- utils/introspection/ERC165.sol @ line 6:
    import "./IERC165.sol";
    ->
    import "../../../safe/interfaces/IERC165.sol";