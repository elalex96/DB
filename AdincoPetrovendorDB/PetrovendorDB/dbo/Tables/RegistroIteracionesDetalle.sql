CREATE TABLE [dbo].[RegistroIteracionesDetalle] (
    [IdDetalleIteracion] INT            IDENTITY (1, 1) NOT NULL,
    [IdIteracion]        INT            NULL,
    [DescripcionLarga]   NVARCHAR (MAX) NULL,
    [ImagenVideo]        IMAGE          NULL,
    [FechaRegistro]      DATETIME       NULL,
    [CreadoPor]          INT            NULL,
    [FechaModificado]    DATETIME       NULL,
    [ModificadoPor]      INT            NULL,
    [Modulo]             NVARCHAR (MAX) NULL,
    [IsEliminado]        BIT            NULL,
    CONSTRAINT [PK_RegistroIteracionesDetalle] PRIMARY KEY CLUSTERED ([IdDetalleIteracion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

