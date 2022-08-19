import {
  compat,
  types as T,
} from "../deps.ts";

// deno-lint-ignore no-explicit-any
export const setConfig: T.ExpectedExports.setConfig = async (effects, input: any) => {

  const depBitcoin: T.DependsOn = input?.bitcoind?.type === "internal" || input?.bitcoind?.type === "internal-proxy" ? { bitcoind: ["synced"] } : {}
  return await compat.setConfig(effects, input, {
    ...depBitcoin
  });
}
