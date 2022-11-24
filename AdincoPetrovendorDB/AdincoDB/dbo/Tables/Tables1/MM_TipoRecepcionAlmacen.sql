CREATE TABLE [dbo].[MM_TipoRecepcionAlmacen] (
    [id]               INT            IDENTITY (1, 1) NOT NULL,
    [id_tiporecep]     INT            NULL,
    [nombre_tiporecep] NVARCHAR (50)  NULL,
    [desc_tiporecep]   NVARCHAR (MAX) NULL,
    [txt_numrecep]     NVARCHAR (MAX) NULL,
    [txt_ayuda]        NVARCHAR (MAX) NULL,
    [txt_resumen]      NVARCHAR (MAX) NULL,
    [CreadoPor]        INT            NULL,
    CONSTRAINT [PK_admin_tiposrecepcion] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

