CREATE TABLE [dbo].[MM_Maquilados] (
    [IdMaquilado]      INT            IDENTITY (1, 1) NOT NULL,
    [IdMaterialPadre]  INT            NULL,
    [IdMaterialHijo]   INT            NULL,
    [CantidadPadre]    FLOAT (53)     NULL,
    [CantidadHijo]     FLOAT (53)     NULL,
    [DescripcionPadre] NVARCHAR (MAX) NULL,
    [DescripcionHijo]  NVARCHAR (MAX) NULL,
    [Activo]           BIT            NULL,
    [CreadoPor]        INT            NULL,
    CONSTRAINT [PK_MM_Maquilados] PRIMARY KEY CLUSTERED ([IdMaquilado] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

