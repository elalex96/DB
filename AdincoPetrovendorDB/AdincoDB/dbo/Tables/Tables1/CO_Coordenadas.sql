CREATE TABLE [dbo].[CO_Coordenadas] (
    [idCoordenada]      INT          IDENTITY (1, 1) NOT NULL,
    [lat]               VARCHAR (50) NULL,
    [lng]               VARCHAR (50) NULL,
    [IdAreaContractual] INT          NOT NULL,
    [poligono]          INT          NULL,
    PRIMARY KEY CLUSTERED ([idCoordenada] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_idAreaContractual] FOREIGN KEY ([IdAreaContractual]) REFERENCES [dbo].[CO_AreaContractual] ([IdAreaContractual])
);

