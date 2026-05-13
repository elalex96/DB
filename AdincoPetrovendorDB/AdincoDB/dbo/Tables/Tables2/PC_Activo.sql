CREATE TABLE [dbo].[PC_Activo] (
    [IdActivo]          INT            IDENTITY (10000, 1) NOT NULL,
    [CveActivo]         INT            NULL,
    [DescripcionActivo] NVARCHAR (MAX) NULL,
    [CreadoPor]         INT            NULL,
    [CreadoEn]          DATETIME       NULL,
    CONSTRAINT [PK_PC_Activo] PRIMARY KEY CLUSTERED ([IdActivo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

