{{ config( alias='nft_curated', tags=['static']) }}

SELECT LOWER(contract_address) AS contract_address, name, symbol
FROM (VALUES
        (0x8bb765AE3e2320fd9447889D10b9DC7CE4970DA5, 'TinyDaemons', 'TINYDMN'),
        (0x8073a39bc8f89d9def372fABc20C5E4b200684ba, 'WaveDaemons', 'WAVEDMN'),
        (0x3dA92Fb1cA64a9592aCa25813F320867eDf61E34, 'Fantom WolfLand Games: Breeding', 'WBABY'),
        (0xae083c497926c9d33cF520E0AfcF81b2840aa82d, 'XonasWorld', 'XC'),
        (0x668d40Fb53871Aa139aE306Bca88F00bB8C475fB, 'Simpin Santa', 'Simp'),
        (0x4F46C9D58c9736fe0f0DB5494Cf285E995c17397, 'Fantomon Trainers Gen1 on FTM', 'FTG1'),
        (0x77fA9d9D4eF0b3862c6F5B279Ce0fa576888Bc31, 'WigoSwap Wiggies', 'WIGGY'),
        (0x946D51c2919A6AbD401Ba0F16E3d3647cf245B19, 'Fantom Wolf Game Reborn', 'BABY'),
        (0x31E1Fd82b20cC56C2f41a56b2bCDCFda0470AAF9, 'CryptoMan', 'CRMAN'),
        (0x22236208f54864688BF9E027f12B1D0dc83c87be, 'Potluck Labs Anniversary Raffle Ticket', 'PLART'),
        (0xcCD1a30d363Cd254EA11bb02C2A9474da9FF6910, 'Cartoon Bunch', 'CBunch'),
        (0x2aB5C606a5AA2352f8072B9e2E8A213033e2c4c9, 'Magicats', 'MGC'),
        (0x51aEafAC5E4494E9bB2B9e5176844206AaC33Aa3, 'Hector FNFT', 'HFNFT'),
        (0x3B37270C332b5C6CF6Aac0103D9D896F5Dcafb1d, 'Riia the Girls', 'RIIA'),
        (0x0EE76C03f6C639fccDE0286A3D145955D710C81b, 'Cat Boris', 'Boris'),
        (0x8B42c6Cb07c8dD5fE5dB3aC03693867AFd11353d, 'veDEUS', 'veDEUS'),
        (0xDbD1D1f5E81c39c5b7931A8dFfDB78e260bF288a, 'Creatures Of The Cave Two', 'COTCTWO'),
        (0x0d8aec676d0078EEC693B481039DBe240B1b79d3, 'WWA Community Collection', 'WWACC'),
        (0xDf7834cEaDCB94Ef67fBE52BA8ce4c6B2ee12bCc, 'GOLUM', 'GLM'),
        (0x82913BB5587e42c7307cdA8bACab396c647ac20d, 'COTC2Serum', 'COTC2Serum'),
        (0xf9e393CbD7e8F34FB87127195f1F74E699D3d595, 'BBChickens', 'BBC'),
        (0x23cD2E6b283754Fd2340a75732f9DdBb5d11807e, 'EverRise NFT Stakes', 'nftRISE'),
        (0x98C12b56258552F143d35be8983077eb6adBe9a4, 'BaseLexPack', 'LCP'),
        (0xbAc40dc5168D2f109dFAD164af438d6b9C078254, 'BearishPods', 'BPOD'),
        (0x398bBB8fBB49d9c6DbdAa448c7335C38D4F9E23F, 'AdventMowse', 'AM'),
        (0x14Ffd1Fa75491595c6FD22De8218738525892101, 'Rave Names .ftm registry', '.ftm'),
        (0xC93F8096f003B09690A546d40cbB971e9346dcf3, 'Fantomon Gen1', 'FMONG1'),
        (0x91De3162dfD52a027F83aFe67A9F822092B97C54, 'BSGGStaking', 'BSGGStaking'),
        (0x7aCeE5D0acC520faB33b3Ea25D4FEEF1FfebDE73, 'Cyber Neko', 'NEKO'),
        (0x33b5202aDFaffD177D5b7aC58896de779F4D7327, 'WeCreaturesFamWe', 'WCF'),
        (0x0C600D41b9C7656e60C0bf76D79B1532b4770D0C, 'Fantums', 'FUM'),
        (0x9Ee6d281D77DEdB1D65684C9137B7B3Dc54f5d23, 'Gothums', 'GUM'),
        (0x3396d660653612Ba06Ea9259316aad2E962F964c, 'Cosmic Frens', 'CSFR'),
        (0x7e6Eef5388261973B0A1Aa14E1ca5Bbb11CC9A90, 'tinyfrogs', 'tiny'),
        (0x610CA70b7a61F405D080C1D618382a81FeD1C878, 'CryptoWormzHD', 'CWHD'),
        (0xdF96d74F6b182DaC0f9cE0aA7f3c64b8a0aa2929, 'MagikWorldSPRV2', 'MWSPRV2'),
        (0xcB846f2d2Cf754314803D01DE1c43a08ec8c9B4c, 'Beenz On Acid', 'BENZ'),
        (0x7124b89Ff43D06ffd9E020a40854F513921F04DF, 'BitFishes', 'BitFish'),
        (0x9d4B9AE4849D72A6273313aAbcA59Bc0575A4c6a, 'Bonkers', 'BONK'),
        (0x5563Cc1ee23c4b17C861418cFF16641D46E12436, 'Moo Scream BTC MAI Vault', 'mScBTCMVT'),
        (0xb54FF1EBc9950fce19Ee9E055A382B1219f862f0, 'Portalheads', 'PH'),
        (0x8313f3551C4D3984FfbaDFb42f780D0c8763Ce94, 'veEQUAL', 'veEQUAL'),
        (0x6393C82a8CDB073C97E496e44849f584539DC21d, 'Fantom Name Service', 'FNS'),
        (0x2B1c7b41f6A8F2b2bc45C3233a5d5FB3cD6dC9A8, 'KyberSwap v2 NFT Positions Manager', 'KS2-NPM'),
        (0x74D3736377fd0251c19b2b77288Cea6D3Ad87578, 'CryptoWormzNFT', 'CW'),
        (0x68B714Ac6913B9497817c03ac14cf99BbfB9d737, 'Fantom Fox Boy', 'FTMFOXBOY'),
        (0x6Fc9D59108D54e874b82e29833227f5fB3c57020, 'MagikWorldSPR', 'MWSPR'),
        (0xE564cBcD78A76fD0Bb716a8e4252DFF06C2e4AE7, 'veMULTI NFT', 'veMULTI'),
        (0x1576570D1AcFCd59750419bd02Eb3386B6897407, 'Bassment Rats', 'BRats'),
        (0xD888B9Aa5EF1a85968892C12E8cC83C73D69c8A1, 'ETH / USDC - Premia Options Pool', 'ETH / USDC - Premia Options Pool'),
        (0x7C7eC9d8672DfEAD60d6a533c3c5610Dd8916C48, 'WFTM / USDC - Premia Options Pool', 'WFTM / USDC - Premia Options Pool'),
        (0xa95D7adEcb3349b9e98e87C14726aFa53511a38D, 'LexiconBaseSet', 'LEXICON'),
        (0xEf5af209AE811Fb759C0D863D7f6EC1AF3a0a986, 'MiniVerse Market', 'MvMarket'),
        (0x3a098984f1c3ecBAb0D5866F35438Ec0db3ec8C2, 'BTC / USDC - Premia Options Pool', 'BTC / USDC - Premia Options Pool'),
        (0xEAfA5482e406Fced0b5c4f933C773A9342F0cAC7, 'Advent Calendar 2022', 'Advent Calendar 2022'),
        (0xB7745883A82c822f2b581359F4AEa3DCd096dcaf, 'Tarot Cats', 'Tarot Cats'),
        (0xB9C9bC2F438E165FFC7AC203EA7a824f58f867D5, 'SuperPositions', 'SP'),
        (0x8d9Ab6Aa28720a28D75CA157F7E16E9109520bAd, 'Afterlife Black Market', 'Afterlife Black Market'),
        (0x3B65eeC5FAFf50EAA34c66734F62A6825BB37879, 'depegMIM_975*RISK', 'rDEPEG'),
        (0x6269709A9CF20b9531B6c5b3197F4Ee2503ce427, 'depegUSDC_997*RISK', 'rDEPEG'),
        (0x6db9Ff140b68AD2a8D6af64b5384446ad03487Ab, 'Gold', 'Gold')
  ) AS temp_table (contract_address, name, symbol)
