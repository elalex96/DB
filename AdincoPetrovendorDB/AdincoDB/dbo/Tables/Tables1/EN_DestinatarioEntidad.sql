CREATE TABLE [dbo].[EN_DestinatarioEntidad] (
    [idDestinatarioEntidad] INT          IDENTITY (10000, 1) NOT NULL,
    [Nombre]                VARCHAR (50) NULL,
    [ApellidoPaterno]       VARCHAR (50) NULL,
    [ApellidoMaterno]       VARCHAR (50) NULL,
    [idTitulo]              INT          NULL,
    [Puesto]                VARCHAR (50) NULL,
    CONSTRAINT [PK__EN_Desti__BA5620FF652151DC] PRIMARY KEY CLUSTERED ([idDestinatarioEntidad] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

