CREATE TYPE SC_Type_Subcontratos AS TABLE
(
    NumeroFila INT NULL,
    DocumentoCompras VARCHAR(100) NULL,
    Posicion VARCHAR(100) NULL,
    CentroDeBeneficio VARCHAR(500) NULL,
    FechaDocumento DATE NULL,
    ProveedorCentroSuministrador VARCHAR(100) NULL,
    Material VARCHAR(100) NULL,
    TextoBreve VARCHAR(1000) NULL,
    DescripcionLarga VARCHAR(MAX) NULL,
    CantidadDePedido DECIMAL(18, 5) NULL,
    UnidadMedidaPedido VARCHAR(100) NULL,
    PrecioNeto DECIMAL(18, 2) NULL,
    Moneda VARCHAR(100) NULL
);