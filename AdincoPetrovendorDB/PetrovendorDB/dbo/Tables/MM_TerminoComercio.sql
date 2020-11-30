CREATE TABLE [dbo].[MM_TerminoComercio] (
    [IdTerminoComercio] INT            IDENTITY (1, 1) NOT NULL,
    [Termino]           NVARCHAR (250) NULL,
    [Descripcion]       NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_MM_TerminoComercio] PRIMARY KEY CLUSTERED ([IdTerminoComercio] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

