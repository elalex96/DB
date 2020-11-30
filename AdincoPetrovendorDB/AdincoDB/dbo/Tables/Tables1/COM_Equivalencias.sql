CREATE TABLE [dbo].[COM_Equivalencias] (
    [IdEquivalencia] INT         IDENTITY (1, 1) NOT NULL,
    [Unidad]         VARCHAR (5) NULL,
    [Factor]         FLOAT (53)  NULL,
    [UnidadDestino]  VARCHAR (5) NULL,
    PRIMARY KEY CLUSTERED ([IdEquivalencia] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

