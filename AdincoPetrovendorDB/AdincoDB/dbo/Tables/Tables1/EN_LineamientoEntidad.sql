CREATE TABLE [dbo].[EN_LineamientoEntidad] (
    [IdLineamientoEntidad] INT          IDENTITY (10000, 1) NOT NULL,
    [Entidad]              VARCHAR (50) NULL,
    [NombreEntidad]        VARCHAR (50) NULL,
    [DireccionEntidad]     VARCHAR (50) NULL,
    [MunicipioEntidad]     VARCHAR (50) NULL,
    [CiudadEntidad]        VARCHAR (50) NULL,
    CONSTRAINT [PK__EN_Linea__58B817D2D14E159E] PRIMARY KEY CLUSTERED ([IdLineamientoEntidad] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

