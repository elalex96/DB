CREATE TABLE [dbo].[RegistroIteracionesDetalle] (
    [IdDetalleIteracion] INT            IDENTITY (1, 1) NOT NULL,
    [IdIteracion]        INT            NULL,
    [DescripcionLarga]   NVARCHAR (MAX) NULL,
    [ImagenVideo]        IMAGE          NULL,
    [FechaRegistro]      DATETIME       NULL,
    [FechaModificado]    DATETIME       NULL,
    [Modulo]             NVARCHAR (MAX) NULL,
    [IsEliminado]        BIT            NULL,
    CONSTRAINT [PK_RegistroIteracionesDetalle] PRIMARY KEY CLUSTERED ([IdDetalleIteracion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

