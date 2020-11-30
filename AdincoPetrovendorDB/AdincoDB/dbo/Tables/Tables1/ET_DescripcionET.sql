CREATE TABLE [dbo].[ET_DescripcionET] (
    [IdDescripcionET] INT            IDENTITY (10000, 1) NOT NULL,
    [IdEscalaTiempo]  INT            NULL,
    [Parte]           NVARCHAR (50)  NULL,
    [Descripción]     NVARCHAR (MAX) NULL,
    [CreadoPor]       INT            NULL,
    [CreadoEn]        DATETIME       NULL,
    CONSTRAINT [PK_ET_DescripcionET] PRIMARY KEY CLUSTERED ([IdDescripcionET] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

