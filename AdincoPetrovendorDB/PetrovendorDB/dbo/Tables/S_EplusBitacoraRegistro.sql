CREATE TABLE [dbo].[S_EplusBitacoraRegistro] (
    [IdBitacoraEplus] INT            IDENTITY (1, 1) NOT NULL,
    [Correo]          NVARCHAR (400) NULL,
    [Usuario]         NVARCHAR (500) NULL,
    [RFC]             VARCHAR (30)   NULL,
    [TipoRegimen]     INT            NULL,
    [Nacionalidad]    INT            NULL,
    [RazonSocial]     NVARCHAR (MAX) NULL,
    [FechaRegistro]   DATETIME       NULL,
    CONSTRAINT [PK_S_EplusBitacoraRegistro] PRIMARY KEY CLUSTERED ([IdBitacoraEplus] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

