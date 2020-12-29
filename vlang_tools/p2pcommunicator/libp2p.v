module libp2p
import patrickpissurno.vredis

redis := vredis.connect({addr:"localhost",port:6378}) or {
		panic(err)
	}

