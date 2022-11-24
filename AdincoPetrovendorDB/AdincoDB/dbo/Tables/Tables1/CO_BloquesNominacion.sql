CREATE TABLE [dbo].[CO_BloquesNominacion] (
    [BloqueID]          INT            IDENTITY (1000, 1) NOT NULL,
    [Nombre]            NVARCHAR (MAX) NULL,
    [idAreaContractual] INT            NULL,
    CONSTRAINT [PK__CO_Bloqu__1E811AE3D95946B6] PRIMARY KEY CLUSTERED ([BloqueID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__CO_Bloque__idAre__670CA2E0] FOREIGN KEY ([idAreaContractual]) REFERENCES [dbo].[CO_AreaContractual] ([IdAreaContractual])
);

