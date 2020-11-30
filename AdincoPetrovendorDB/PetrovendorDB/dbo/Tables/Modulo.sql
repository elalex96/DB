CREATE TABLE [dbo].[Modulo] (
    [IdModulo]       INT            IDENTITY (1, 1) NOT NULL,
    [NombreModulo]   NVARCHAR (200) NULL,
    [StringModuloId] NVARCHAR (200) NULL,
    [CreadoPor]      INT            NULL,
    [CreadoEl]       DATETIME       NULL,
    [ModificadoPor]  INT            NULL,
    [ModificadoEl]   DATETIME       NULL,
    [URL_MODULO]     NVARCHAR (350) NULL,
    [IsEliminado]    BIT            NULL,
    [Aplicacion]     INT            NULL,
    CONSTRAINT [PK_Modulo] PRIMARY KEY CLUSTERED ([IdModulo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

