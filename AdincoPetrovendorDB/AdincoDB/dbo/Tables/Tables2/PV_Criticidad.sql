CREATE TABLE [dbo].[PV_Criticidad] (
    [idCriticidad] INT           IDENTITY (1, 1) NOT NULL,
    [Criticidad]   VARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_PV_Criticidad] PRIMARY KEY CLUSTERED ([idCriticidad] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

