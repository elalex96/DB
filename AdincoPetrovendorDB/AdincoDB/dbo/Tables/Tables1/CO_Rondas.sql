CREATE TABLE [dbo].[CO_Rondas] (
    [IdRonda]           INT           NOT NULL,
    [Descripcion]       VARCHAR (250) NULL,
    [FechaCreacion]     DATETIME      NULL,
    [FechaModificacion] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdRonda] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

