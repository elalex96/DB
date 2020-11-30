CREATE TABLE [dbo].[TmpServicios] (
    [id]           INT            NOT NULL,
    [IdSubFamilia] INT            NULL,
    [Grupo]        NVARCHAR (50)  NULL,
    [Servicio]     INT            NULL,
    [TextoCorto]   NVARCHAR (MAX) NULL,
    [TextoLargo]   NVARCHAR (MAX) NULL,
    [IdUnidad]     INT            NULL,
    [UMB]          NVARCHAR (50)  NULL,
    [TipoServicio] NVARCHAR (50)  NULL,
    [CatValor]     INT            NULL,
    [IdImpuesto]   INT            NULL,
    [Denomin]      INT            NULL,
    [Creado]       NVARCHAR (50)  NULL,
    [Modificado]   NVARCHAR (50)  NULL
);

