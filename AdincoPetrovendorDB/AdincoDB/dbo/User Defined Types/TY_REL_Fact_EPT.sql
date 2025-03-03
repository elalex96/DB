use adinco

IF NOT EXISTS (SELECT * FROM sys.types WHERE name = 'Type_REL_Fact_EPT')
BEGIN
    CREATE TYPE Type_REL_Fact_EPT AS TABLE
    (
		FilaExcel INT,
        Anio VARCHAR(100),
        Contratista VARCHAR(100),
        Contrato VARCHAR(200),
        IdEstudioPrecioTransfer INT,
        IdentificadorDelDocumento VARCHAR(100),
        Mes VARCHAR(50),
        NombreDelDocumento VARCHAR(500),
        Observaciones VARCHAR(MAX)
    );
END;

