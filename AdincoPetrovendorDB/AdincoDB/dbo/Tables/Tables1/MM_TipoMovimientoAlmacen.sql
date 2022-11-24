CREATE TABLE [dbo].[MM_TipoMovimientoAlmacen] (
    [id]        INT           IDENTITY (1, 1) NOT NULL,
    [id_mov]    INT           NULL,
    [tipo_mov]  NVARCHAR (50) NULL,
    [CreadoPor] INT           NULL,
    CONSTRAINT [PK_admin_tipos_movimientos] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

