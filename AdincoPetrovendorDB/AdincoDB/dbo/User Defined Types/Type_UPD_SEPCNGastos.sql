CREATE TYPE Type_UPD_SEPCNGastos AS TABLE
    (
		FilaExcel INT,
        UUID VARCHAR(500),
        CodigoSE NVARCHAR(100),
        PCN VARCHAR(200),
        IdContrato INT,
        Observaciones VARCHAR(MAX)
    );