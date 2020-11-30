CREATE TABLE [dbo].[CAT_Flujos] (
    [IdFlujo] INT           NOT NULL,
    [Flujo]   VARCHAR (100) NULL,
    [Activo]  BIT           NULL,
    CONSTRAINT [PF_CAT_Flujos] PRIMARY KEY CLUSTERED ([IdFlujo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

