{{ config(
        schema='prices_optimism',
        alias = alias('tokens_curated', legacy_model=True),
        materialized='table',
        file_format = 'delta',
        tags=['static']
        )
}}
SELECT
    TRIM(token_id) as token_id
    , 'optimism' as blockchain
    , TRIM(symbol) as symbol
    , LOWER(TRIM(contract_address)) as contract_address
    , decimals
FROM
(
    VALUES

    --tokens not yet supported or are not active on coinpaprika are commented out
    ("op-optimism", "OP", "0x4200000000000000000000000000000000000042", 18),
    ("eth-ethereum", "ETH", "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee", 18),
    ("eth-ethereum", "ETH", "0xdeaddeaddeaddeaddeaddeaddeaddeaddead0000",18),
    ("dai-dai", "DAI", "0xda10009cbd5d07dd0cecc66161fc93d7c9000da1", 18),
    ("usdc-usd-coin", "USDC", "0x7f5c764cbc14f9669b88837ca1490cca17c31607", 6),
    ("usdt-tether", "USDT", "0x94b008aa00579c1307b0ef2c499ad98a8ce58e58", 6),
    ("wbtc-wrapped-bitcoin", "WBTC", "0x68f180fcce6836688e9084f035309e29bf0a2095", 8),
    ("weth-weth","WETH","0x4200000000000000000000000000000000000006",18),
    ("link-chainlink","LINK","0x350a791bfc2c21f9ed5d10980dad2e2638ffa7f6",18),
    ("rgt-rari-governance-token","RGT","0xb548f63d4405466b36c0c0ac3318a22fdcec711a",18),
    ("mkr-maker","MKR","0xab7badef82e9fe11f6f33f87bc9bc2aa27f2fcb5",18),
    ("uni-uniswap","UNI","0x6fd9d7ad17242c41f7131d257212c54a0e816691",18),
    ("rai-rai-reflex-index","RAI","0x7fb688ccf682d58f86d7e38e03f9d22e7705448b",18),
    ("susd-susd","sUSD","0x8c6f28f2f1a3c87f0f938b96d27520d9751ec8d9",18),
    ("seth-seth","sETH","0xe405de8f52ba7559f9df3c368500b6e6ae6cee49",18),
    -- ("NULL","sLINK","0xc5db22719a06418028a40a9b5e9a7c02959d0d08",18),
    -- ("NULL","sBTC","0x298b9b95708152ff6968aafd889c6586e9169f1d",18),
    ("lusd-liquity-usd","LUSD","0xc40f949f8a4e094d1b49a23ea9241d289b7b2819",18),
    ("syn-synapse","SYN","0x5a5fff6f753d7c11a56a52fe47a177a87e431655",18),
    ("ens-ethereum-name-service","ENS","0x65559aa14915a70190438ef90104769e5e890a00",18),
    ("paper-dope-wars-paper","PAPER","0x00f932f0fe257456b32deda4758922e56a4f4b42",18),
    ("lyra-lyra-finance","LYRA","0x50c5725949a6f0c72e6c4a641f24049a917db0cb",18),
    ("dcn-dentacoin","DCN","0x1da650c3b2daa8aa9ff6f661d4156ce24d08a062",0),
    ("uma-uma","UMA","0xe7798f023fc62146e8aa1b36da45fb70855a77ea",18),
    -- ("NULL","USX","0xbfd291da8a403daaf7e5e9dc1ec0aceacd4848b9",18),
    ("wpc-wepiggy-coin","WPC","0x6f620ec89b8479e97a6985792d0c64f237566746",18),
    ("bond-barnbridge","BOND","0x3e7ef8f50246f725885102e8238cbba33f276747",18),
    ("perp-perpetual-protocol","PERP","0x9e1028f5f1d5ede59748ffcee5532509976840e0",18),
    -- ("NULL","AELIN","0x61baadcf22d2565b0f471b291c475db5555e0b76",18),
    -- ("NULL","ZIP","0xfa436399d0458dbe8ab890c3441256e3e09022a8",18),
    ("frax-frax","FRAX","0x2e3d870790dc77a83dd1d18184acc7439a53f475",18),
    ("thales-thales","THALES","0x217d47011b23bb961eb6d93ca9945b7501a5bb11",18),
    -- ("NULL","sSOL","0x8b2f7ae8ca8ee8428b6d76de88326bb413db2766",18),
    ("fxs-frax-share","FXS","0x67ccea5bb16181e7b4109c9c2143c24a1c2205be",18),
    ("aave-new","AAVE","0x76fb31fb4af56892a25e32cfc43de717950c9278",18),
    -- ("NULL","sAVAX","0xb2b42b231c68cbb0b4bf2ffebf57782fd97d3da4",18),
    -- ("NULL","sMATIC","0x81ddfac111913d3d5218dea999216323b7cd6356",18),
    -- ("NULL","sAAVE","0x00b8d5a5e1ac97cb4341c4bc4367443c8776e8d9",18),
    -- ("NULL","sUNI","0xf5a6115aa582fd1beea22bc93b7dc7a785f60d03",18),
    -- ("seur-seur","sEUR","0xfbc4198702e81ae77c06d58f81b629bdf36f0a71",18),
    ("seur-seur","sEUR","0xfbc4198702e81ae77c06d58f81b629bdf36f0a71",18),
    ("stg-stargatetoken","STG","0x296f55f8fb28e498b858d0bcda06d955b2cb3f97",18),
    -- ("socks-unisocks","SOCKS","0x514832a97f0b440567055a73fe03aa160017b990",18),
    -- ("NULL","MAI","0xdfa46478f9e5ea86d57387849598dbfb2e964b02",18),
    -- ("NULL","QI","0x3f56e0c36d275367b8c502090edf38289b3dea0d",18),
    -- ("NULL","VELO","0x3c8b650257cfb5f272f799f5e2b4e65093a11a05",18),
    ("bal-balancer","BAL","0xfe8b128ba8c78aabc59d4c64cee7ff28e9379921",18),
    ("alusd-alchemixusd","alUSD","0xcb8fa9a76b8e203d8c3797bf438d8fb81ea3326a",18),
    ("aleth-alchemix-eth","alETH","0x3e29d3a9316dab217754d13b28646b76607c5f04",18),
    -- ("NULL","DOLA","0x8ae125e8653821e851f12a49f7765db9a9ce7384",18),
    ("gtc-gitcoin","GTC","0x1eba7a6a72c894026cd654ac5cdcf83a46445b08",18),
    ("lrc-loopring","LRC","0xfeaa9194f9f8c1b65429e31341a103071464907e",18),
    ("bico-biconomy","BICO","0xd6909e9e702024eb93312b989ee46794c0fb1c9d",18),
    ("l2dao-layer2dao","L2DAO","0xd52f94df742a6f4b4c8b033369fe13a41782bf44",18),
    ("ageur-ageur","agEUR","0x9485aca5bbbe1667ad97c7fe7c4531a624c8b1ed",18),
    ("renbtc-renbtc","renBTC","0x85f6583762bc76d775eab9a7456db344f12409f7",8),
    ("df-dforce-token","DF","0x9e5aac1ba1a2e6aed6b32689dfcf62a509ca96f3",18),
    ("tarot-tarot","TAROT","0x375488f097176507e39b9653b88fdc52cde736bf",18),
    ("zrx-0x","ZRX","0xd1917629b3e6a72e6772aab5dbe58eb7fa3c2f33",18),
    ("pool-pooltogether","POOL","0x395ae52bb17aef68c2888d941736a71dc6d4e125",18),
    ("tusd-trueusd","TUSD","0xcb59a0a753fdb7491d5f3d794316f1ade197b21e",18),
    -- ("ib-iron-bank","IB","0x00a35fd824c717879bf370e70ac6868b95870dfb",18),
    ("bifi-beefyfinance","BIFI","0x4e720dd3ac5cfe1e1fbde4935f386bb1c66f4642",18),
    ("mim-magic-internet-money","MIM","0xB153FB3d196A8eB25522705560ac152eeEc57901",18),
    ("wsteth-wrapped-liquid-staked-ether-20","wstETH","0x1F32b1c2345538c0c6f582fCB022739c4A194Ebb",18),
    ("ldo-lido-dao","LDO","0xFdb794692724153d1488CcdBE0C56c252596735F",18),
    ("sdl-saddle-finance", "SDL", "0xAe31207aC34423C41576Ff59BFB4E036150f9cF7", 18),
    -- ("xchf-cryptofranc", "XCHF", "0xe4f27b04cc7729901876b44f4eaa5102ec150265", 18),
    ("wad-warden", "WAD", "0x703D57164CA270b0B330A87FD159CfEF1490c0a5", 18),
    ("ust-terrausd-wormhole", "UST", "0xBA28feb4b6A6b81e3F26F08b83a19E715C4294fd", 6),
    ("usdd-usdd", "USDD", "0x7113370218f31764C1B6353BDF6004d86fF6B9cc", 18),
    ("ubi-universal-basic-income", "UBI", "0xbb586ed34974b15049a876fd5366a4c2d1203115", 18),
    ("krom-kromatikafinance", "KROM", "0xf98dcd95217e15e05d8638da4c91125e59590b07", 18),
    ("knc-kyber-network", "KNC", "0xa00E3A3511aAC35cA78530c85007AFCd31753819", 18),
    ('dht-dhedge', 'DHT', '0xAF9fE3B5cCDAe78188B1F8b9a49Da7ae9510F151', 18),
    ("crv-curve-dao-token", "CRV", "0x0994206dfe8de6ec6920ff4d779b0d950605fb53", 18),
    ("oath-oath", "OATH", "0x39FdE572a18448F8139b7788099F0a0740f51205", 18),
    ("hop-hop-protocol", "HOP", "0xc5102fE9359FD9a28f877a67E36B0F050d81a3CC", 18),
    ("0xbtc-0xbitcoin", "0xBTC", "0xe0bb0d3de8c10976511e5030ca403dbf4c25165b", 8),
    -- ("bitbtc-bitbtc", "BitBTC", "0xc98b98d17435aa00830c87ea02474c5007e1f272", 18),
    ("ctsi-cartesi", "CTSI", "0xec6adef5e1006bb305bb1975333e8fc4071295bf", 18),
    ("duck-dlp-duck-token", "DUCK", "0x0e49ca6ea763190084c846d3fc18f28bc2ac689a", 18),
    ("eqz-equalizer", "EQZ", "0x81ab7e0d570b01411fcc4afd3d50ec8c241cb74b", 18),
    ("gysr-geyser", "GYSR", "0x117cfd9060525452db4a34d51c0b3b7599087f05", 18),
    ("han-hanchain", "HAN", "0x50bce64397c75488465253c0a034b8097fea6578", 18),
    -- ("hnd-hundred-finance", "HND", "0x10010078a54396f62c96df8532dc2b4847d47ed3", 18),
    ("spell-spell-token", "SPELL", "0xe3ab61371ecc88534c522922a026f2296116c109", 18),
    ("suku-suku", "SUKU", "0xef6301da234fc7b0545c6e877d3359fe0b9e50a4", 18),
    ("snx-synthetix-network-token", "SNX", "0x8700daec35af8ff88c16bdf0418774cb3d7599b4", 18),
    -- ("unlock-unlock", "UNLOCK", "0x7ae97042a4a0eb4d1eb370c34bfec71042a056b7", 18), --removed for low quality feed
    ("bank-bankless-dao", "BANK", "0x29FAF5905bfF9Cfcc7CF56a5ed91E0f091F8664B", 18),
    ("btcb-bitcoin-avalanche-bridged-btcb","BTC.b","0x2297aebd383787a160dd0d9f71508148769342e3",18),
    ("pickle-pickle-finance", "PICKLE", "0x0c5b4c92c948691EEBf185C17eeB9c230DC019E9", 18),
    ("bob-bob", "BOB", "0xb0b195aefa3650a6908f15cdac7d92f8a5791b0b", 18),
    ("bomb-fbomb","fBOMB","0x74ccbe53F77b08632ce0CB91D3A545bF6B8E0979",18),
    ("busd-binance-usd","BUSD","0x9c9e5fd8bbc25984b178fdce6117defa39d2db39",18),
    ("cbeth-coinbase-wrapped-staked-eth","cbETH","0xaddb6a0412de1ba0f936dcaeb8aaa24578dcf3b2",18),
    ("grain-granary","GRAIN","0xfD389Dc9533717239856190F42475d3f263a270d",18)

) as temp (token_id, symbol, contract_address, decimals)
