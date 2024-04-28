	CREATE TYPE CO_GastosActualizarType AS TABLE
	(
		Id INT,
		UUIDImport VARCHAR(100),
		RFCEmisor VARCHAR(18),
		UUID VARCHAR(100),
		CuentaContable VARCHAR(20),
		Poliza VARCHAR(20),
		GastoAdmon BIT,
		IdLineaPresupuesto INT,
		Error VARCHAR(8000)
	);

