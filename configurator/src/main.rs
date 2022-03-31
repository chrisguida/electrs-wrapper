use std::fs::File;
use std::io::Write;

use http::Uri;
use serde::{
    de::{Deserializer, Error as DeserializeError, Unexpected},
    Deserialize,
};

fn deserialize_parse<'de, D: Deserializer<'de>, T: std::str::FromStr>(
    deserializer: D,
) -> Result<T, D::Error> {
    let s: String = Deserialize::deserialize(deserializer)?;
    s.parse()
        .map_err(|_| DeserializeError::invalid_value(Unexpected::Str(&s), &"a valid URI"))
}

fn parse_quick_connect_url(url: Uri) -> Result<(String, String, String, u16), anyhow::Error> {
    let auth = url
        .authority()
        .ok_or_else(|| anyhow::anyhow!("invalid Quick Connect URL"))?;
    let mut auth_split = auth.as_str().split(|c| c == ':' || c == '@');
    let user = auth_split
        .next()
        .ok_or_else(|| anyhow::anyhow!("missing user"))?;
    let pass = auth_split
        .next()
        .ok_or_else(|| anyhow::anyhow!("missing pass"))?;
    let host = url.host().unwrap();
    let port = url.port_u16().unwrap_or(8332);
    Ok((user.to_owned(), pass.to_owned(), host.to_owned(), port))
}

#[derive(Deserialize)]
#[serde(rename_all = "kebab-case")]
struct Config {
    bitcoind: BitcoinCoreConfig,
    advanced: AdvancedConfig,
}

#[derive(Deserialize)]
#[serde(rename_all = "kebab-case")]
struct AdvancedConfig {
    log_filters: String,
    index_batch_size: Option<u16>,
    index_lookup_limit: Option<u16>,
}

#[derive(serde::Deserialize)]
#[serde(tag = "type")]
#[serde(rename_all = "kebab-case")]
enum BitcoinCoreConfig {
    #[serde(rename_all = "kebab-case")]
    Internal { user: String, password: String },
    #[serde(rename_all = "kebab-case")]
    InternalProxy { user: String, password: String },
    #[serde(rename_all = "kebab-case")]
    External {
        #[serde(deserialize_with = "deserialize_parse")]
        host: Uri,
        rpc_user: String,
        rpc_password: String,
        rpc_port: u16,
        #[serde(deserialize_with = "deserialize_parse")]
        p2p_host: Uri,
        p2p_port: u16,
    },
    #[serde(rename_all = "kebab-case")]
    QuickConnect {
        #[serde(deserialize_with = "deserialize_parse")]
        quick_connect_url: Uri,
    },
}

#[derive(serde::Serialize)]
pub struct Properties {
    version: u8,
    data: Data,
}

#[derive(serde::Serialize)]
pub struct Data {
    #[serde(rename = "LND Connect URL")]
    lnd_connect: Property<String>,
}

#[derive(serde::Serialize)]
pub struct Property<T> {
    #[serde(rename = "type")]
    value_type: &'static str,
    value: T,
    description: Option<String>,
    copyable: bool,
    qr: bool,
    masked: bool,
}

fn main() -> Result<(), anyhow::Error> {
    let config: Config = serde_yaml::from_reader(File::open("/data/start9/config.yaml")?)?;

    {
        let mut outfile = File::create("/data/electrs.toml")?;

        let (
            bitcoin_rpc_user,
            bitcoin_rpc_pass,
            bitcoin_rpc_host,
            bitcoin_rpc_port,
            bitcoin_p2p_host,
            bitcoin_p2p_port,
        ) = match config.bitcoind {
            BitcoinCoreConfig::Internal { user, password } => {
                let hostname = format!("{}", "bitcoind.embassy");
                (user, password, hostname.clone(), 8332, hostname, 8333)
            }
            BitcoinCoreConfig::InternalProxy { user, password } => (
                user,
                password,
                format!("{}", "btc-rpc-proxy.embassy"),
                8332,
                // use bitcoin p2p interface. this requires bitcoind to be defined in dependencies.yaml
                format!("{}", "bitcoind.embassy"),
                8333,
            ),
            BitcoinCoreConfig::External {
                host,
                rpc_user,
                rpc_password,
                rpc_port,
                p2p_host,
                p2p_port,
            } => (
                rpc_user,
                rpc_password,
                format!("{}", host.host().unwrap()),
                rpc_port,
                format!("{}", p2p_host.host().unwrap()),
                p2p_port,
            ),
            BitcoinCoreConfig::QuickConnect { quick_connect_url } => {
                let (bitcoin_rpc_user, bitcoin_rpc_pass, bitcoin_rpc_host, bitcoin_rpc_port) =
                    parse_quick_connect_url(quick_connect_url)?;
                (
                    bitcoin_rpc_user,
                    bitcoin_rpc_pass,
                    bitcoin_rpc_host.clone(),
                    bitcoin_rpc_port,
                    bitcoin_rpc_host.clone(),
                    //Since Quick Connect doesn't support the peer interface, we'll just assume it's the rpc host and port 8333
                    8333,
                )
            }
        };

        let mut index_batch_size: String = "".to_string();
        if config.advanced.index_batch_size.is_some() {
            index_batch_size = format!(
                "index_batch_size = {}",
                config.advanced.index_batch_size.unwrap()
            );
        }

        let mut index_lookup_limit: String = "".to_string();
        if config.advanced.index_lookup_limit.is_some() {
            index_lookup_limit = format!(
                "index_batch_size = {}",
                config.advanced.index_lookup_limit.unwrap()
            );
        }

        write!(
            outfile,
            include_str!("electrs.toml.template"),
            bitcoin_rpc_user = bitcoin_rpc_user,
            bitcoin_rpc_pass = bitcoin_rpc_pass,
            bitcoin_rpc_host = bitcoin_rpc_host,
            bitcoin_rpc_port = bitcoin_rpc_port,
            bitcoin_p2p_host = bitcoin_p2p_host,
            bitcoin_p2p_port = bitcoin_p2p_port,
            log_filters = config.advanced.log_filters,
            index_batch_size = index_batch_size,
            index_lookup_limit = index_lookup_limit,
        )?;
    }

    Ok(())
}
