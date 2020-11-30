CREATE TABLE [dbo].[CO_PesoMolecularGPA2145] (
    [IdPesoMolecular] INT        IDENTITY (1, 1) NOT NULL,
    [C1]              FLOAT (53) NULL,
    [C2]              FLOAT (53) NULL,
    [C3]              FLOAT (53) NULL,
    [nC4]             FLOAT (53) NULL,
    [IC4]             FLOAT (53) NULL,
    [nC5]             FLOAT (53) NULL,
    [IC5]             FLOAT (53) NULL,
    [C6]              FLOAT (53) NULL,
    [CO2]             FLOAT (53) NULL,
    [H2S]             FLOAT (53) NULL,
    [N2]              FLOAT (53) NULL,
    PRIMARY KEY CLUSTERED ([IdPesoMolecular] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

