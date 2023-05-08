CREATE TABLE [dbo].[TmpServicios] (
    [id]           INT            NOT NULL,
    [IdSubFamilia] INT            NULL,
    [Grupo]        VARCHAR (50)   NULL,
    [Servicio]     INT            NULL,
    [TextoCorto]   VARCHAR (5000) NULL,
    [TextoLargo]   VARCHAR (5000) NULL,
    [IdUnidad]     INT            NULL,
    [UMB]          VARCHAR (5)    NULL,
    [TipoServicio] VARCHAR (50)   NULL,
    [CatValor]     INT            NULL,
    [IdImpuesto]   INT            NULL,
    [Denomin]      INT            NULL,
    [Creado]       VARCHAR (50)   NULL,
    [Modificado]   VARCHAR (50)   NULL,
    CONSTRAINT [PK__tmpservi__3213E83F780801D6] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

