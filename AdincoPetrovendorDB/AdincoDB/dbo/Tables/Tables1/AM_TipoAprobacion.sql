CREATE TABLE [dbo].[AM_TipoAprobacion] (
    [idTipoAprobacion] INT           IDENTITY (1, 1) NOT NULL,
    [TipoAprobacion]   VARCHAR (100) NULL,
    [Icon]             VARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([idTipoAprobacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

