	
	
module main
import despiegk.crystallib.coinmarketcap


fn main() {
	key := "92be9b29-7f6c-48e4-9ef2-d6aa0550f620"

	mut c := coinmarketcap.new(secret:key)

	// c.token_price_get("TFT") or {panic("...")}

	//use connection constructs as put there, see taiga client for more examples

}