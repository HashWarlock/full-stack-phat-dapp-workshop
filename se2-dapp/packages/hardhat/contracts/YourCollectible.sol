pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import 'base64-sol/base64.sol';

import './HexStrings.sol';
import './ToColor.sol';

contract YourCollectible is ERC721, Ownable {

    using Strings for uint256;
    using HexStrings for uint160;
    using ToColor for bytes3;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    mapping (uint256 => bytes3) public color;
    mapping(address authorizedMinter => bool authorized) public authorizedMinters;

    uint256 mintDeadline = block.timestamp + 72 hours;

    event AuthorizedMinterSet(address indexed minter, bool authorized);

    modifier onlyAuthorizedMinter() {
        require(authorizedMinters[msg.sender], "FrameNFTs: Mint must be triggered by API");
        _;
    }

    modifier onlyBelowMaxMint(address to) {
        require(mintCount[to] < maxMintPerAddress, "FrameNFTs: Max mint reached");
        _;
    }

    constructor(address yourContract) public ERC721("Yeahhh! Buoy SE2", "YBSE2") {
        // HELP ME! Deploy the buoysss
        maxMintPerAddress = 1;
        authorizedMinters[msg.sender] = true;
        authorizedMinters[yourContract] = true;
        emit AuthorizedMinterSet(msg.sender, true);
        emit AuthorizedMinterSet(yourContract, true);
    }



    function mintItem(address to)
    public onlyAuthorizedMinter onlyBelowMaxMint(to)
    returns (uint256)
    {
        require( block.timestamp < mintDeadline, "DONE MINTING");
        _tokenIds.increment();

        uint256 id = _tokenIds.current();
        _mint(msg.sender, id);

        bytes32 predictableRandom = keccak256(abi.encodePacked( blockhash(block.number-1), msg.sender, address(this) ));
        color[id] = bytes2(predictableRandom[0]) | ( bytes2(predictableRandom[1]) >> 8 ) | ( bytes3(predictableRandom[2]) >> 16 );

        return id;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        require(_exists(id), "not exist");
        string memory name = string(abi.encodePacked('Yeahhh! Buoy #',id.toString()));
        string memory description = string(abi.encodePacked('This Buoy is the color #',color[id].toColor(),' & it saved ',(uint160(ownerOf(id))).toHexString(20),'\'s life!!!'));
        string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));

        return
            string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            name,
                            '", "description":"',
                            description,
                            '", "attributes": [{"trait_type": "color", "value": "#',
                            color[id].toColor(),
                            '"}], "owner":"',
                            (uint160(ownerOf(id))).toHexString(20),
                            '", "image": "',
                            'data:image/svg+xml;base64,',
                            image,
                            '"}'
                        )
                    )
                )
            )
        );
    }

    function generateSVGofTokenById(uint256 id) internal view returns (string memory) {

        string memory svg = string(abi.encodePacked(
            '<svg width="640" height="640" xmlns="http://www.w3.org/2000/svg"> xmlns:xlink="http://www.w3.org/1999/xlink" enable-background="new 0 0 64 64" version="1.1" xml:space="preserve">',
            renderTokenById(id),
            '</svg>'
        ));

        return svg;
    }

    // Visibility is `public` to enable it being called by other contracts for composition.
    function renderTokenById(uint256 id) public view returns (string memory) {
        string memory render = string(abi.encodePacked(
            '<g class="layer">',
            '<g class="layer" id="svg_11" stroke="',
            color[id].toColor(),
            '" fill="',
            color[id].toColor(),
            '">',
            '<circle cx="320" cy="320" fill="none" id="svg_1" r="310" stroke-miterlimit="100" stroke-width="20"/>',
            '<circle cx="320" cy="320" id="svg_2" r="150" stroke-miterlimit="100" stroke-width="20"/>',
            '<line fill="none" id="svg_3" stroke-miterlimit="100" stroke-width="20" x1="260" x2="260" y1="180" y2="10"/>',
            '<line fill="none" id="svg_4" stroke-miterlimit="100" stroke-width="20" x1="380" x2="380" y1="180" y2="10"/>',
            '<line fill="none" id="svg_5" stroke-miterlimit="100" stroke-width="20" x1="260" x2="260" y1="630" y2="460"/>',
            '<line fill="none" id="svg_6" stroke-miterlimit="100" stroke-width="20" x1="380" x2="380" y1="630" y2="460"/>',
            '<line fill="none" id="svg_7" stroke-miterlimit="100" stroke-width="20" x1="460" x2="630" y1="260" y2="260"/>',
            '<line fill="none" id="svg_8" stroke-miterlimit="100" stroke-width="20" x1="460" x2="630" y1="380" y2="380"/>',
            '<line fill="none" id="svg_9" stroke-miterlimit="100" stroke-width="20" x1="10" x2="180" y1="260" y2="260"/>',
            '<line fill="none" id="svg_10" stroke-miterlimit="100" stroke-width="20" x1="10" x2="180" y1="380" y2="380"/>',
            '<circle cx="320" cy="320" fill="none" id="svg_2" r="130" stroke-miterlimit="100" stroke-width="20" stroke="white"/>',
            '<circle cx="320" cy="320" fill="none" id="svg_2" r="125" stroke-miterlimit="100" stroke-width="10" stroke="#DFDFDF"/>',
            '<use id="svg_12" transform="matrix(0.20712 0 0 0.20712 0 0)" x="102.6" xlink:href="#svg_11" y="102.6"/>',
            '</g>',
            '</g>',
            '<defs>',
            '<symbol height="102" id="svg_13" viewBox="0 0 103 102" width="103" xmlns="http://www.w3.org/2000/svg">',
            '<rect fill="pink" id="svg_15"/>',
            '<path d="m69.41,42.5l1.5,-2.69l1.63,2.69l10.48,16.69l-12.07,6.75l-11.83,-6.75l10.29,-16.69z" fill="white" id="svg_16"/>',
            '<path d="m70.95,69.25l-10.29,-5.56l10.29,15.38l10.23,-15.57l-10.23,5.75z" fill="white" id="svg_17"/>',
            '<path d="m70.95,65.93l0,-24.08l0,-2l12.11,19.33l-12.11,6.75z" fill="#DFDFDF" id="svg_18"/>',
            '<path d="m70.96,79.05l0.08,-9.75l10.17,-5.84l-10.25,15.59z" fill="#DFDFDF" id="svg_19"/>',
            '<path d="m34.41,21.69l0,2.92l0,0l0,3.14l-7.6,0l0,0.01l-1.27,0l-4.16,8.73l13.03,0l0,3.48l0,0l0,29.48c0,4.08 -3.3,7.38 -7.37,7.38l-2.31,0l-4.92,7.25l42.61,0l-5.07,-7.25l-5.57,0c-4.07,0 -7.37,-3.3 -7.37,-7.38l-0.01,-25.79c0.11,-3.95 3.33,-7.13 7.3,-7.17l27.85,0l-4.89,-8.73l-21.06,0l0,-0.01l-9.2,0l0,-3.14l0,0l0,-6.29l-9.99,3.37z" fill="white" id="svg_20"/>',
            '<path d="m39.88,19.85l0,56.7c0.09,-1.59 1.17,-5.69 4.48,-7.45l0,-18.23l0.11,0.03l0,-7.07c0,-4.07 3.3,-7.37 7.37,-7.37l27.74,0l-2.63,-4.59l-27.04,0c-3.78,0 -5.55,2.69 -5.55,2.69l0.08,-16.25l-4.56,1.54z" fill="#DFDFDF" id="svg_21"/>',
            '<path d="m23.62,31.79l-2.29,4.72l13.09,0l0,-4.72l-10.8,0z" fill="#DFDFDF" id="svg_22"/>',
            '</symbol>',
            '</defs>',
            '<g class="layer">',
            '<title>SE2</title>',
            '<use id="svg_14" transform="matrix(2.0712 0 0 2.0712 0 0)" x="102.82" xlink:href="#svg_13" y="101.87"/>',
            '</g>'
        ));

        return render;
    }

    // Only the owner can set the max mint per address
    function setMaxMintPerAddress(uint256 _maxMintPerAddress) public onlyOwner {
        maxMintPerAddress = _maxMintPerAddress;
    }

    // Only the owner can set authorized minters. True = authorized, false =
    // unauthorized
    function setAuthorizedMinter(address minter, bool authorized) public onlyOwner {
        authorizedMinters[minter] = authorized;

        emit AuthorizedMinterSet(minter, authorized);
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
