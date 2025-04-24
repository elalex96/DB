USE [Adinco];
GO


IF OBJECT_ID('[dbo].[Cat_TipoDocumento]', 'U') IS NOT NULL
    DROP TABLE [dbo].[Cat_TipoDocumento];
GO

CREATE TABLE [dbo].[Cat_TipoDocumento]
(
    IdTipoDocumento   INT PRIMARY KEY IDENTITY,
    TipoDeDocumento      VARCHAR(100) NOT NULL,
    Descripcion       VARCHAR(300),
    Activo            BIT NOT NULL DEFAULT 1,
    CreadoPor         INT NOT NULL,
    CreadoEn          DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ModificadoPor     INT NULL,
    ModificadoEn      DATETIME2 NULL
);
GO

INSERT INTO [dbo].Cat_TipoDocumento 
    (TipoDeDocumento, Descripcion, Activo, CreadoPor, CreadoEn)
VALUES
    ('Factura', 'Factura.', 1, 1, GETDATE()),
    ('Pedimento', 'Pedimento de Importación.', 1, 1, GETDATE()),
    ('Comprobante', 'Comprobante de Proveedor en el Extranjero.', 1, 1, GETDATE());

