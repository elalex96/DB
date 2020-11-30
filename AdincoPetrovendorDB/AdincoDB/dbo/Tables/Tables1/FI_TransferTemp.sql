CREATE TABLE [dbo].[FI_TransferTemp] (
    [Referencia bancaria de la operación] FLOAT (53)     NULL,
    [Fecha de pago]                       DATE           NULL,
    [Beneficiario]                        NVARCHAR (255) NULL,
    [Monto pagado]                        MONEY          NULL,
    [Moneda funcional]                    NVARCHAR (255) NULL,
    [Cuenta origen]                       NVARCHAR (255) NULL,
    [Banco origen nacional]               NVARCHAR (255) NULL,
    [Banco origen extranjero]             NVARCHAR (255) NULL,
    [Cuenta destino]                      NVARCHAR (255) NULL,
    [Banco destino nacional]              NVARCHAR (255) NULL,
    [Banco destino extranjero ]           NVARCHAR (255) NULL,
    [Fila]                                INT            IDENTITY (1, 1) NOT NULL
);

