CREATE TABLE [dbo].[AM_BitacoraAprobaciones] (
    [Id]                   INT           IDENTITY (1, 1) NOT NULL,
    [IdTarea]              INT           NULL,
    [IdContrato]           INT           NULL,
    [IdEstatus]            INT           NULL,
    [Comentario]           VARCHAR (MAX) NULL,
    [AprobadorPetrovendor] INT           NULL,
    [AprobadorAdinco]      INT           NULL,
    [FechaAprobacion]      DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

