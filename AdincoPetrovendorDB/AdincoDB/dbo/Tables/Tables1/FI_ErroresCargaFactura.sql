CREATE TABLE [dbo].[FI_ErroresCargaFactura] (
    [idError]       INT            IDENTITY (1, 1) NOT NULL,
    [Error]         VARCHAR (1000) NULL,
    [IdContrato]    INT            NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEl]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEl]  DATETIME       NULL,
    [Activo]        BIT            NULL,
    CONSTRAINT [PK_ErrorCargaFactura] PRIMARY KEY CLUSTERED ([idError] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Creadopor] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

