CREATE TABLE [dbo].[MA_TipoDocumento] (
    [IdTipoDocumento]  INT            IDENTITY (1, 1) NOT NULL,
    [Documento]        NVARCHAR (300) NULL,
    [IdContrato]       INT            NULL,
    [IsEliminado]      BIT            NULL,
    [CreadoPor]        INT            NULL,
    [CreadoEl]         DATETIME       NULL,
    [EditadoPor]       INT            NULL,
    [EditadoEl]        DATETIME       NULL,
    [IdContratista]    INT            NULL,
    [IdSubcontratista] INT            NULL,
    CONSTRAINT [PK_MA_TipoDocumento] PRIMARY KEY CLUSTERED ([IdTipoDocumento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

