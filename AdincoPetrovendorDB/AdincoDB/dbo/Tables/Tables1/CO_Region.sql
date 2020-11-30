CREATE TABLE [dbo].[CO_Region] (
    [IdRegion]  INT            IDENTITY (10000, 1) NOT NULL,
    [No]        INT            NULL,
    [Nombre]    NVARCHAR (MAX) NULL,
    [CreadoPor] INT            NULL,
    [CreadoEn]  DATETIME       NULL,
    CONSTRAINT [PK_Regiones] PRIMARY KEY CLUSTERED ([IdRegion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

