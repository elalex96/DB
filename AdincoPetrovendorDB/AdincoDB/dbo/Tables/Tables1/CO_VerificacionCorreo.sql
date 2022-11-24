CREATE TABLE [dbo].[CO_VerificacionCorreo] (
    [IdVerificacionCorreo]  INT             IDENTITY (100, 1) NOT NULL,
    [IdUsuario]             INT             NULL,
    [IdIdentificadorCorreo] INT             NULL,
    [Pantalla]              NVARCHAR (1000) NULL,
    [FechaVisto]            DATETIME        NULL
);

