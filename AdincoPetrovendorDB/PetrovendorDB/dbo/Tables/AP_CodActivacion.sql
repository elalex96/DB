CREATE TABLE [dbo].[AP_CodActivacion] (
    [IdCodActivacion]  INT           IDENTITY (1, 1) NOT NULL,
    [CodigoActivacion] VARCHAR (100) NULL,
    [Activo]           BIT           NULL,
    [fechaRegistro]    DATETIME      NULL,
    [IdProveedor]      INT           NULL,
    CONSTRAINT [PK_AP_CodActivacion] PRIMARY KEY CLUSTERED ([IdCodActivacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

