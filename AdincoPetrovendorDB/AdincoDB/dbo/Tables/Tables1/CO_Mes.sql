CREATE TABLE [dbo].[CO_Mes] (
    [idMes]         INT           IDENTITY (1, 1) NOT NULL,
    [NumeroMes]     VARCHAR (MAX) NOT NULL,
    [MesCalendario] VARCHAR (MAX) NOT NULL,
    [Descripcion]   VARCHAR (MAX) NULL,
    [Activo]        BIT           NOT NULL,
    CONSTRAINT [PK_CO_Mes] PRIMARY KEY CLUSTERED ([idMes] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

