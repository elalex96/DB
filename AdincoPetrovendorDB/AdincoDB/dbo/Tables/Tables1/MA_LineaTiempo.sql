CREATE TABLE [dbo].[MA_LineaTiempo] (
    [IdLineaTiempo]     INT            IDENTITY (1, 1) NOT NULL,
    [IdDocumento]       INT            NULL,
    [FechaCreacion]     DATETIME       NULL,
    [ComentarioRechazo] NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdLineaTiempo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

