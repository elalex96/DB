CREATE TABLE [dbo].[PV_Accion] (
    [IdCatAcciones] INT          IDENTITY (1, 1) NOT NULL,
    [Accion]        VARCHAR (50) NULL,
    CONSTRAINT [PK_AP_Accion] PRIMARY KEY CLUSTERED ([IdCatAcciones] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

