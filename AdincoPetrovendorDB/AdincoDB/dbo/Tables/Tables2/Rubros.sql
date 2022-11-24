CREATE TABLE [dbo].[Rubros] (
    [IdRubro]     INT            IDENTITY (1, 1) NOT NULL,
    [ID_RUBRO1]   NVARCHAR (MAX) NULL,
    [ID_RUBRO2]   NVARCHAR (MAX) NULL,
    [ID_RUBRO3]   NVARCHAR (MAX) NULL,
    [CLAVE_RUBRO] NVARCHAR (MAX) NULL,
    [NombreRubro] NVARCHAR (MAX) NULL,
    [RU_DESCRIP]  NVARCHAR (MAX) NULL,
    [IdUsuario]   INT            NULL,
    [FecMovto]    DATETIME       NULL,
    [Activo]      BIT            NULL,
    CONSTRAINT [PK_Rubros2] PRIMARY KEY CLUSTERED ([IdRubro] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

