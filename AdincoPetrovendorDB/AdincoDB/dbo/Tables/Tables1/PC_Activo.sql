CREATE TABLE [dbo].[PC_Activo] (
    [IdActivo]          INT            IDENTITY (10000, 1) NOT NULL,
    [CveActivo]         INT            NULL,
    [DescripcionActivo] NVARCHAR (MAX) NULL,
    [CreadoPor]         INT            NULL,
    [CreadoEn]          DATETIME       NULL,
    CONSTRAINT [PK_PC_Activo] PRIMARY KEY CLUSTERED ([IdActivo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

